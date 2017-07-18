class UserVerificationsController < ApplicationController
  before_action :check_valid_and_verified, only: :create

  def new
    @user_verification = UserVerification.for current_user
  end

  def create
    @user_verification = UserVerification.for current_user, user_verification_params
    # if the validation was rejected, restart it
    @user_verification.status = 0 if @user_verification.status == 3
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
  private
  def check_valid_and_verified
    redirect_to(root_path, flash: { notice: t('podemos.user_verification.user_not_valid_to_verify') }) if current_user.has_not_future_verified_elections?
    redirect_to(root_path, flash: { notice: t('podemos.user_verification.user_already_verified') }) if current_user.verified?
  end
  def user_verification_params
    params.require(:user_verification).permit(:procesed_at, :front_vatid, :back_vatid, :terms_of_service, :wants_card)
  end
end

