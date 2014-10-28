class VoteController < ApplicationController

  before_action :authenticate_user! 
  
  def create
    election = Election.find params[:election_id]
    if election.is_actived?
      vote = current_user.get_or_create_vote(election.id)
      redirect_to vote.url      
    else
      redirect_to root_url, flash: {error: I18n.t('podemos.election.close_message') }
    end
  end

end
