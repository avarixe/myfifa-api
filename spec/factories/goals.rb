# == Schema Information
#
# Table name: goals
#
#  id          :bigint(8)        not null, primary key
#  match_id    :bigint(8)
#  minute      :integer
#  player_name :string
#  player_id   :bigint(8)
#  assist_id   :bigint(8)
#  home        :boolean          default(FALSE)
#  own_goal    :boolean          default(FALSE)
#  penalty     :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  assisted_by :string
#
# Indexes
#
#  index_goals_on_assist_id  (assist_id)
#  index_goals_on_match_id   (match_id)
#  index_goals_on_player_id  (player_id)
#

FactoryBot.define do
  factory :goal do
    minute { Faker::Number.between(1, 120) }
    player_name { Faker::Name.name }
    match

    factory :home_goal do
      home true

      factory :own_home_goal do
        own_goal true
      end
    end

    factory :away_goal do
      home false

      factory :own_away_goal do
        own_goal true
      end
    end
  end
end
