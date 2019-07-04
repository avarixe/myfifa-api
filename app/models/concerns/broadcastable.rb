# frozen_string_literal: true

module Broadcastable
  extend ActiveSupport::Concern

  included do
    after_save :broadcast_save
    after_destroy :broadcast_destroy
  end

  def broadcast_save
    return unless respond_to?(:team) && previous_changes.any?

    TeamChannel.broadcast_to(
      team,
      type: self.class.name,
      data: as_json
    )
  end

  def broadcast_destroy
    return unless respond_to?(:team)

    TeamChannel.broadcast_to(
      team,
      destroyed: true,
      type: self.class.name,
      data: as_json
    )
  end
end
