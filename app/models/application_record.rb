class ApplicationRecord < ActiveRecord::Base
  cattr_accessor :skip_callbacks

  default_scope { order(id: :asc) }

  self.abstract_class = true
end
