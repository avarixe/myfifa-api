# frozen_string_literal: true

class PenaltyShootoutPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(match: :team).where(teams: { user_id: user.id })
    end
  end
end
