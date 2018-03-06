# == Schema Information
#
# Table name: teams
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  title        :string
#  start_date   :date
#  current_date :date
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_teams_on_user_id  (user_id)
#

class Team < ApplicationRecord
  # belongs_to :user, optional: true

  has_many :players

  validates :title, presence: true
  validates :start_date, presence: true
  validates :current_date, presence: true

  before_create :set_current_date

  def set_current_date
    self.current_date ||= self.start_date
  end
end
