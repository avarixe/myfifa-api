# frozen_string_literal: true

module InputObjects
  class InjuryDurationAttributes < BaseTypes::BaseInputObject
    description 'Attributes to specify the duration of a Injury record'

    argument :length, Integer, 'Length of the provided timespan', required: true
    argument :timespan, String, 'Days/Weeks/Months/Years', required: true
  end
end
