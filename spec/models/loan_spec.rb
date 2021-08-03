# frozen_string_literal: true

# == Schema Information
#
# Table name: loans
#
#  id              :bigint           not null, primary key
#  addon_clause    :integer
#  destination     :string
#  ended_on        :date
#  origin          :string
#  signed_on       :date
#  started_on      :date
#  transfer_fee    :integer
#  wage_percentage :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  player_id       :bigint
#
# Indexes
#
#  index_loans_on_player_id  (player_id)
#

require 'rails_helper'

describe Loan, type: :model do
  let(:player) { create(:player) }

  it 'has a valid factory' do
    expect(create(:loan)).to be_valid
  end

  it 'requires an origin' do
    expect(build(:loan, origin: nil)).not_to be_valid
  end

  it 'requires a destination' do
    expect(build(:loan, destination: nil)).not_to be_valid
  end

  it 'has an end date after start date' do
    loan = build :loan,
                 started_on: Faker::Date.forward(days: 1),
                 ended_on: Faker::Date.backward(days: 1)
    expect(loan).not_to be_valid
  end

  it 'sets signed date to the Team current date' do
    loan = create(:loan)
    expect(loan.signed_on).to be == loan.team.currently_on
  end

  it 'changes status to loaned when loaned out' do
    create :loan,
           player: player,
           started_on: player.team.currently_on,
           origin: player.team.name
    expect(player.loaned?).to be true
  end

  it 'does not change status to loaned when loaned in' do
    create :loan,
           player: player,
           started_on: player.team.currently_on,
           destination: player.team.name
    expect(player.loaned?).not_to be true
  end

  it 'changes status when loaned Player returns to team' do
    create :loan,
           player: player,
           origin: player.team.name,
           started_on: player.team.currently_on,
           ended_on: player.team.currently_on + 1.week
    player.team.increment_date 1.week
    expect(player.reload.active?).to be true
  end

  describe 'when created for Injured Player' do
    before do
      create :injury,
             player: player,
             started_on: player.team.currently_on
      create :loan,
             player: player,
             origin: player.team.name,
             started_on: player.team.currently_on
    end

    it 'stops regarding Player as injured' do
      expect(player).not_to be_injured
    end

    it 'stops tracking injury' do
      expect(player.last_injury.ended_on).to be == player.team.currently_on
    end
  end

  describe 'when Loan-to-Buy is activated' do
    let(:loan) do
      create :loan,
             player: player,
             origin: player.team.name,
             started_on: player.team.currently_on,
             transfer_fee: Faker::Number.within(range: 50_000..10_000_000),
             addon_clause: Faker::Number.within(range: 0..25)
    end

    before do
      player.team.increment_date 1.week
      loan.update activated_buy_option: true
    end

    it 'creates a Transfer on the current Team date' do
      expect(loan.player.transfers.last.moved_on)
        .to be == loan.team.currently_on
    end

    it 'creates a Transfer inheriting its Transfer Fee' do
      expect(loan.player.transfers.last.fee).to be == loan.transfer_fee
    end

    it 'creates a Transfer inheriting Add-On Clause, Origin and Destination' do
      %i[addon_clause origin destination].each do |attribute|
        expect(loan.player.transfers.last.public_send(attribute))
          .to be == loan.public_send(attribute)
      end
    end
  end
end
