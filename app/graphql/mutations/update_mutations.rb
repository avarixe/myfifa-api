# frozen_string_literal: true

module Mutations
  module UpdateMutations
    %w[
      Booking
      Cap
      Competition
      Contract
      Fixture
      Goal
      Injury
      Loan
      Match
      Player
      Squad
      Stage
      Substitution
      TableRow
      Team
      Transfer
      User
    ].each do |model_name|
      update_mutation = Class.new(BaseMutation) do
        argument :id, GraphQL::Types::ID, required: true
        argument :attributes,
                 Types::Inputs.const_get("#{model_name}Attributes"),
                 required: true

        field model_name.underscore.to_sym,
              Types::Myfifa.const_get("#{model_name}Type"),
              null: true
        field :errors, Types::ValidationErrorsType, null: true

        def resolve(id:, attributes:)
          record = model_name.constantize.find(id)

          if record.update(attributes.to_h)
            { model_name.underscore.to_sym => record }
          else
            { errors: record.errors }
          end
        end

        define_singleton_method :model_name do
          model_name
        end

        def model_name
          self.class.model_name
        end
      end

      const_set("Update#{model_name}", update_mutation)
    end
  end
end
