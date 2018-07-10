class Import < Thor
  desc 'teams [SRC]', 'Import Teams from JoonDEV database [SRC]'
  # method_option :benchmark, type: :boolean, aliases: '-b', desc: "Output benchmark performance"
  method_option :verbose, type: :boolean, aliases: '-v', desc: "Output all database commands"
  def teams(src)
    require File.expand_path('config/environment.rb')

    if options[:verbose]
      ActiveRecord::Base.logger = Logger.new(STDOUT)
    end

    puts ' ------------------------------------------- '
    puts '| IMPORTING DATA FROM JOONDEV TO MYFIFA_API |'
    puts " ------------------------------------------- \n"

    config = Rails.configuration.database_configuration[Rails.env]

    puts "FROM: #{ src }"
    puts "TO: #{ config['database'] }\n\n"

    client = PG::Connection.open(
      host: config['host'],
      dbname: src,
      user: config['username'],
      password: config['password'],
    )

    begin
      run_cmd 'Removing existing data' do
        Team.transaction do
          Team.all.map(&:destroy)
        end
      end

      teams = []
      run_cmd "Migrating Teams" do
        $teams = client.query 'SELECT * FROM my_fifa_teams'
        $seasons = client.query 'SELECT * FROM my_fifa_seasons'
        $teams.each do |team_row|
          first_season = $seasons
                         .select { |season| season['team_id'] == team_row['id'] }
                         .sort_by { |season| season['start_date'] }
                         .first
          start_date = first_season['start_date']

          teams << {
            id:         team_row['id'],
            user_id:    team_row['user_id'],
            title:      team_row['team_name'],
            start_date: start_date,
          }
        end

        Team.import teams, validate: false
      end

      players = []
      run_cmd "Migrating Players" do
        $players = client.query 'SELECT * FROM my_fifa_players'
        $contracts = client.query 'SELECT * FROM my_fifa_player_events WHERE type = $1', [ 'MyFifa::Contract' ]
        $players.each do |player_row|
          player_params = {
            id:      player_row['id'],
            team_id: player_row['team_id'],
            name:    player_row['name'],
            pos:     player_row['pos'],
            sec_pos: player_row['sec_pos'] ? YAML.load(player_row['sec_pos']) : [],

            ovr:     player_row['start_ovr'],
            value:   player_row['start_value'],
            youth:   player_row['youth'],

          }

          first_contract = $contracts
                           .select { |contract| contract['player_id'] == player_row['id'] }
                           .sort_by { |contract| contract['start_date'] }
                           .first

          player_params[:birth_year] = Date.strptime(first_contract['start_date']).year - player_row['start_age'].to_i

          # desc_object player_params, 'Player'
          players << player_params
        end
      end

      run_cmd 'Importing Migrated Players' do
        Player.import players, validate: false
      end

      run_cmd 'Migrating Player Histories' do
        Player.skip_callbacks = true

        $player_seasons = client.query 'SELECT my_fifa_player_seasons.*, end_date
                                        FROM my_fifa_player_seasons
                                        LEFT JOIN my_fifa_seasons ON my_fifa_player_seasons.season_id = my_fifa_seasons.id'

        histories = []
        $player_seasons.each do |record|
          histories << {
            player_id: record['player_id'],
            datestamp: record['end_date'],
            ovr:       record['ovr'],
            value:     record['value'],
            kit_no:    record['kit_no']
          }

          Player
            .where(id: record['player_id'])
            .update_all ovr:    record['ovr'],
                        value:  record['value'],
                        kit_no: record['kit_no']
        end

        PlayerHistory.import histories, validate: false

        Player.skip_callbacks = false
      end

      contracts = []
      transfers = []
      histories = []
      run_cmd 'Migrating Contracts and Transfers' do

        $contracts = client.query 'SELECT my_fifa_player_events.*, team_id
                                   FROM my_fifa_player_events
                                     LEFT JOIN my_fifa_players
                                     ON my_fifa_player_events.player_id = my_fifa_players.id
                                   WHERE type = $1', [ 'MyFifa::Contract' ]

        $contracts.each do |contract|
          if contract['origin'].present?
            cost = client.query 'SELECT * FROM my_fifa_costs WHERE event_id = $1 AND dir = $2', [ contract['id'], 'in' ]
            cost = cost.first

            transfer_params = {
              player_id:      contract['player_id'],
              signed_date:    contract['start_date'],
              effective_date: contract['start_date'],
              origin:         contract['origin'],
              destination:    $teams.find { |team| team['id'] == contract['team_id'] }['team_name'],
              fee:            cost['fee'],
              addon_clause:   cost['add_on_clause'],
              traded_player:  cost['player_id'] ? players.find{ |player| player.id.to_s == cost['player_id'] }.name : nil,
              loan:           contract['loan']
            }

            # desc_object transfer_params, 'Transfer'
            transfers << transfer_params
          end

          if contract['destination'].present?
            cost = client.query 'SELECT * FROM my_fifa_costs WHERE event_id = $1 AND dir = $2', [ contract['id'], 'out' ]
            cost = cost.first

            transfer_params = {
              player_id:      contract['player_id'],
              signed_date:    contract['end_date'],
              effective_date: contract['end_date'],
              origin:         $teams.find { |team| team['id'] == contract['team_id'] }['team_name'],
              destination:    contract['destination'],
              fee:            cost['fee'],
              addon_clause:   cost['add_on_clause'],
              traded_player:  cost['player_id'] ? players.find{ |player| player.id.to_s == cost['player_id'] }.name : nil,
              loan:           contract['loan'],
            }

            transfer_params[:destination] = nil if transfer_params[:destination] == 'RELEASED'

            # desc_object transfer_params, 'Transfer'
            transfers << transfer_params
          end

          $terms = client.query 'SELECT * FROM my_fifa_contract_terms WHERE contract_id = $1', [ contract['id'] ]
          $terms = $terms.to_a

          contract_params = {
            player_id:         contract['player_id'],
            wage:              $terms.last['wage'],
            signing_bonus:     $terms.last['signing_bonus'],
            release_clause:    $terms.last['release_clause'],
            performance_bonus: $terms.last['stat_bonus'],
            bonus_req:         $terms.last['num_stats'],
            bonus_req_type:    $terms.last['stat_type'],
            signed_date:       contract['start_date'],
            effective_date:    contract['start_date'],
            end_date:          contract['end_date']
          }

          contract_params[:bonus_req_type] = nil if contract_params[:bonus_req_type].blank?

          # desc_object contract_params, 'Contract'
          contracts << contract_params

          $terms.each do |term|
            term['stat_type'] = nil if term['stat_type'].blank?
            histories << {
              contract_id:       term['contract_id'],
              datestamp:         term['start_date'],
              wage:              term['wage'],
              signing_bonus:     term['signing_bonus'],
              release_clause:    term['release_clause'],
              performance_bonus: term['stat_bonus'],
              bonus_req:         term['num_stats'],
              bonus_req_type:    term['stat_type'],
              effective_date:    term['start_date'],
              end_date:          [ term['end_date'] || contract['end_date'], contract['end_date'] ].min
            }
          end
        end
      end

      run_cmd 'Importing Migrated Transfers' do
        Transfer.import transfers, validate: false
      end

      run_cmd 'Importing Migrated Contracts' do
        Contract.import contracts, validate: false
        ContractHistory.import histories, validate: false
      end

      loans = []
      run_cmd 'Migrating Loans' do
        $loans = client.query('SELECT * FROM my_fifa_player_events WHERE type = $1', [ 'MyFifa::Loan' ])
        $loans.each do |loan|
          loans << {
            player_id:   loan['player_id'],
            destination: loan['destination'],
            start_date:  loan['start_date'],
            end_date:    loan['end_date']
          }
        end
      end

      run_cmd 'Importing Migrated Loans' do
        Loan.import loans, validate: false
      end

      injuries = []
      run_cmd 'Migrating Injuries' do
        $injuries = client.query 'SELECT * FROM my_fifa_player_events WHERE type = $1', [ 'MyFifa::Injury' ]
        $injuries.each do |injury|
          injuries << {
            player_id:   injury['player_id'],
            description: injury['notes'],
            start_date:  injury['start_date'],
            end_date:    injury['end_date']
          }
        end
      end

      run_cmd 'Importing Migrated Injuries' do
        Injury.import injuries, validate: false
      end

      run_cmd 'Update Team Current Dates and Player Statuses' do
        Team.all.each do |team|
          current_date = $teams.find { |t| t['id'] == team.id.to_s }['current_date']
          team.update(current_date: current_date)
        end
      end

    rescue => e
      puts "===ERROR!==="
      puts e.message
      puts e.backtrace.join("\n")
      puts "===END ERROR!==="
    end
  end

  private

    def run_cmd(action)
      puts "#{action}..."
      yield
      puts "\t...done.\n\n"
    end

    def desc_object(obj, type)
      max_key_length = obj.keys.map(&:length).max

      puts "#{ type }:"
      obj.each do |k, v|
        puts "  #{ (k.to_s + ': ').ljust(max_key_length + 2) } #{ v }"
      end
    end
end
