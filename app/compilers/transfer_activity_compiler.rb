# frozen_string_literal: true

class TransferActivityCompiler
  attr_accessor :team, :season

  def initialize(team:, season: nil)
    @team = team
    @season = season
  end

  def results
    @results ||= {
      arrivals:,
      departures:,
      transfers:,
      loans:
    }
  end

  private

    def base_query(model)
      model
        .joins(:player)
        .where(players: { team_id: team.id })
        .where.not(signed_on: nil)
    end

    def arrivals
      contracts = base_query(Contract).where(previous_id: nil)
      if season
        contracts.where(started_on: season_start..season_end)
      else
        contracts
      end
    end

    def departures
      contracts = base_query(Contract).where.not(
        conclusion: [nil, 'Renewed', 'Transferred']
      )
      if season
        contracts.where ended_on: (season_start + 1.day)..(season_end + 1.day)
      else
        contracts
      end
    end

    def transfers
      if season
        base_query(Transfer).where(moved_on: season_start..season_end)
      else
        base_query Transfer
      end
    end

    def loans
      if season
        base_query(Loan).where(
          started_on: nil..season_end,
          ended_on: season_start..
        )
      else
        base_query Loan
      end
    end

    def season_start
      team.started_on + season.years
    end

    def season_end
      team.end_of_season(season)
    end
end
