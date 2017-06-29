class UserVerificationsController < ApplicationController

  def new
    @user_verification = UserVerification.new user: current_user
  end

  def create
    @user_verification = UserVerification.build(user_verification_params, user: current_user)
    if @user_verification.valid?
      @user_verification.save
      redirect_to(create_vote_path(election_id: params[:election_id])) and return if params[:election_id]
      redirect_to(root_path, flash: { notice: "Ya hemos recibido tu documentación y la procesaremos proximamente." })
    else
      flash.now[:error] = "Ha ocurrido un error al recibir tus ficheros, inténtalo nuevamente por favor."
      render :new
    end
  end

  private

  def user_verification_params
    params.require(:user_verification).permit(:procesed_at, :result)
  end
end

