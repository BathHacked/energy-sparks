class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, Activity
      can :manage, ActivityType
      can :manage, ActivityCategory
      can :manage, Alert
      can :manage, Contact
      can :manage, Calendar
      can :manage, CalendarEvent
      can :manage, Scoreboard
      can :manage, School
      can :manage, SchoolGroup
      can :manage, User
      can :manage, DataFeed
      can :manage, Meter
    elsif user.school_admin?
      can :manage, Activity, school_id: user.school_id
      can :manage, Calendar, id: user.school.try(:calendar_id)
      can [:read, :update, :manage_school_times], School, id: user.school_id
      can :manage, Alert, school_id: user.school_id
      can :manage, Contact, school_id: user.school_id
      can :manage, Meter, school_id: user.school_id
      can :read, ActivityCategory
      can :show, ActivityType
      can :show, Scoreboard
    elsif user.school_user?
      can :manage, Activity, school_id: user.school_id
      can :index, School
      can :show, School
      can :usage, School
      can :awards, School
      can :scoreboard, School
      can :suggest_activity, School
      can :read, ActivityCategory
      can :show, ActivityType
      can :show, Scoreboard
    elsif user.guest?
      can :show, Activity
      can :read, ActivityCategory
      can :show, ActivityType
      can :index, School
      can :awards, School
      can :scoreboard, School
      can :show, School
      can :usage, School
      can :index, Simulation
      can :show, Simulation
      can :show, Scoreboard
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
