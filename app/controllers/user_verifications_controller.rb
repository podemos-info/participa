class UserVerificationsController < ApplicationController

  def new
    @user_verification = UserVerification.new user: current_user
  end

  def create
    @user_verification = UserVerification.new user_verification_params.merge(user: current_user)
    if @user_verification.save
      redirect_to(create_vote_path(election_id: params[:election_id])) and return if params[:election_id]
      redirect_to(root_path, flash: { notice: "Ya hemos recibido tu documentación y la procesaremos proximamente." })
    else
      render :new
    end
  end

  private

  def user_verification_params
    params.require(:user_verification).permit(:procesed_at, :front_vatid, :back_vatid, :terms_of_service)
  end
end

