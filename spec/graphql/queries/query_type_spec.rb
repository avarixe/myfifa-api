# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  subject { described_class }

  %w[
    Team
    Player
    Match
    Squad
    Competition
  ].each do |model|
    records = model.underscore.pluralize.to_sym
    record = model.underscore.to_sym

    it { is_expected.to have_field(records).of_type("[#{model}!]!") }
    it { is_expected.to have_field(record).of_type("#{model}!") }

    describe record.to_s do
      subject(:field) { described_class.fields[record.to_s] }

      it 'requires an ID' do
        expect(field).to accept_argument(:id).of_type('ID!')
      end
    end
  end
end
