# frozen_string_literal: true

class PunditProvider
  include Pundit

  attr_accessor :current_user

  def initialize(user:)
    self.current_user = user
  end

  public :policy_scope
end
