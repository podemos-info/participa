class UserVerificationsController < ApplicationController
  before_action :check_verified
  def new
    @user_verification = UserVerification.for current_user
  end

  def create
    @user_verification = UserVerification.for current_user, user_verification_params
    if @user_verification.save
      if  user_verification_params[:wants_card] == "1"
        redirect_to(edit_user_registration_path ,flash: { notice: [t('podemos.user_verification.documentation_received'),
                                                                   t('podemos.user_verification.please_check_details')].join("<br>")})
      else
        #redirect_to(create_vote_path(election_id: user_verification_params[:election_id])) and return if user_verification_params[:election_id]
        redirect_to(root_path, flash: { notice: t('podemos.user_verification.documentation_received')})
      end
    else
      render :new
    end
  end

  private

  def check_verified
    redirect_to(root_path, flash: { notice: t('podemos.user_verification.user_already_verified') }) if current_user.verified?
  end

  def user_verification_params
    params.require(:user_verification).permit(:procesed_at, :front_vatid, :back_vatid, :terms_of_service, :wants_card)
  end

end

