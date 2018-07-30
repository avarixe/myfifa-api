# == Schema Information
#
# Table name: teams
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)
#  title        :string
#  start_date   :date
#  current_date :date
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  currency     :string           default("$")
#
# Indexes
#
#  index_teams_on_user_id  (user_id)
#

class Team < ApplicationRecord
  belongs_to :user, optional: true
  has_many :players, dependent: :destroy
  has_many :squads, dependent: :destroy
  has_many :matches, dependent: :destroy

  PERMITTED_ATTRIBUTES = %i[
    start_date
    title
    current_date
    currency
  ].freeze

  def self.permitted_create_attributes
    PERMITTED_ATTRIBUTES
  end

  def self.permitted_update_attributes
    PERMITTED_ATTRIBUTES.drop 1
  end

  validates :title, presence: true
  validates :start_date, presence: true
  validates :current_date, presence: true
  validates :currency, presence: true

  before_validation :set_start_date
  after_save :update_player_statuses

  def set_start_date
    self.current_date ||= self.start_date
  end

  def update_player_statuses
    Player.transaction do
      players
        .preload(:contracts, :loans, :injuries)
        .map(&:update_status)
    end
  end

  def as_json(options = {})
    super((options || {}).merge({
      methods: %i[time_period]
    }))
  end

  def time_period
    start_year = start_date.year
    "#{start_date.year} - #{current_date.year}"
  end

end
