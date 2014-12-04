class PageController < ApplicationController

  before_action :authenticate_user!, only: :guarantees

  def privacy_policy
  end

  def faq
  end

  def guarantees
  end

end
