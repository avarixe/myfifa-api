# frozen_string_literal: true

# == Schema Information
#
# Table name: table_rows
#
#  id            :bigint(8)        not null, primary key
#  stage_id      :bigint(8)
#  name          :string
#  wins          :integer
#  draws         :integer
#  losses        :integer
#  goals_for     :integer
#  goals_against :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_table_rows_on_stage_id  (stage_id)
#

class TableRow < ApplicationRecord
  belongs_to :stage

  PERMITTED_ATTRIBUTES = %i[
    name
    wins
    draws
    losses
    goals_for
    goals_against
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end
end
