# frozen_string_literal: true

module Mutations
  module RemoveMutations
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
      remove_mutation = Class.new(BaseMutation) do
        argument :id, GraphQL::Types::ID, required: true

        field klass.underscore.to_sym,
              Types::Myfifa.const_get("#{klass}Type"),
              null: true
        field :errors, Types::ValidationErrorsType, null: true

        def resolve(id:)
          record = klass.constantize.find(id)

          if record.destroy
            { klass.underscore.to_sym => record }
          else
            { errors: record.errors }
          end
        end
      end

      const_set("Remove#{klass}", remove_mutation)
    end
  end
end
