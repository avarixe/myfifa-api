# frozen_string_literal: true

module Mutations
  module AddMutations
    {
      'Team' => %w[Competition Match Player Squad],
      'Player' => %w[Contract Injury Loan Transfer],
      'Match' => %w[Booking Cap Goal Substitution],
      'Competition' => %w[Stage],
      'Stage' => %w[Fixture TableRow]
    }.each do |parent_model_name, models|
      models.each do |model_name|
        add_mutation = Class.new(BaseMutation) do
          argument "#{parent_model_name.underscore.to_sym}_id".to_sym,
                   GraphQL::Types::ID,
                   required: true
          argument :attributes,
                   Types::Inputs.const_get("#{model_name}Attributes"),
                   required: true

          field model_name.underscore.to_sym,
                Types::Myfifa.const_get("#{model_name}Type"),
                null: true
          field :errors, Types::ValidationErrorsType, null: true

          def resolve(**args)
            parent_class = parent_model_name.constantize
            parent_id = args["#{parent_model_name.underscore}_id".to_sym]
            parent_record = parent_class.find(parent_id)

            record = parent_record
                     .public_send(model_name.underscore.pluralize)
                     .new(args[:attributes].to_h)

            if record.save
              { model_name.underscore.to_sym => record }
            else
              { errors: record.errors }
            end
          end

          define_singleton_method :parent_model_name do
            parent_model_name
          end

          define_singleton_method :model_name do
            model_name
          end

          def parent_model_name
            self.class.parent_model_name
          end

          def model_name
            self.class.model_name
          end
        end

        const_set("Add#{model_name}", add_mutation)
      end
    end
  end
end
