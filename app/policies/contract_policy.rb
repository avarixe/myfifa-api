# frozen_string_literal: true

class ContractPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(player: :team).where(teams: { user_id: user.id })
    end
  end
end
