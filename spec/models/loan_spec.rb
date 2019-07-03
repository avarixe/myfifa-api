# frozen_string_literal: true

# == Schema Information
#
# Table name: loans
#
#  id          :bigint(8)        not null, primary key
#  player_id   :bigint(8)
#  start_date  :date
#  end_date    :date
#  destination :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  origin      :string
#  signed_date :date
#
# Indexes
#
#  index_loans_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Loan, type: :model do
  let(:player) { FactoryBot.create(:player)}

  it "has a valid factory" do
    expect(FactoryBot.create(:loan)).to be_valid
  end

  it 'requires an origin' do
    expect(FactoryBot.build(:loan, origin: nil)).to_not be_valid
  end

  it 'requires a destination' do
    expect(
      FactoryBot.build(:loan, destination: nil)).to_not be_valid
  end

  it 'has an end date after start date' do
    expect(
      FactoryBot.build :loan,
                       start_date: Faker::Date.forward(1),
                       end_date: Faker::Date.backward(1)
    ).to_not be_valid
  end

  it 'sets signed_date to the Team current date' do
    loan = FactoryBot.create(:loan)
    expect(loan.signed_date).to be == loan.team.current_date
  end

  it 'sets end_date to the Team current date' do
    loan = FactoryBot.create :loan
    loan.team.increment_date 2.days
    loan.update returned: true
    expect(loan.end_date).to be == loan.team.current_date
  end

  it 'changes status to loaned when loaned out' do
    FactoryBot.create :loan,
                      player: player,
                      start_date: player.current_date,
                      origin: player.team.title
    expect(player.loaned?).to be true
  end

  it 'changes status when loaned Player returns to team' do
    FactoryBot.create :loan,
                      player: player,
                      origin: player.team.title
    player.loans.last.update returned: true
    expect(player.active?).to be true
  end

  it 'ends the current contract if loaned ends and player leaves' do
    player = FactoryBot.create :player
    loan = FactoryBot.create :loan,
                             player: player,
                             origin: Faker::Team.name,
                             destination: player.team.title
    player.team.increment_date 1.year
    loan.update returned: true

    expect(player.status).to be_nil
    expect(player.contracts.last.end_date).to be == player.current_date
  end

  it 'ends tracking of any injuries upon creation' do
    FactoryBot.create :injury, player: player
    FactoryBot.create :loan,
                      player: player,
                      start_date: player.current_date
    expect(player.injured?).to be false
    expect(player.injuries.last.end_date).to be == player.current_date
  end
end
