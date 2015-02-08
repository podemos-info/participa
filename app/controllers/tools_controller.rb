class ToolsController < ApplicationController
  before_action :authenticate_user! 
  before_action :user_elections

  def index
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def user_elections
    @elections = Election.active.map { |e| e.has_location_for? current_user } .compact
  end

end
