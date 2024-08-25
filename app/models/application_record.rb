# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.cache_options(category, *attributes)
    attributes.each do |attribute|
      cache_method = :"cache_#{attribute}_as_#{category}_option"

      after_save cache_method, if: :"saved_change_to_#{attribute}?"

      define_method cache_method do
        Option.create user_id: team.user_id,
                      category:,
                      value: public_send(attribute)
      end
    end
  end

  def as_json(options = {})
    options[:except] ||= []
    options[:except] += %i[updated_at]
    super
  end
end
