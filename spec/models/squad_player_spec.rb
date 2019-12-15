# frozen_string_literal: true
# == Schema Information
#
# Table name: squad_players
#
#  id         :bigint           not null, primary key
#  pos        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  player_id  :bigint
#  squad_id   :bigint
#
# Indexes
#
#  index_squad_players_on_player_id  (player_id)
#  index_squad_players_on_squad_id   (squad_id)
#

require 'rails_helper'

RSpec.describe SquadPlayer, type: :model do
  let(:squad_player) { FactoryBot.create(:squad_player) }

  it 'has a valid factory' do
    expect(squad_player).to be_valid
  end

  it 'requires a position' do
    expect(FactoryBot.build(:squad_player, pos: nil)).to_not be_valid
  end

  it 'requires a player' do
    expect(FactoryBot.build(:squad_player, player_id: nil)).to_not be_valid
  end

  it 'requires a squad' do
    expect(FactoryBot.build(:squad_player, squad_id: nil)).to_not be_valid
  end
end
