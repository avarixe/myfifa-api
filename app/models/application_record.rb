# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  default_scope { order(id: :asc) }

  self.abstract_class = true

  def as_json(options = {})
    options[:except] ||= []
    options[:except] += %i[created_at updated_at]
    super
  end

  after_save :broadcast_save
  after_destroy :broadcast_destroy

  def broadcast_save
    return unless respond_to?(:team) && previous_changes.any?

    TeamChannel.broadcast_to(
      team,
      type: self.class.name,
      data: as_json
    )
  end

  def broadcast_destroy
    return unless respond_to?(:team) && previous_changes.any?

    TeamChannel.broadcast_to(
      team,
      destroyed: true,
      type: self.class.name,
      data: as_json
    )
  end
end
