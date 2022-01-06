# frozen_string_literal: true

class StagePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(competition: :team).where(teams: { user_id: user.id })
    end
  end
end
