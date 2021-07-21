# frozen_string_literal: true

module Types
  module Statistics
    class TransferActivityType < BaseObject
      field :arrivals, [Myfifa::ContractType], null: false
      field :departures, [Myfifa::ContractType], null: false
      field :transfers, [Myfifa::TransferType], null: false
      field :loans, [Myfifa::LoanType], null: false
    end
  end
end
