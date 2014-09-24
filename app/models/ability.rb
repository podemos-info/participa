class Ability
  include CanCan::Ability

  def initialize(user)
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)
    if user.is_admin?
      can :manage, :all
      can :manage, Notice
      can :manage, Resque
      can :manage, ActiveAdmin
    else
      can [:show, :update], User, id: user.id
      cannot :manage, Resque
      cannot :manage, ActiveAdmin
      can :show, Notice
    end

  end
end
