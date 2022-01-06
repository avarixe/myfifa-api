# frozen_string_literal: true

class FixturePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope
        .joins(stage: { competition: :team })
        .where(teams: { user_id: user.id })
    end
  end
end
