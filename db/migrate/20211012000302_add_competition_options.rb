class AddCompetitionOptions < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        User.all.each do |user|
          competition_options =
            Competition
            .where(team_id: user.teams.select(:id))
            .distinct
            .pluck(:name)
            .map do |name|
              { user_id: user.id, category: 'Competition', value: name }
            end
          Option.insert_all(competition_options) if competition_options.any?
        end
      end
    end
  end
end
