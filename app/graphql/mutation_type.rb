# frozen_string_literal: true

class MutationType < BaseTypes::BaseObject
  field :grant_access_token, mutation: Mutations::GrantAccessToken
  field :revoke_access_token, mutation: Mutations::RevokeAccessToken

  field :register_user, mutation: Mutations::UserMutations::AddUser
  field :update_user, mutation: Mutations::UserMutations::UpdateUser
  field :change_password, mutation: Mutations::UserMutations::ChangePassword

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
    TableRow
    Team
    Transfer
  ].each do |model|
    field :"add_#{model.underscore}",
          mutation: Mutations.const_get("#{model}Mutations").const_get("Add#{model}")
    field :"update_#{model.underscore}",
          mutation: Mutations.const_get("#{model}Mutations").const_get("Update#{model}")
    field :"remove_#{model.underscore}",
          mutation: Mutations.const_get("#{model}Mutations").const_get("Remove#{model}")
  end

  field :upload_badge, mutation: Mutations::TeamMutations::UploadBadge
  field :release_player, mutation: Mutations::PlayerMutations::ReleasePlayer
  field :retire_player, mutation: Mutations::PlayerMutations::RetirePlayer
  field :apply_squad_to_match, mutation: Mutations::MatchMutations::ApplySquadToMatch
  field :update_match_formation, mutation: Mutations::MatchMutations::UpdateMatchFormation
  field :substitute_cap, mutation: Mutations::CapMutations::SubstituteCap
  field :store_match_lineup_to_squad,
        mutation: Mutations::SquadMutations::StoreMatchLineupToSquad
  field :remove_penalty_shootout,
        mutation: Mutations::PenaltyShootoutMutations::RemovePenaltyShootout
end
