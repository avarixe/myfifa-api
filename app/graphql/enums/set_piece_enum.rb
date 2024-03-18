# frozen_string_literal: true

module Enums
  class SetPieceEnum < BaseTypes::BaseEnum
    graphql_name 'SetPiece'
    description 'Set Pieces utilized by Players to score goals'

    value 'PK', 'Penalty Kick'
    value 'CK', 'Corner Kick'
    value 'DFK', 'Direct Free Kick'
    value 'IFK', 'Indirect Free Kick'
  end
end
