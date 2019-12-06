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
                               player_id: @player.id,
                               replacement_id: @replacement.id,
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

  it 'requires a Cap for the replaced player'

  it 'automatically sets player name' do
    expect(@sub.player_name).to be == @sub.player.name
  end

  it 'automatically sets replaced by' do
    expect(@sub.replaced_by).to be == @sub.replacement.name
  end

  it 'creates a Cap record upon creation' do
    expect(@replacement.caps.count).to be == 1
    expect(@match.caps.count).to be == 2
  end

  it 'marks replaced Cap record as subbed_out' do
    expect(@player.caps.last.subbed_out).to be true
  end

  describe 'in extra time' do
    before :each do
      @match.substitutions.map(&:destroy)
      @match.caps.delete_all
      @match.update(extra_time: true)
      @player = FactoryBot.create :player, team: @team
      @replacement = FactoryBot.create :player, team: @team
      FactoryBot.create :cap, start: 0, match: @match, player: @player
      @sub = FactoryBot.create :substitution,
                               player_id: @player.id,
                               replacement_id: @replacement.id,
                               match: @match,
                               minute: Faker::Number.between(from: 91, to: 120)
    end

    it 'creates a Cap record upon creation' do
      expect(@replacement.caps.count).to be == 1
      expect(@match.caps.count).to be == 2
    end
  end

  describe 'when destroyed' do
    before :each do
      @sub.destroy
    end

    it 'removes the Cap record' do
      expect(@replacement.caps.count).to be == 0
      expect(@match.caps.count).to be == 1
    end

    it 'marks replaced Cap record as not subbed_out' do
      expect(@player.caps.last.subbed_out).to be false
    end
  end

  describe 'upon player_id change' do
    before :each do
      @player2 = FactoryBot.create :player, team: @team
      pos2 = Cap::POSITIONS[Cap::POSITIONS.index(@player.caps.last.pos) - 1]
      FactoryBot.create :cap, start: 0, match: @match, player: @player2, pos: pos2
      @sub.update(player_id: @player2.id)
    end

    it 'automatically changes player name' do
      expect(@sub.player_name).to be == @player2.name
    end

    it 'marks replaced Cap as not subbed_out' do
      cap = Cap.find_by(match_id: @match.id, player_id: @player.id)
      expect(cap.subbed_out?).to be_falsey
    end

    it 'marks new Player Cap as subbed_out' do
      cap = Cap.find_by(match_id: @match.id, player_id: @player2.id)
      expect(cap.subbed_out?).to be true
    end
  end

  describe 'upon replacement_id change' do
    before :each do
      @player2 = FactoryBot.create :player, team: @team
      @sub.update(replacement_id: @player2.id)
    end

    it 'automatically changes replaced by' do
      expect(@sub.replaced_by).to be == @player2.name
    end

    it 'detaches from old Player Cap' do
      cap = Cap.find_by(match_id: @match.id, player_id: @replacement.id)
      expect(cap).to be_nil
    end

    it 'attaches to new Player Cap' do
      cap = Cap.find_by(match_id: @match.id, player_id: @player2.id)
      expect(cap).to_not be_nil
    end
  end

end
