class UserVerificationsController < ApplicationController
  before_action :check_verified

  def new
    @user_verification = UserVerification.for current_user
  end

  def create
    @user_verification = UserVerification.for current_user, user_verification_params
    if @user_verification.save
      redirect_to(create_vote_path(election_id: params[:election_id])) and return if params[:election_id]
      redirect_to(root_path, flash: { notice: "Ya hemos recibido tu documentación y la procesaremos proximamente." })
    else
      render :new
    end
  end

  private

  def check_verified
    redirect_to(root_path, flash: { notice: "Tu usuario ya está verificado" }) if current_user.verified?
  end

  def user_verification_params
    params.require(:user_verification).permit(:procesed_at, :front_vatid, :back_vatid, :terms_of_service)
  end
end

