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
      PenaltyShootout
      Player
      Squad
      Stage
      Substitution
      TableRow
      Team
      Transfer
      User
    ].each do |klass|
      update_mutation = Class.new(BaseMutation) do
        argument :id, GraphQL::Types::ID, required: true
        argument :attributes,
                 Types::Inputs.const_get("#{klass}Attributes"),
                 required: true

        field klass.underscore.to_sym,
              Types::Myfifa.const_get("#{klass}Type"),
              null: true
        field :errors, Types::ValidationErrorsType, null: true

        def resolve(id:, attributes:)
          record = klass.constantize.find(id)

          if record.update(attributes.to_h)
            { klass.underscore.to_sym => record }
          else
            { errors: record.errors }
          end
        end
      end

      const_set("Update#{klass}", update_mutation)
    end
  end
end
