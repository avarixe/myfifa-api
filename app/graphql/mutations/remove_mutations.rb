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
    ].each do |model_name|
      remove_mutation = Class.new(BaseMutation) do
        argument :id, GraphQL::Types::ID, required: true

        field model_name.underscore.to_sym,
              Types::Myfifa.const_get("#{model_name}Type"),
              null: true
        field :errors, Types::ValidationErrorsType, null: true

        def resolve(id:)
          record = model_name.constantize.find(id)

          if record.destroy
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

      const_set("Remove#{model_name}", remove_mutation)
    end
  end
end
