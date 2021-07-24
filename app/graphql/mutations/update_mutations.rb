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
    ].each do |model|
      update_mutation = Class.new(BaseMutation) do
        description "Update #{model} with the provided attributes"

        argument :id, GraphQL::Types::ID,
                 "ID of #{model} to update", required: true
        argument :attributes, InputObjects.const_get("#{model}Attributes"),
                 "Data object to update #{model}", required: true

        field model.underscore.to_sym,
              Types.const_get("#{model}Type"),
              "#{model} that was updated if attributes were saved",
              null: true
        field :errors, Types::ValidationErrorsType,
              'Errors preventing changes from being applied', null: true

        define_method :resolve do |id:, attributes:|
          current_ability = Ability.new(context[:current_user])
          record = model.constantize.find(id)

          current_ability.authorize! :update, record

          if record.skip_preload.update(attributes.to_h)
            { model.underscore.to_sym => record }
          else
            { errors: record.errors }
          end
        end
      end

      const_set "Update#{model}", update_mutation
    end
  end
end
