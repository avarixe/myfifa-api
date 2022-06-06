# frozen_string_literal: true

require 'rails_helper'

describe Mutations::BookingMutations::RemoveBooking, type: :graphql do
  subject { described_class }

  let(:booking) { create :booking }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:booking).returning('Booking') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removeBooking($id: ID!) {
      removeBooking(id: $id) {
        booking { id }
        errors { fullMessages }
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
