class Import < Thor
  desc 'players [SRC]', 'Import Players from JoonDEV database [SRC]'
  # method_option :clean, type: :boolean, aliases: '-c', desc: "Truncates all tables prior to import"
  method_option :verbose, type: :boolean, aliases: '-v', desc: "Output all database commands"
  def players(src)
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
        Team.all.map(&:destroy)
      end

      run_cmd 'Preloading source tables' do
        $teams = client.query('SELECT * FROM my_fifa_teams')
        $players = client.query('SELECT * FROM my_fifa_players')
        $seasons = client.query('SELECT * FROM my_fifa_seasons')
        $contracts = client.query('SELECT * FROM my_fifa_player_events WHERE type = $1', [ 'MyFifa::Contract' ])
      end

      $teams.each do |team_row|
        first_season = $seasons
                       .select { |season| season['team_id'] == team_row['id'] }
                       .sort_by { |season| season['start_date'] }
                       .first
        start_date = first_season['start_date']

        team_params = {
          user_id: team_row['user_id'],
          title: team_row['team_name'],
          start_date: start_date,
        }

        run_cmd "Creating Team #{ team_params[:title] }" do
          # desc_object team_params, 'Team'
          $team = Team.new(team_params)
          $team.id = team_row['id']
          $team.save!
        end

        $players
          .select{ |player| player['team_id'] == team_row['id'] }
          .each do |player_row|

          player_params = {
            name:    player_row['name'],
            pos:     player_row['pos'],

            ovr:     player_row['start_ovr'],
            value:   player_row['start_value'],
            youth:   player_row['youth'],
          }

          if player_row['sec_pos']
            player_params[:sec_pos] = YAML.load player_row['sec_pos']
          end

          first_contract = $contracts
                           .select { |contract| contract['player_id'] == player_row['id'] }
                           .sort_by { |contract| contract['start_date'] }
                           .first

          player_params[:birth_year] = Date.strptime(first_contract['start_date']).year - player_row['start_age'].to_i

          run_cmd "Creating Player #{ player_params[:name] }" do
            desc_object player_params, 'Player'
            player = $team.players.new(player_params)
            player.id = player_row['id']
            player.save!
          end

        end

        # TODO: Iterate through all PlayerEvents and Matches
        # sort both arrays by date
        # until both arrays are empty
        #   pop the earliest (event or match)
        #   increment team current date
        #   create relevant record(s)

        run_cmd 'Retrieving PlayerEvents and Matches' do
          puts "team: #{$team.inspect}"
          $player_events = client.query('SELECT my_fifa_player_events.* '\
                                        'FROM my_fifa_player_events'\
                                        '  LEFT JOIN my_fifa_players'\
                                        '  ON my_fifa_player_events.player_id = my_fifa_players.id '\
                                        'WHERE my_fifa_players.team_id = $1', [ $team.id ])
          puts $player_events.values.length
          $player_events = $player_events
                           .sort_by{ |event| event['start_date'] }
                           .each do |event|
                             desc_object event, 'Event'
                           end
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