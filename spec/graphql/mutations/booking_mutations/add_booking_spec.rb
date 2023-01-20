# frozen_string_literal: true

require 'rails_helper'

describe Mutations::BookingMutations::AddBooking, type: :graphql do
  subject { described_class }

  let(:match) { create(:match) }

  it { is_expected.to accept_argument(:match_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('BookingAttributes!') }
  it { is_expected.to have_a_field(:booking).returning('Booking') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation addBooking($matchId: ID!, $attributes: BookingAttributes!) {
      addBooking(matchId: $matchId, attributes: $attributes) {
        booking { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      matchId: match.id,
      attributes: graphql_attributes_for(:booking).merge(
        playerId: create(:player, team: match.team).id
      )
    }
  end

  graphql_context do
    { current_user: match.team.user }
  end

  it 'creates a Booking for the Match' do
    record_id = response_data.dig('addBooking', 'booking', 'id')
    expect(match.reload.bookings.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Booking' do
    expect(response_data.dig('addBooking', 'booking', 'id'))
      .to be_present
  end
end
