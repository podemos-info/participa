class VoteController < ApplicationController

  before_action :authenticate_user! 
  
  def create
    election = Election.find params[:election_id]
    if election.is_actived?
      @scoped_agora_election_id = election.scoped_agora_election_id current_user
    else
      redirect_to root_url, flash: {error: I18n.t('podemos.election.close_message') }
    end
  end

  def create_token
    election = Election.find params[:election_id]
    if election.is_actived?
      vote = current_user.get_or_create_vote(election.id)
      message = vote.generate_message
      render :content_type => 'text/plain', :status => :ok, :text => "#{vote.generate_hash message}/#{message}"
    else
      render :content_type => 'text/plain', :status => :service_unavailable, :text => "Error generando hash"
    end
  end
end