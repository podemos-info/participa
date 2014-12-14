class PageController < ApplicationController

  before_action :authenticate_user!, only: [:participation_teams]

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

  def participation_teams
  end

end
