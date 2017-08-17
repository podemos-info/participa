class UserVerificationsController < ApplicationController
  before_action :check_valid_and_verified, only: [:new, :create]

  def new
    @user_verification = UserVerification.for current_user
  end

  def create
    @user_verification = UserVerification.for current_user, user_verification_params
    # if the validation was rejected, restart it
    @user_verification.status = UserVerification.statuses[:pending] if @user_verification.rejected?
    @user_verification.status = UserVerification.statuses[:accepted_by_email] if current_user.photos_unnecessary?
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

  def report
    filas=[]
    @report = {
                provincias: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } },
                autonomias: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } }
              }

    provinces = Carmen::Country.coded("ES").subregions.map {|p| [ "p_%02d" % + p.index, p.name ] }
    autonomies = Podemos::GeoExtra::AUTONOMIES.values.uniq.sort

    provinces.each do |province_code, province_name|
      UserVerification.joins(:user).merge(User.confirmed.ransack( vote_province_in: province_code ).result)
                      .group(:status).pluck(:status, "count(*)").each do |status, total|
        status = UserVerification.statuses.invert[status].to_sym
        @report[:provincias][province_name][status] = total
        @report[:provincias][province_name][:users] = User.confirmed.ransack( vote_province_in: province_code ).result.count
      end
    end

    autonomies.each do |autonomy_code, autonomy_name|
      UserVerification.joins(:user).merge(User.confirmed.ransack( vote_autonomy_in: autonomy_code ).result)
                      .group(:status).pluck(:status, "count(*)").each do |status, total|
        status = UserVerification.statuses.invert[status].to_sym
        @report[:autonomias][autonomy_name][status] = total
        @report[:autonomias][autonomy_name][:users] = User.confirmed.ransack( vote_autonomy_in: autonomy_code ).result.count
      end
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

