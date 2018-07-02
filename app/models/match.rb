# == Schema Information
#
# Table name: matches
#
#  id          :integer          not null, primary key
#  team_id     :integer
#  home        :string
#  away        :string
#  competition :string
#  date_played :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_matches_on_team_id  (team_id)
#

class Match < ApplicationRecord
  belongs_to :team

  %w[
    line_ups
    goals
    assists
    own_goals
    sub_ins
    sub_outs
    injuries
    bookings
  ].each do |event|
    has_many event.to_sym,
             class_name: "Event::#{event.singularize.titleize.tr(' ', '')}",
             inverse_of: :match
  end
  has_one :penalty_shootout,
          class_name: "Event::PenaltyShootout",
          inverse_of: :match

  PERMITTED_ATTRIBUTES = %i[
    home
    away
    competition
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  ################
  #  VALIDATION  #
  ################

  validates :home, presence: true
  validates :away, presence: true
  validates :competition, presence: true
  validates :date_played, presence: true

  ##############
  #  CALLBACK  #
  ##############

  after_initialize :set_signed_date

  def set_signed_date
    self.date_played ||= team.current_date
  end

  ##############
  #  MUTATORS  #
  ##############

  ###############
  #  ACCESSORS  #
  ###############

  def score
    "#{home_score} - #{away_score}"
  end

  def home_score
    score = goals.home.count + own_goals.away.count
    if penalty_shootout
      score += " (#{penalty_shootout.home_score})"
    end
    score
  end

  def away_score
    score = goals.away.count + own_goals.home.count
    if penalty_shootout
      score += " (#{penalty_shootout.away_score})"
    end
    score
  end

  def as_json(options = {})
    super((options || {}).merge({
      methods: %i[ score ]
    }))
  end

end
