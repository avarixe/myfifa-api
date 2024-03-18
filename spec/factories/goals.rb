# frozen_string_literal: true

# == Schema Information
#
# Table name: goals
#
#  id            :bigint           not null, primary key
#  assisted_by   :string
#  home          :boolean          default(FALSE), not null
#  minute        :integer
#  own_goal      :boolean          default(FALSE), not null
#  player_name   :string
#  set_piece     :string(20)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assist_cap_id :bigint
#  assist_id     :bigint
#  cap_id        :bigint
#  match_id      :bigint
#  player_id     :bigint
#
# Indexes
#
#  index_goals_on_assist_cap_id  (assist_cap_id)
#  index_goals_on_assist_id      (assist_id)
#  index_goals_on_cap_id         (cap_id)
#  index_goals_on_match_id       (match_id)
#  index_goals_on_player_id      (player_id)
#

FactoryBot.define do
  factory :goal do
    minute { Faker::Number.between(from: 1, to: 120) }
    player_name { Faker::Name.name }
    match

    factory :player_goal do
      cap
    end

    factory :home_goal do
      home { true }

      factory :own_home_goal do
        own_goal { true }
      end
    end

    factory :away_goal do
      home { false }

      factory :own_away_goal do
        own_goal { true }
      end
    end
  end
end
