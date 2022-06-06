# frozen_string_literal: true

module Mutations
  module UserMutations
    class AddUser < BaseAddMutation
      self.entity_attributes = InputObjects::UserRegistrationAttributes
      set_entity

      def resolve(attributes:)
        user = User.new(attributes.to_h)

        if user.save
          { user: }
        else
          { errors: user.errors }
        end
      end
    end

    class UpdateUser < BaseUpdateMutation
      set_entity

      def resolve(id:, attributes:)
        user = User.find(id)

        current_ability.authorize! :update, user

        if user.update_without_password(attributes.to_h)
          { user: }
        else
          { errors: user.errors }
        end
      end
    end

    class ChangePassword < BaseMutation
      description 'Change the password for a User'

      argument :attributes, InputObjects::UserPasswordChangeAttributes,
               'Data object to change the password for User', required: true

      field :confirmation, String,
            'Message confirming password has been changed', null: true
      field :errors, Types::ValidationErrorsType,
            'Errors preventing password from being changed', null: true

      def resolve(attributes:)
        user = context[:current_user]

        if user.update_with_password(attributes.to_h)
          { confirmation: 'Password has been successfully changed!' }
        else
          { errors: user.errors }
        end
      end
    end
  end
end
