class Migrate < Thor
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

      $teams = client.query 'SELECT * FROM my_fifa_teams'
      $seasons = client.query 'SELECT * FROM my_fifa_seasons'

      teams = []
      run_cmd "Migrating Teams" do
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

      $players = client.query 'SELECT * FROM my_fifa_players'
      $contracts = client.query 'SELECT events.*, team_name
                                 FROM my_fifa_player_events AS events
                                 LEFT JOIN my_fifa_players AS players
                                   ON events.player_id = players.id
                                 LEFT JOIN my_fifa_teams AS teams
                                   ON players.team_id = teams.id
                                 WHERE type = $1', [ 'MyFifa::Contract' ]

      players = []
      run_cmd "Migrating Players" do
        $players.each do |player_row|
          player_params = {
            id:      player_row['id'],
            team_id: player_row['team_id'],
            name:    player_row['name'],
            pos:     player_row['pos'],
            sec_pos: player_row['sec_pos'] ? YAML.load(player_row['sec_pos']) : [],

            ovr:     player_row['start_ovr'],
            value:   player_row['start_value'],
            youth:   player_row['youth'] == 't'

          }

          first_contract = $contracts
                           .select { |contract| contract['player_id'] == player_row['id'] }
                           .sort_by { |contract| contract['start_date'] }
                           .first

          player_params[:birth_year] = Date.strptime(first_contract['start_date']).year -
                                       player_row['start_age'].to_i

          # desc_object player_params, 'Player'
          players << player_params
        end
      end

      run_cmd 'Importing Migrated Players' do
        Player.import players, validate: false
      end

      $player_seasons = client.query 'SELECT player_seasons.*, end_date
                                      FROM my_fifa_player_seasons AS player_seasons
                                      LEFT JOIN my_fifa_seasons AS seasons
                                        ON player_seasons.season_id = seasons.id'

      run_cmd 'Migrating Player Histories' do
        Player.skip_callbacks = true

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
        $contracts.each do |contract|
          if contract['origin'].present?
            cost = client.query 'SELECT costs.*, name
                                 FROM my_fifa_costs AS costs
                                 LEFT JOIN my_fifa_players AS players
                                   ON costs.player_id = players.id
                                 WHERE event_id = $1 AND dir = $2', [ contract['id'], 'in' ]
            cost = cost.first

            transfer_params = {
              player_id:      contract['player_id'],
              signed_date:    contract['start_date'],
              effective_date: contract['start_date'],
              origin:         contract['origin'],
              destination:    contract['team_name'],
              fee:            cost['fee'],
              addon_clause:   cost['add_on_clause'],
              traded_player:  cost['name'],
              loan:           contract['loan'] == 't'
            }

            # desc_object transfer_params, 'Transfer'
            transfers << transfer_params
          end

          if contract['destination'].present?
            cost = client.query 'SELECT my_fifa_costs.*, name
                                 FROM my_fifa_costs
                                 LEFT JOIN my_fifa_players
                                   ON my_fifa_costs.player_id = my_fifa_players.id
                                 WHERE event_id = $1 AND dir = $2', [ contract['id'], 'out' ]
            cost = cost.first

            transfer_params = {
              player_id:      contract['player_id'],
              signed_date:    contract['end_date'],
              effective_date: contract['end_date'],
              origin:         contract['team_name'],
              destination:    contract['destination'],
              fee:            cost['fee'],
              addon_clause:   cost['add_on_clause'],
              traded_player:  cost['name'],
              loan:           contract['loan'] == 't'
            }

            transfer_params[:destination] = nil if transfer_params[:destination] == 'RELEASED'

            # desc_object transfer_params, 'Transfer'
            transfers << transfer_params
          end

          $terms = client.query 'SELECT *
                                 FROM my_fifa_contract_terms
                                 WHERE contract_id = $1', [ contract['id'] ]
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

      $loans = client.query 'SELECT *
                             FROM my_fifa_player_events
                             WHERE type = $1', [ 'MyFifa::Loan' ]

      loans = []
      run_cmd 'Migrating Loans' do
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

      $injuries = client.query 'SELECT *
                                FROM my_fifa_player_events
                                WHERE type = $1', [ 'MyFifa::Injury' ]
      injuries = []
      run_cmd 'Migrating Injuries' do
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

      $matches = client.query 'SELECT matches.*, team_name
                               FROM my_fifa_matches AS matches
                               LEFT JOIN my_fifa_teams AS teams
                                 ON teams.id = matches.team_id'
      matches = []
      goals = []
      penalty_shootouts = []
      run_cmd 'Importing Matches' do
        $matches.each do |record|
          matches << {
            id:          record['id'],
            team_id:     record['team_id'],
            competition: record['competition'],
            date_played: record['date_played'],
            home:        record['home'] == 't' ? record['team_name'] : record['opponent'],
            away:        record['home'] == 't' ? record['opponent'] : record['team_name'],
            home_score_override: record['home'] == 't' ? record['score_gf'] : record['score_ga'],
            away_score_override: record['home'] == 't' ? record['score_ga'] : record['score_gf'],
          }

          if record['penalty_gf'] && record['penalty_ga']
            penalty_shootouts << {
              match_id: record['id'],
              home_score: record['home'] == 't' ? record['penalty_gf'] : record['penalty_ga'],
              away_score: record['home'] == 't' ? record['penalty_ga'] : record['penalty_gf']
            }
          end
        end
      end

      $match_events = client.query 'SELECT logs.*, name, home
                                    FROM my_fifa_match_logs AS logs
                                    LEFT JOIN my_fifa_matches AS matches
                                      ON matches.id = logs.match_id
                                    LEFT JOIN my_fifa_players AS players
                                      ON players.id = logs.player1_id'
      substitutions = []
      bookings = []
      run_cmd 'Importing Match Events' do
        $match_events.each do |event|
          case event['event']
          when 'Goal'
            goals << {
              match_id:    event['match_id'],
              minute:      event['minute'],
              player_name: event['name'],
              player_id:   event['player1_id'],
              assist_id:   event['player2_id'],
              home:        event['home'] == 't',
              own_goal:    false
            }
          when 'Substitution'
            substitutions << {
              match_id:       event['match_id'],
              minute:         event['minute'],
              player_name:    event['name'],
              player_id:      event['player1_id'],
              replacement_id: event['player2_id'],
              home:           event['home'] == 't'
            }
          when 'Booking'
            bookings << {
              match_id:    event['match_id'],
              minute:      event['minute'],
              player_name: event['name'],
              player_id:   event['player1_id'],
              home:        event['home'] == 't'
            }
          end
        end
      end

      $player_records = client.query "SELECT records.*,
                                             subins.minute AS subin_minute,
                                             subouts.minute AS subout_minute
                                      FROM my_fifa_player_records AS records
                                      LEFT JOIN my_fifa_match_logs AS subins
                                        ON subins.match_id = records.match_id
                                        AND subins.player2_id = records.player_id
                                        AND subins.event = 'Substitution'
                                      LEFT JOIN my_fifa_match_logs AS subouts
                                        ON subouts.match_id = records.match_id
                                        AND subouts.player1_id = records.player_id
                                        AND subouts.event = 'Substitution'
                                      GROUP BY records.id, subins.minute, subouts.minute"
      logs = []
      run_cmd 'Importing Match-Player Records' do
        $player_records.each do |record|
          logs << {
            player_id: record['player_id'],
            match_id:  record['match_id'],
            pos:       record['pos'],
            start:     record['subin_minute'] || 0,
            stop:      record['subout_minute'] || 90
          }
        end
      end

      run_cmd 'Importing Migrated Match Data' do
        Match.import matches, validate: false
        Goal.import goals, validate: false
        PenaltyShootout.import penalty_shootouts, validate: false
        MatchLog.import logs, validate: false
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
