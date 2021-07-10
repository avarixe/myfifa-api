# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AddMutations do
  {
    'Team' => %w[Competition Match Player Squad],
    'Player' => %w[Contract Injury Loan Transfer],
    'Match' => %w[Booking Cap Goal Substitution],
    'Competition' => %w[Stage],
    'Stage' => %w[Fixture TableRow]
  }.each do |parent_model, models|
    models.each do |model|
      describe described_class.const_get("Add#{model}") do
        subject { described_class }

        it { is_expected.to accept_argument("#{parent_model.underscore}_id".to_sym).of_type('ID!') }
        it { is_expected.to accept_argument(:attributes).of_type("#{model}Attributes!") }
        it { is_expected.to have_a_field(model.underscore.to_sym).returning(model) }
        it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }
      end
    end
  end
end
