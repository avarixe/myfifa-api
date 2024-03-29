# frozen_string_literal: true

require 'rails_helper'

describe Mutations::BookingMutations::AddBooking, type: :graphql do
  let(:match) { create(:match) }
  let!(:user) { match.team.user }

  graphql_operation "
    mutation addBooking($matchId: ID!, $attributes: BookingAttributes!) {
      addBooking(matchId: $matchId, attributes: $attributes) {
        booking { id }
      }
    }
  "

  graphql_variables do
    {
      matchId: match.id,
      attributes: graphql_attributes_for(:booking).merge(
        capId: create(:cap, match:, player: create(:player, team: match.team)).id
      )
    }
  end

  graphql_context do
    { current_user: user }
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
