# frozen_string_literal: true

module Types
  module Statistics
    class PlayerHistoryStatsType < BaseObject
      field :season, Int, null: false
      field :player_id, ID, null: false
      field :ovr, [Int], null: false
      field :value, [Int], null: false
    end
  end
end
