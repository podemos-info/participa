class VoteController < ApplicationController
  layout "full", only: [:create]
  before_action :authenticate_user!, except: [:election_votes_count, :election_location_votes_count]
  
  def send_sms_check
    if current_user.send_sms_check!
      redirect_to sms_check_vote_path(params[:election_id]), flash: {info: "El código ha sido enviado a tu teléfono móvil." }
    else
      redirect_to sms_check_vote_path(params[:election_id]), flash: {error: "Ya se ha solicitado un código recientemente." }
    end
  end

  def sms_check
    @election_id = params[:election_id]
    @election = Election.find @election_id
  end

  def create
    @election = Election.find params[:election_id]
    redirect_to(root_path, flash: {error: "Ha llegado la fecha límite para votar. La votación está cerrada." }) and return unless @election.is_active? 
    redirect_to(root_path, flash: {error: "Tu usuario no tiene la antigüedad requerida para participar en esta votación."}) and return unless @election.has_valid_user_created_at? current_user
    redirect_to(root_path, flash: {error: "No hay votaciones en tu municipio." }) and return unless @election.has_valid_location_for? current_user

    redirect_to(new_user_verification_path(params[:election_id])) and return if @election.requires_vatid_check? && !current_user.pass_vatid_check?

    if @election.requires_sms_check?
      if params[:sms_check_token].nil?
        redirect_to sms_check_vote_path(params[:election_id])
      elsif !current_user.valid_sms_check? params[:sms_check_token]
        redirect_to sms_check_vote_path(params[:election_id]), flash: {error: "El código introducido es incorrecto."}
      end
    end
    @scoped_agora_election_id = @election.scoped_agora_election_id current_user
  end

  def create_token
    election = Election.find params[:election_id]
    if election.is_active?
      if election.has_valid_user_created_at? current_user
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

  def election_votes_count
    @election = Election.find(params[:election_id])
    redirect_to root_url and return if !@election.validate_hash(params[:hash])
    render 'votes_count', layout: 'minimal', locals: { votes: @election.valid_votes_count }
  end

  def election_location_votes_count
    @election_location = ElectionLocation.find(params[:election_location_id])
    redirect_to root_url and return if !@election_location.validate_hash(params[:hash])
    render 'votes_count', layout: 'minimal', locals: { votes: @election_location.valid_votes_count }
  end
end
