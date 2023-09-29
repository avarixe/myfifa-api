# frozen_string_literal: true

class CapPolicy < ApplicationPolicy
  def substitute?
    manage? && record.next_id.blank?
  end
end
