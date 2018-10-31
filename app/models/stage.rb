# frozen_string_literal: true

# == Schema Information
#
# Table name: stages
#
#  id             :bigint(8)        not null, primary key
#  competition_id :bigint(8)
#  name           :string
#  num_teams      :integer
#  num_fixtures   :integer
#  table          :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_stages_on_competition_id  (competition_id)
#

class Stage < ApplicationRecord
  belongs_to :competition
  has_many :table_rows, dependent: :destroy
  has_many :fixtures, dependent: :destroy

  PERMITTED_ATTRIBUTES = %i[
    name
    num_teams
    num_fixtures
    table
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :name, presence: true
  validates :num_teams, numericality: { greater_than: 0 }
  validates :num_fixtures, numericality: { greater_than: 0 }

  after_create :create_items

  def create_items
    if table?
      num_teams.times { table_rows.create! }
    else
      num_fixtures.times { fixtures.create! }
    end
  end

  delegate :team, to: :competition

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] += %i[fixtures table_rows]
    super
  end
end
