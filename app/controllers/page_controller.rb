class PageController < ApplicationController

  before_action :authenticate_user!, only: [:participation_teams, :candidate_register]

  def privacy_policy
  end

  def faq
  end

  def guarantees
  end

  def guarantees_conflict
  end

  def guarantees_compliance
  end

  def guarantees_ethic
  end

  def circles_validation
  end

  def participation_teams
  end

  def candidate_register
  end

  def hospitality
  end

  def town_legal
  end
end
