# frozen_string_literal: true

module InputObjects
  class PaginationAttributes < BaseTypes::BaseInputObject
    description 'Attributes to handle pagination'

    argument :page, Int,
             'Number of result sets to skip for this query', required: true
    argument :items_per_page, Int,
             'Number of results to return per query', required: true
    argument :sort_by, String, 'Field to sort results', required: false
    argument :sort_desc, Boolean,
             'Sort results in descending order', required: false
  end
end
