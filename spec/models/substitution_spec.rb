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
  before :each do |test|
    unless test.metadata[:skip_before]
      @match = FactoryBot.create(:match)
      @player = FactoryBot.create(:player)
      FactoryBot.create :performance,
                        start: 0,
                        match: @match,
                        player: @player
      @sub = FactoryBot.create :substitution,
                               player: @player,
                               match: @match
      @replacement = @sub.replacement
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
    expect(@sub.player_name).to_not be_nil
  end

  it 'automatically sets replaced by' do
    expect(@sub.replaced_by).to_not be_nil
  end

  it 'creates a Performance record upon creation' do
    expect(@replacement.performances.count).to be == 1
    expect(@match.performances.count).to be == 2
  end

  it 'marks replaced Performance record as subbed_out' do
    expect(@player.performances.last.subbed_out).to be true
  end

  it 'removes the Performance record upon destruction' do
    @sub.destroy
    expect(@replacement.performances.count).to be == 0
    expect(@match.performances.count).to be == 1
  end

  it 'marks replaced Performance record as not subbed_out upon destruction' do
    @sub.destroy
    expect(@player.performances.last.subbed_out).to be false
  end
end
