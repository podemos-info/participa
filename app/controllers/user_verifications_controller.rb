class UserVerificationsController < ApplicationController
  before_action :check_valid_and_verified

  def new
    @user_verification = UserVerification.for current_user
  end

  def create
    @user_verification = UserVerification.for current_user, user_verification_params
    if @user_verification.save
      if params[:wants_card].present?
        redirect_to(edit_user_registration_path ,flash: { notice: [t('podemos.user_verification.documentation_received'),
                                                                   t('podemos.user_verification.please_check_details')].join("<br>")})
      else
        redirect_to(create_vote_path(election_id: params[:election_id])) and return if params[:election_id]
        redirect_to(root_path, flash: { notice: t('podemos.user_verification.documentation_received')})
      end
    else
      render :new
    end
  end

  private

  def check_valid_and_verified
    redirect_to(root_path, flash: { notice: t('podemos.user_verification.user_not_valid_to_verify') }) if Election.future.none? { |e| e.has_valid_location_for? current_user }
    redirect_to(root_path, flash: { notice: t('podemos.user_verification.user_already_verified') }) if current_user.verified?
  end

  def user_verification_params
    params.require(:user_verification).permit(:procesed_at, :front_vatid, :back_vatid, :terms_of_service, :wants_card)
  end
end

