class ApplicationRecord < ActiveRecord::Base
  default_scope { order(id: :asc) }

  self.abstract_class = true
end
