class ApplicationRecord < ActiveRecord::Base
  default_scope { order(id: :asc) }

  self.abstract_class = true

  def as_json(options = {})
    super((options || {}).merge({
      except: %i[
        created_at
        updated_at
      ]
    }))
  end
end
