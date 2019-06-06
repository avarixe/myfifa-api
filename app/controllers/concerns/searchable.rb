# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  private

    def filter(data, filters = {})
      @results = data
      filters.each do |k, v|
        @results = @results.where(k => v)
      end
      @results
    end
end
