# frozen_string_literal: true

module Mutations
  module AddMutations
    {
      'Team' => %w[Competition Match Player Squad],
      'Player' => %w[Contract Injury Loan Transfer],
      'Match' => %w[Booking Cap Goal Substitution],
      'Competition' => %w[Stage],
      'Stage' => %w[Fixture TableRow]
    }.each do |parent_model, models|
      models.each do |model|
        add_mutation = Class.new(BaseMutation) do
          description "Create new #{model} in database " \
                      'with the provided attributes'

          argument "#{parent_model.underscore}_id".to_sym, GraphQL::Types::ID,
                   "ID of #{parent_model} bounding #{model}", required: true
          argument :attributes, InputObjects.const_get("#{model}Attributes"),
                   "Data object to save as #{model}", required: true

          field model.underscore.to_sym,
                Types.const_get("#{model}Type"),
                "#{model} that was created if saved to database",
                null: true
          field :errors, Types::ValidationErrorsType,
                "Errors preventing #{model} from being created", null: true

          define_method :resolve do |**args|
            parent_id = args["#{parent_model.underscore}_id".to_sym]
            parent_record = context[:pundit]
                            .policy_scope(parent_model.constantize)
                            .find(parent_id)

            record = parent_record.public_send(model.underscore.pluralize).new
            record.attributes = args[:attributes].to_h

            if record.save
              { model.underscore.to_sym => record }
            else
              { errors: record.errors }
            end
          end
        end

        const_set "Add#{model}", add_mutation
      end
    end
  end
end
