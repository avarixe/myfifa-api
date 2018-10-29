# == Schema Information
#
# Table name: competitions
#
#  id         :bigint(8)        not null, primary key
#  team_id    :bigint(8)
#  season     :integer
#  name       :string
#  champion   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_competitions_on_season   (season)
#  index_competitions_on_team_id  (team_id)
#

require 'rails_helper'

RSpec.describe Competition, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
