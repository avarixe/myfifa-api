# frozen_string_literal: true

require 'rails_helper'

describe TransferActivityCompiler do
  it 'requires a team' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  describe 'result' do
    sample_set = (1..3).map do |season|
      {
        season:,
        arrivals: Faker::Number.within(range: 0..3),
        departures: Faker::Number.within(range: 0..3),
        transfers: Faker::Number.within(range: 0..3),
        loans: Faker::Number.within(range: 0..3)
      }
    end

    before :all do
      team = create(:team)
      sample_set.each do |set|
        set[:arrivals].times do
          player = create(:player, team:, contracts_count: 0)
          create(:contract,
                 player:,
                 signed_on: team.currently_on + set[:season].years,
                 started_on: team.currently_on + set[:season].years,
                 ended_on: team.currently_on + 10.years)
        end
        set[:departures].times do
          player = create(:player, team:, contracts_count: 0)
          create(:contract,
                 player:,
                 signed_on: team.currently_on,
                 ended_on: team.end_of_season(set[:season]))
        end
        set[:transfers].times do
          player = create(:player, team:, contracts_count: 0)
          create(:contract,
                 player:,
                 signed_on: team.currently_on,
                 ended_on: team.currently_on + 10.years)
          create(:transfer,
                 player:,
                 origin: team.name,
                 signed_on: team.currently_on + set[:season].years,
                 moved_on: team.currently_on + set[:season].years)
        end
        set[:loans].times do
          player = create(:player, team:, contracts_count: 0)
          create(:contract,
                 player:,
                 signed_on: team.currently_on,
                 ended_on: team.currently_on + 10.years)
          create(:loan,
                 player:,
                 origin: team.name,
                 signed_on: team.currently_on + set[:season].years,
                 started_on: team.currently_on + set[:season].years,
                 ended_on: team.end_of_season(set[:season]))
        end
      end
      team.increment_date 5.years
    end

    after :all do
      User.last.destroy
    end

    (1..3).each do |season|
      describe "if Season #{season} provided" do
        let(:compiler) { described_class.new(team: Team.last, season:) }
        let(:set) { sample_set[season - 1] }

        it "returns arriving Contracts in Season #{season}" do
          expect(compiler.results[:arrivals].count).to eq set[:arrivals]
        end

        it "returns departing Contracts in Season #{season}" do
          expect(compiler.results[:departures].count).to eq set[:departures]
        end

        it "returns Transfers in Season #{season}" do
          expect(compiler.results[:transfers].count).to eq set[:transfers]
        end

        it "returns Loans in Season #{season}" do
          expect(compiler.results[:loans].count).to eq set[:loans]
        end
      end
    end

    describe 'if Season not provided' do
      let(:compiler) { described_class.new(team: Team.last) }

      it 'returns all arriving Contracts' do
        Contract.where(previous_id: nil).find_each do |contract|
          expect(compiler.results[:arrivals]).to include(contract)
        end
      end

      it 'returns all departing Contracts' do
        Contract.where.not(conclusion: [nil, 'Renewed', 'Transferred']).find_each do |contract|
          expect(compiler.results[:departures]).to include(contract)
        end
      end

      it 'returns all Transfers' do
        Transfer.find_each do |transfer|
          expect(compiler.results[:transfers]).to include(transfer)
        end
      end

      it 'returns all Loans' do
        Loan.find_each do |loan|
          expect(compiler.results[:loans]).to include(loan)
        end
      end
    end
  end
end
