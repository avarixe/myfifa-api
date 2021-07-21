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
    ].each do |model|
      remove_mutation = Class.new(BaseMutation) do
        description "Remove #{model} from database"

        argument :id,
                 GraphQL::Types::ID,
                 "ID of #{model} to delete",
                 required: true

        field model.underscore.to_sym,
              Types::Myfifa.const_get("#{model}Type"),
              "Removed #{model} if deleted from the database",
              null: true
        field :errors,
              Types::ValidationErrorsType,
              "Errors preventing #{model} from being removed",
              null: true

        define_method :resolve do |id:|
          current_ability = Ability.new(context[:current_user])
          record = model.constantize.accessible_by(current_ability).find(id)

          if record.destroy
            { model.underscore.to_sym => record }
          else
            { errors: record.errors }
          end
        end
      end

      const_set("Remove#{model}", remove_mutation)
    end
  end
end
