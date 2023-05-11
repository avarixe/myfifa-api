# frozen_string_literal: true

class CompetitionPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:team).where(teams: { user_id: user.id })
    end
  end
end
