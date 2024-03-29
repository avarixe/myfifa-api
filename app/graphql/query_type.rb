# frozen_string_literal: true

class QueryType < BaseTypes::BaseObject
  # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
  include GraphQL::Types::Relay::HasNodeField
  include GraphQL::Types::Relay::HasNodesField

  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  field :user, Types::UserType, 'Data about the current User', null: true
  field :teams, [Types::TeamType],
        'List of all Teams owned by User', null: true
  field :team, Types::TeamType, 'Specific Team owned by User', null: true do
    argument :id, ID, 'ID of Team', required: true
  end
  field :player, Types::PlayerType,
        'Specific Player bound to a Team owned by User', null: false do
    argument :id, ID, 'ID of Player', required: true
  end
  field :match, Types::MatchType,
        'Specific Match bound to a Team owned by User', null: false do
    argument :id, ID, 'ID of Match', required: true
  end
  field :competition, Types::CompetitionType,
        'Specific Competition bound to a Team owned by User', null: false do
    argument :id, ID, 'ID of Competition', required: true
  end
  field :options, [String],
        'Options previously entered by User for select Category', null: false do
    argument :category, Enums::OptionCategoryEnum,
             'Category of results', required: true
    argument :search, String, 'Search Term to filter results', required: false
  end

  def user
    context[:current_user]
  end

  delegate :teams, to: :user, allow_nil: true

  def team(id:)
    teams&.find(id)
  end

  def player(id:)
    PlayerPolicy::Scope.new(user, Player).resolve.find(id)
  end

  def match(id:)
    MatchPolicy::Scope.new(user, Match).resolve.find(id)
  end

  def competition(id:)
    CompetitionPolicy::Scope.new(user, Competition).resolve.find(id)
  end

  def options(category:, search: nil)
    context[:current_user]
      .options
      .where(category:)
      .where('LOWER(value) LIKE ?', "%#{search&.downcase}%")
      .pluck(:value)
  end
end
