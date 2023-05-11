# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  def manage?
    record.user == user
  end
end
