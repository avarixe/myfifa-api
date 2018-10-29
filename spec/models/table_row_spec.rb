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

require 'rails_helper'

RSpec.describe TableRow, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
