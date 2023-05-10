# frozen_string_literal: true

require 'rails_helper'

describe Mutations::BookingMutations::UpdateBooking, type: :graphql do
  let(:booking) { create(:booking) }

  graphql_operation "
    mutation updateBooking($id: ID!, $attributes: BookingAttributes!) {
      updateBooking(id: $id, attributes: $attributes) {
        booking { id }
      }
    }
  "

  graphql_variables do
    {
      id: booking.id,
      attributes: graphql_attributes_for(:booking)
    }
  end

  graphql_context do
    { current_user: booking.team.user }
  end

  it 'updates the Booking' do
    old_attributes = booking.attributes
    execute_graphql
    expect(booking.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Booking' do
    expect(response_data.dig('updateBooking', 'booking', 'id'))
      .to be == booking.id.to_s
  end
end
