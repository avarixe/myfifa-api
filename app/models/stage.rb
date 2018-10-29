# frozen_string_literal: true

# == Schema Information
#
# Table name: stages
#
#  id             :bigint(8)        not null, primary key
#  competition_id :bigint(8)
#  name           :string
#  num_fixtures   :string
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
    num_fixtures
    table
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end
end
