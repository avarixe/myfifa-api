class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all
    else
      can :read, :all
      can :manage, Team, user: user
      can :manage, team_permissions, team: { user: user }
      can :manage, player_permissions, player: { team: { user: user } }
      can :manage, match_permissions, match: { team: { user: user } }
    end
  end

  def team_permissions
    [
      Player,
      Squad,
      Match
    ]
  end

  def player_permissions
    [
      Injury,
      Contract,
      Loan,
      Transfer
    ]
  end

  def match_permissions
    [
      Performance,
      Goal,
      Booking,
      Substitution,
      PenaltyShootout
    ]
  end
end
