# frozen_string_literal: true

require 'rails_helper'

describe Mutations::BookingMutations::RemoveBooking, type: :graphql do
  let(:booking) { create(:booking) }

  graphql_operation "
    mutation removeBooking($id: ID!) {
      removeBooking(id: $id) {
        booking { id }
      }
    }
  "

  graphql_variables do
    { id: booking.id }
  end

  graphql_context do
    { current_user: booking.team.user }
  end

  it 'removes the Booking' do
    execute_graphql
    expect { booking.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Booking' do
    expect(response_data.dig('removeBooking', 'booking', 'id'))
      .to be == booking.id.to_s
  end
end
