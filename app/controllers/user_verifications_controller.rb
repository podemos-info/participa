class UserVerificationsController < ApplicationController
  before_action :check_valid_and_verified, only: [:new, :create]

  def new
    @user_verification = UserVerification.for current_user
  end

  def create
    @user_verification = UserVerification.for current_user, user_verification_params
    # if the validation was rejected, restart it
    @user_verification.status = UserVerification.statuses[:pending] if @user_verification.rejected?
    # @user_verification.status = UserVerification.statuses[:accepted_by_email] if current_user.photos_unnecessary?
    if @user_verification.save
      if @user_verification.wants_card
        redirect_to(edit_user_registration_path ,flash: { notice: [t('podemos.user_verification.documentation_received'), t('podemos.user_verification.please_check_details')].join("<br>")})
      else
        redirect_to(create_vote_path(election_id: params[:election_id])) and return if params[:election_id]
        redirect_to(root_path, flash: { notice: t('podemos.user_verification.documentation_received')})
      end
    else
      render :new
    end
  end
  def download_image
    verification = UserVerification.find(params[:id])
    type= params[:attachment]
     case type
       when "front_vatid"
         send_file verification.front_vatid.path(:thumb)
       when "back_vatid"
         send_file verification.back_vatid.path(:thumb)
     end
  end

  def report
    filas=[]
    @report = {autonomias: {}, provincias: {} }
    UserVerification.all.each do |v|
      a = v.user.vote_autonomy_name
      p = v.user.vote_province_name
      s = v.status
      filas.push([a, p, s])
      @report[:autonomias][a] = @report[:autonomias][a] || {pendientes: 0, verificados: 0, verificados_por_email: 0,con_problemas: 0, rechazados: 0, total: 0}
      @report[:provincias][p] = @report[:provincias][p] || {pendientes: 0, verificados: 0, verificados_por_email: 0, con_problemas: 0, rechazados: 0, total: 0}
      case UserVerification.statuses[v.status]
        when UserVerification.statuses[:pending]
          @report[:autonomias][a][:pendientes] += 1
          @report[:provincias][p][:pendientes] += 1
        when UserVerification.statuses[:accepted]
          @report[:autonomias][a][:verificados] += 1
          @report[:provincias][p][:verificados] += 1
        when UserVerification.statuses[:accepted_by_email]
          @report[:autonomias][a][:verificados_por_email] += 1
          @report[:provincias][p][:verificados_por_email] += 1
        when UserVerification.statuses[:issues]
          @report[:autonomias][a][:con_problemas] += 1
          @report[:provincias][p][:con_problemas] += 1
        when UserVerification.statuses[:rejected]
          @report[:autonomias][a][:rechazados] += 1
          @report[:provincias][p][:rechazados] += 1
      end

      @report[:autonomias][a][:total] += 1
      @report[:provincias][p][:total] += 1
    end
    @report
  end
  private
  def check_valid_and_verified
    if current_user.has_not_future_verified_elections?
      redirect_to(root_path, flash: { notice: t('podemos.user_verification.user_not_valid_to_verify') })
    elsif current_user.verified? && current_user.photos_necessary?
      redirect_to(root_path, flash: { notice: t('podemos.user_verification.user_already_verified') })
    end
  end
  def user_verification_params
    params.require(:user_verification).permit(:procesed_at, :front_vatid, :back_vatid, :terms_of_service, :wants_card)
  end
end

