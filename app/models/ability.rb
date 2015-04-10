class Ability
  include CanCan::Ability

  def initialize(user)
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)
    if user.is_admin?
      can :manage, :all
      can :manage, Notice
      can :manage, Resque
      can :manage, Report
      can :manage, ActiveAdmin
      can :admin, User
      can :admin, MicrocreditLoan

      if not user.superadmin?
        cannot :manage, Election
        cannot :manage, Notice
        cannot :manage, ReportGroup
        cannot :manage, SpamFilter
      end
    else
      cannot :manage, :all
      cannot :manage, Resque
      cannot :manage, ActiveAdmin

      can [:read], MicrocreditLoan if user.microcredits_admin?
      can [:show, :update], User, id: user.id
      can :show, Notice

      cannot :admin, :all
    end

  end
end
