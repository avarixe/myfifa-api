# frozen_string_literal: true

module Types
  module Statistics
    class TransferActivityType < BaseObject
      description 'Collection of Player Arrivals and Departures'

      field :arrivals, [Myfifa::ContractType],
            'List of new Contracts (i.e. excluding Renewals)', null: false
      field :departures, [Myfifa::ContractType],
            'List of Contract expirations excluding Transfers', null: false
      field :transfers, [Myfifa::TransferType], 'List of Transfers', null: false
      field :loans, [Myfifa::LoanType], 'List of Loans', null: false
    end
  end
end
