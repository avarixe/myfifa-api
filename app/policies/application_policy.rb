# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def manage?
    record.team.user == user
  end

  def create?
    manage?
  end

  def update?
    manage?
  end

  def destroy?
    manage?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # def resolve
    #   scope.all
    # end

    private

      attr_reader :user, :scope
  end
end
