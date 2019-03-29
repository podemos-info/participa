class ToolsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_elections
  before_action :get_promoted_forms

  def index
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def user_elections
    @all_elections = Election.upcoming_finished.map { |e| e if e.has_valid_location_for?(current_user, check_created_at: false) } .compact

    @elections = @all_elections.select { |e| e.is_active? }
    @upcoming_elections = @all_elections.select { |e| e.is_upcoming? }
    @finished_elections = @all_elections.select { |e| e.recently_finished? }
  end

  def get_promoted_forms
    @promoted_forms = Page.where(promoted: true).order(priority: :desc)
  end
end