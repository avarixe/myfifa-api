# frozen_string_literal: true

module Mutations
  class BaseAddMutation < BaseMutation
    class_attribute :parent_id,
                    :parent_model_klass,
                    :record_field_name,
                    :entity_klass_name,
                    :entity_type,
                    :entity_attributes,
                    :model_klass,
                    :policy

    def self.set_entity
      self.entity_klass_name ||= to_s.demodulize.gsub('Add', '')
      self.record_field_name ||= entity_klass_name.to_s.underscore.to_sym
      self.entity_type ||= Types.const_get("#{entity_klass_name}Type")
      self.entity_attributes ||= InputObjects.const_get("#{entity_klass_name}Attributes")
      self.model_klass ||= entity_klass_name.constantize
      self.policy ||= "#{entity_klass_name}Policy".constantize

      description "Create new #{entity_klass_name} in database " \
                  'with the provided attributes'

      argument :attributes, entity_attributes,
               "Data object to save as #{entity_klass_name}", required: true

      field record_field_name, entity_type,
            "#{entity_klass_name} that was created if saved to database",
            null: false
    end

    def self.parent_type=(parent_type)
      self.parent_id ||= "#{parent_type.underscore}_id".to_sym
      self.parent_model_klass ||= parent_type.constantize

      argument parent_id, GraphQL::Types::ID,
               "ID of #{parent_model_klass.name} bounding #{entity_klass_name}",
               required: true
    end

    def current_user
      @current_user ||= context[:current_user]
    end

    def resolve(**args)
      parent_id = args[self.class.parent_id]
      parent_record = self.class.parent_model_klass.find(parent_id)
      record = parent_record
               .public_send(self.class.record_field_name.to_s.pluralize)
               .new

      if policy.new(current_user, record).create?
        record.attributes = args[:attributes].to_h
        record.save!
        { self.class.record_field_name => record }
      else
        GraphQL::ExecutionError.new('You are not allow to perform this action')
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.full_messages.first)
    end
  end
end
