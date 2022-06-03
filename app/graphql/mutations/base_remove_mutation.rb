# frozen_string_literal: true

module Mutations
  class BaseRemoveMutation < BaseMutation
    class_attribute :record_field_name,
                    :entity_klass_name,
                    :entity_type,
                    :model_klass

    def self.set_entity
      self.entity_klass_name ||= to_s.demodulize.gsub('Remove', '')
      self.record_field_name ||= entity_klass_name.to_s.underscore.to_sym
      self.entity_type ||= Types.const_get("#{entity_klass_name}Type")
      self.model_klass ||= entity_klass_name.constantize

      description "Remove #{entity_klass_name} from database"

      argument :id, GraphQL::Types::ID,
               "ID of #{entity_klass_name} to delete", required: true

      field record_field_name, entity_type,
            "#{entity_klass_name} that was removed if deleted from the database",
            null: true
      field :errors, Types::ValidationErrorsType,
            "Errors preventing #{entity_klass_name} from being removed", null: true
    end

    def current_user
      @current_user ||= context[:current_user]
    end

    def current_ability
      @current_ability ||= Ability.new(current_user)
    end

    def resolve(id:)
      record = self.class.model_klass.find(id)

      current_ability.authorize! :destroy, record

      if record.destroy
        { self.class.record_field_name => record }
      else
        { errors: record.errors }
      end
    end
  end
end
