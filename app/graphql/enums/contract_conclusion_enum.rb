# frozen_string_literal: true

module Enums
  class ContractConclusionEnum < BaseTypes::BaseEnum
    graphql_name 'ContractConclusion'
    description 'How a Contract was Ended'

    value 'Renewed', 'Contract was renewed by another Contract'
    value 'Transferred', 'Contract was ended by a Transfer to another Team'
    value 'Expired', 'Contract had expired'
    value 'Released', 'Player was released from the Team'
    value 'Retired', 'Player retired their career at the end of the Season'
  end
end
