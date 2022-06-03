# frozen_string_literal: true

module Mutations
  module TeamMutations
    class AddTeam < BaseAddMutation
      set_entity

      def resolve(attributes:)
        team = current_user.teams.new(attributes.to_h)

        if team.save
          { team: }
        else
          { errors: team.errors }
        end
      end
    end

    class UpdateTeam < BaseUpdateMutation
      set_entity
    end

    class RemoveTeam < BaseRemoveMutation
      set_entity
    end

    class UploadBadge < BaseMutation
      description 'Upload new Team badge'

      argument :team_id, ID, 'ID of Team to upload this Badge', required: true
      argument :badge, ApolloUploadServer::Upload, required: true

      field :team, Types::TeamType,
            'Team that was updated if saved to database', null: true
      field :errors, Types::ValidationErrorsType,
            'Errors preventing Team from being created', null: true

      def resolve(team_id:, badge:)
        team = context[:current_user].teams.find(team_id)

        blob = ActiveStorage::Blob.create_and_upload!(
          io: badge,
          filename: badge.original_filename,
          content_type: badge.content_type
        )

        if team.update(badge: blob)
          { team: }
        else
          { errors: team.errors }
        end
      end
    end
  end
end
