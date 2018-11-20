# frozen_string_literal: true

# == Schema Information
#
# Table name: substitutions
#
#  id             :bigint(8)        not null, primary key
#  match_id       :bigint(8)
#  minute         :integer
#  player_id      :bigint(8)
#  replacement_id :bigint(8)
#  injury         :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  player_name    :string
#  replaced_by    :string
#
# Indexes
#
#  index_substitutions_on_match_id        (match_id)
#  index_substitutions_on_player_id       (player_id)
#  index_substitutions_on_replacement_id  (replacement_id)
#

require 'rails_helper'

RSpec.describe Substitution, type: :model do
  before do |test|
    unless test.metadata[:skip_before]
      @team = FactoryBot.create :team
      @match = FactoryBot.create :match, team: @team
      @player = FactoryBot.create :player, team: @team
      @replacement = FactoryBot.create :player, team: @team
      FactoryBot.create :cap, start: 0, match: @match, player: @player
      @sub = FactoryBot.create :substitution,
                               player: @player,
                               replacement: @replacement,
                               match: @match
    end
  end

  it 'has a valid factory', :skip_before do
    expect(FactoryBot.create(:substitution)).to be_valid
  end

  it 'requires a player', :skip_before do
    expect(FactoryBot.build(:substitution, player: nil)).to_not be_valid
  end

  it 'requires a match', :skip_before do
    expect(FactoryBot.build(:substitution, match: nil)).to_not be_valid
  end

  it 'requires a minute', :skip_before do
    expect(FactoryBot.build(:substitution, minute: nil)).to_not be_valid
  end

  it 'requires a replacement', :skip_before do
    expect(FactoryBot.build(:substitution, replacement: nil)).to_not be_valid
  end

  it 'automatically sets player name' do
    expect(@sub.player_name).to be == @sub.player.name
  end

  it 'automatically sets replaced by' do
    expect(@sub.replaced_by).to be == @sub.replacement.name
  end

  it 'creates a Performance record upon creation' do
    expect(@replacement.caps.count).to be == 1
    expect(@match.caps.count).to be == 2
  end

  it 'marks replaced Performance record as subbed_out' do
    expect(@player.caps.last.subbed_out).to be true
  end

  it 'removes the Performance record upon destruction' do
    @sub.destroy
    expect(@replacement.caps.count).to be == 0
    expect(@match.caps.count).to be == 1
  end

  it 'marks replaced Performance record as not subbed_out upon destruction' do
    @sub.destroy
    expect(@player.caps.last.subbed_out).to be false
  end
end
