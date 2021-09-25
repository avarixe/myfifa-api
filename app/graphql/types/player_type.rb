# frozen_string_literal: true

module Types
  class PlayerType < BaseTypes::BaseObject
    description 'Record of a Soccer/Football Player'

    field :id, ID, 'Unique Identifer of record', null: false
    field :team_id, ID, 'ID of Team', null: false
    field :name, String, 'Name of this Player', null: false
    field :nationality, String, 'Nationality of this Player', null: true
    field :pos, Enums::PlayerPositionEnum,
          'Primary Position of this Player', null: false
    field :sec_pos, [Enums::PlayerPositionEnum],
          'List of Secondary Positions of this Player', null: false
    field :ovr, Integer, 'Overall Rating of this Player', null: false
    field :value, Integer, 'Value of this Player', null: false
    field :birth_year, Integer, 'Year of Birth of this Player', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false
    field :status, Enums::PlayerStatusEnum, 'Status of this Player', null: true
    field :youth, Boolean,
          'Whether this Player came from the Youth Academy', null: false
    field :kit_no, Integer, 'Kit Number assigned to this Player', null: true

    field :age, Integer, 'Age of this Player', null: false

    field :team, TeamType, 'Team bound to this Player', null: false

    field :histories, [PlayerHistoryType],
          'List of Player History records bound to this Player', null: false
    field :injuries, [InjuryType],
          'List of Injuries bound to this Player', null: false
    field :loans, [LoanType],
          'List of Loans bound to this Player', null: false
    field :contracts, [ContractType],
          'List of Contracts bound to this Player', null: false
    field :transfers, [TransferType],
          'List of Transfers bound to this Player', null: false

    field :caps, [CapType], 'List of Caps bound to this Player', null: false
    field :goals, [GoalType], 'List of Goals scored by this Player', null: false
    field :assists, [GoalType],
          'List of Goals assisted by this Player', null: false
    field :bookings, [BookingType],
          'List of Bookings for this Player', null: false

    field :current_contract, ContractType,
          'Currently active Contract bound to this Player', null: true
    field :current_injury, InjuryType,
          'Current Injury afficted by this Player', null: true
    field :current_loan, LoanType,
          'Currently active Loan bound to this Player', null: true
  end
end
