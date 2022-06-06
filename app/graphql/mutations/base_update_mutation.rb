# frozen_string_literal: true

module Mutations
  class BaseUpdateMutation < BaseMutation
    class_attribute :record_field_name,
                    :entity_klass_name,
                    :entity_type,
                    :entity_attributes,
                    :model_klass

    def self.set_entity
      self.entity_klass_name = to_s.demodulize.gsub('Update', '')
      self.record_field_name = entity_klass_name.to_s.underscore.to_sym
      self.entity_type = Types.const_get("#{entity_klass_name}Type")
      self.entity_attributes = InputObjects.const_get("#{entity_klass_name}Attributes")
      self.model_klass = entity_klass_name.constantize

      description "Update #{entity_klass_name} with the provided attributes"

      argument :id, GraphQL::Types::ID,
               "ID of #{entity_klass_name} to update", required: true
      argument :attributes, entity_attributes,
               "Data object to update #{entity_klass_name}", required: true

      field record_field_name, entity_type,
            "#{entity_klass_name} that was updated if attributes were saved",
            null: true
      field :errors, Types::ValidationErrorsType,
            'Errors preventing changes from being applied', null: true
    end

    def current_user
      @current_user ||= context[:current_user]
    end

    def current_ability
      @current_ability ||= Ability.new(current_user)
    end

    def resolve(id:, attributes:)
      record = self.class.model_klass.find(id)

      current_ability.authorize! :update, record

      if record.skip_preload.update(attributes.to_h)
        { self.class.record_field_name => record }
      else
        { errors: record.errors }
      end
    end
  end
end
