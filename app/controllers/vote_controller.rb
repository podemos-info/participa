class VoteController < ApplicationController
  layout "full", only: [:create]
  before_action :authenticate_user!, except: [:election_votes_count, :election_location_votes_count]

  helper_method :election, :election_location

  def send_sms_check
    if current_user.send_sms_check!
      redirect_to sms_check_vote_path(params[:election_id]), flash: { info: "El código ha sido enviado a tu teléfono móvil." }
    else
      redirect_to sms_check_vote_path(params[:election_id]), flash: { error: "Ya se ha solicitado un código recientemente." }
    end
  end

  def sms_check
  end

  def create
    return back_to_home unless election.nvotes? && check_open_election && check_valid_user && check_valid_location
    return redirect_to(new_user_verification_path(params[:election_id])) unless check_verification

    if election.requires_sms_check?
      if params[:sms_check_token].nil?
        redirect_to sms_check_vote_path(params[:election_id])
      elsif !current_user.valid_sms_check? params[:sms_check_token]
        redirect_to sms_check_vote_path(params[:election_id]), flash: { error: "El código introducido es incorrecto." }
      end
    end
    @scoped_agora_election_id = election.scoped_agora_election_id current_user
  end

  def create_token
    return send_to_home unless election.nvotes? && check_open_election && check_valid_user && check_valid_location && check_verification

    vote = current_user.get_or_create_vote(election.id)
    message = vote.generate_message
    render content_type: 'text/plain', status: :ok, text: "#{vote.generate_hash message}/#{message}"
  end

  def check
    return back_to_home unless check_valid_user && check_valid_location && check_verification

    @scoped_agora_election_id = election.scoped_agora_election_id current_user
  end

  def election_votes_count
    return back_to_home unless election&.counter_token == params[:token]

    render 'votes_count', layout: 'minimal', locals: { votes: election.valid_votes_count }
  end

  def election_location_votes_count
    return back_to_home unless election_location&.counter_token == params[:token]

    render 'votes_count', layout: 'minimal', locals: { votes: election_location.valid_votes_count }
  end

  def paper_vote
    return back_to_home unless election&.paper? && election_location&.paper_token == params[:token]
    return back_to_home unless check_open_election

    can_vote = false
    if params[:validation_token]
      user = paper_voters.find(params[:user_id])
      return redirect_to(:back) unless check_validation_token(user, params[:validation_token])

      if election.votes.create(user_id: user.id, paper_authority: current_user)
        flash.now[:notice] = "El voto ha sido registrado."
      else
        flash.now[:error] = "No se ha podido registrar el voto. Inténtalo nuevamente o consulta con la persona que administra el sistema."
      end
    elsif params[:document_vatid] && params[:document_type]
      user = paper_voters.where("lower(document_vatid) = ?", params[:document_vatid].downcase).find_by(document_type: params[:document_type])
      if user
        can_vote = check_valid_user(user) && check_valid_location(user, [election_location]) && check_verification(user) && check_not_voted(user)
        validation_token = validation_token_for(user)

        flash.each { |type, message| flash.now[:error] = message }
        flash.discard
      else
        flash.now[:error] = "No se han encontrado usuarios con el documento dado."
      end
    end

    render 'paper_vote', locals: { election: election, user: user, can_vote: can_vote, validation_token: validation_token }
  end

  private

  def election
    @election ||= Election.find(params[:election_id])
  end

  def election_location
    @election_location ||= election.election_locations.find(params[:election_location_id])
  end

  def paper_voters
    User.confirmed.not_banned
  end

  def back_to_home
    redirect_to root_path
  end

  def send_to_home
    render content_type: 'text/plain', status: :gone, text: root_url
  end

  def check_open_election
    return true if election.is_active?

    flash[:error] = "Ha llegado la fecha límite para votar. La votación está cerrada."
    false
  end

  def check_valid_user(user = current_user)
    return true if election.has_valid_user_created_at? user

    flash[:error] = "Tu usuario no tiene la antigüedad requerida para participar en esta votación."
    false
  end

  def check_valid_location(user = current_user, valid_locations = nil)
    return true if election.has_valid_location_for?(user, valid_locations: valid_locations)

    flash[:error] = "No puedes participar en esta votación."
    false
  end

  def check_verification(user = current_user)
    return true unless election.requires_vatid_check? && !user.pass_vatid_check?

    flash[:notice] = "Para esta votación es necesario que verifiques tu identidad"
    false
  end

  def check_not_voted(user = current_user)
    return true unless user.has_already_voted_in(election.id)

    flash[:error] = "Esta persona ya ha emitido su voto en esta votación."
    false
  end

  def check_validation_token(user, received_token)
    return true if validation_token_for(user) == received_token

    flash[:error] = "Ha ocurrido un error al comprobar que el usuario puede votar, inténtalo nuevamente."
    false
  end

  def validation_token_for(user)
    election.generate_access_token("#{user.id} #{election_location.id} #{Date.today.iso8601}")
  end
end
