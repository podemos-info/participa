class VoteController < ApplicationController
  layout "full", only: [:create]
  before_action :authenticate_user!, except: [:election_votes_count, :election_location_votes_count]

  helper_method :election, :election_location, :paper_vote_user, :validation_token_for_paper_vote_user, :paper_authority_votes_count

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
    return back_to_home unless check_open_election && check_paper_authority? && election&.paper? &&
                               election_location&.paper_token == params[:token]
    tracking = Logger.new(File.join(Rails.root, "log", "paper_authorities.log"))

    can_vote = false
    if params[:validation_token]
      return redirect_to(:back) unless paper_vote_user? && check_validation_token(params[:validation_token])

      tracking.info "** #{current_user.id} #{current_user.full_name} ** VOTE: #{paper_vote_user.id}"

      save_paper_vote_for_user(paper_vote_user)
      return redirect_to(:back)
    elsif params[:document_vatid] && params[:document_type]
      tracking.info "** #{current_user.id} #{current_user.full_name} ** QUERY: #{params[:document_type]} #{params[:document_vatid]}"

      return redirect_to(:back) unless paper_vote_user? && check_valid_user(paper_vote_user) &&
                                       check_valid_location(paper_vote_user, [election_location]) &&
                                       check_verification(paper_vote_user) && check_not_voted(paper_vote_user)
    end

    render 'paper_vote', locals: { can_vote: can_vote }
  end

  private

  def election
    @election ||= Election.find(params[:election_id])
  end

  def election_location
    @election_location ||= election.election_locations.find(params[:election_location_id])
  end

  def paper_authority_votes_count
    @paper_authority_votes_count ||= current_user.paper_authority_votes.where(election: election).count
  end

  def paper_vote_user
    @paper_vote_user ||= if params[:validation_token]
                           paper_voters.find(params[:user_id])
                         elsif params[:document_vatid] && params[:document_type]
                           paper_voters.where("lower(document_vatid) = ?", params[:document_vatid].downcase).find_by(document_type: params[:document_type])
                         end
  end

  def validation_token_for_paper_vote_user
    @validation_token_for_paper_vote_user ||= election.generate_access_token("#{paper_vote_user.id} #{election_location.id} #{Date.today.iso8601}")
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

  def save_paper_vote_for_user(user)
    if election.votes.create(user_id: user.id, paper_authority: current_user)
      flash[:notice] = "El voto ha sido registrado."
    else
      flash[:error] = "No se ha podido registrar el voto. Inténtalo nuevamente o consulta con la persona que administra el sistema."
    end
  end

  def paper_vote_user?
    return true if paper_vote_user

    flash[:error] = "No se han encontrado usuarios con el documento dado."
    false
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

    flash[:error] = I18n.t('podemos.election.no_location')
    false
  end

  def check_verification(user = current_user)
    return true unless election.requires_vatid_check? && !user.pass_vatid_check?

    flash[:notice] = "Para esta votación es necesario que verifiques tu identidad"
    false
  end

  def check_paper_authority?
    current_user.admin? || current_user.paper_authority?
  end

  def check_not_voted(user = current_user)
    return true unless user.has_already_voted_in(election.id)

    flash[:error] = t("podemos.election.already_voted")
    false
  end

  def check_validation_token(received_token)
    return true if validation_token_for_paper_vote_user == received_token

    flash[:error] = t("podemos.election.token_error")
    false
  end
end
