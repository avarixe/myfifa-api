class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all
    else
      can :read, :all
      can :manage, Team, user: user

      can :manage, Player, team: { user: user }
      can :manage, Injury, team: { user: user }
      can :manage, Contract, team: { user: user }
      can :manage, Loan, team: { user: user }
      can :manage, Transfer, team: { user: user }

      can :manage, Squad, team: { user: user }

      can :manage, Match, team: { user: user }
      can :manage, MatchLog, match: { team: { user: user }}

      can :manage, Goal, match: { team: { user: user }}
      can :manage, Booking, match: { team: { user: user }}
      can :manage, Substitution, match: { team: { user: user }}
      can :manage, PenaltyShootout, match: { team: { user: user }}
    end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
