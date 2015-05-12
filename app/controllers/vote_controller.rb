class VoteController < ApplicationController
  layout "full", only: [:create]
  before_action :authenticate_user! 
  
  def create
    @election = Election.find params[:election_id]
    if @election.is_active? 
      if @election.has_valid_user_created_at? current_user
        if @election.has_valid_location_for? current_user
          @scoped_agora_election_id = @election.scoped_agora_election_id current_user
        else
          redirect_to root_url, flash: {error: "No hay votaciones en tu municipio." }
        end
      else
        redirect_to root_url, flash: {error: "Tu usuario no tiene la antigüedad requerida para participar en esta votación."}
      end
    else
      redirect_to root_url, flash: {error: "Ha llegado la fecha límite para votar. La votación está cerrada." }
    end
  end

  def create_token
    election = Election.find params[:election_id]
    if election.is_active?
      if @election.has_valid_user_created_at? current_user
        if election.has_valid_location_for? current_user
          vote = current_user.get_or_create_vote(election.id)
          message = vote.generate_message
          render :content_type => 'text/plain', :status => :ok, :text => "#{vote.generate_hash message}/#{message}"
        else
          flash[:error] = "No hay votaciones en tu municipio."
          render :content_type => 'text/plain', :status => :gone, :text => root_url
        end
      else
        flash[:error] = "Tu usuario no tiene la antigüedad requerida para participar en esta votación."
        render :content_type => 'text/plain', :status => :gone, :text => root_url
      end
    else
      flash[:error] = "Ha llegado la fecha límite para votar. La votación está cerrada."
      render :content_type => 'text/plain', :status => :gone, :text => root_url
    end
  end

  def check
    @election = Election.find params[:election_id]
    if @election.has_valid_location_for? current_user
      @scoped_agora_election_id = @election.scoped_agora_election_id current_user
    else
      redirect_to root_url, flash: {error: "No hay votaciones en tu municipio." }
    end
  end
end
