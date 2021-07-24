# frozen_string_literal: true

module Types
  module Statistics
    class TransferActivityType < BaseTypes::BaseObject
      description 'Collection of Player Arrivals and Departures'

      field :arrivals, [ContractType],
            'List of new Contracts (i.e. excluding Renewals)', null: false
      field :departures, [ContractType],
            'List of Contract expirations excluding Transfers', null: false
      field :transfers, [TransferType], 'List of Transfers', null: false
      field :loans, [LoanType], 'List of Loans', null: false
    end
  end
end
