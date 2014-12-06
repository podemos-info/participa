class PageController < ApplicationController

  before_action :authenticate_user!, only: [ :guarantees_conflict, :guarantees_compliance ]

  def privacy_policy
  end

  def faq
  end

  def guarantees_conflict
  end

  def guarantees_compliance
  end

end
