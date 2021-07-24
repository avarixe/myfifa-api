# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def as_json(options = {})
    options[:except] ||= []
    options[:except] += %i[updated_at]
    super
  end
end
