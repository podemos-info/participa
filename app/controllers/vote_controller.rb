class VoteController < ApplicationController
  before_action :authenticate_user! 
  def create
    vote = current_user.get_or_create_vote(params[:election_id])
    redirect_to vote.url      
  end
end
