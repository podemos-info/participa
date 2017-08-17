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

    base_query = User.confirmed.where("vote_town ilike 'm\\___%'")

    # get totals by prov and status
    data = Hash[
              base_query.joins(:user_verification).group(:prov, :status)
              .pluck("right(left(vote_town,4),2) as prov", "status", "count(distinct users.id)").map { |prov, status, count| [[prov, status], count] }
            ]
    
    # add users totals by prov
    active_date = Date.today - eval(Rails.application.secrets.users["active_census_range"])
    base_query.group(:prov, :active, :verified).pluck(
        "right(left(vote_town,4),2) as prov", 
        "(current_sign_in_at IS NOT NULL AND current_sign_in_at > '#{active_date.to_datetime.iso8601 }') as active", 
        "#{User.verified_condition} as verified", 
        "count(distinct users.id)"
      ).each do |prov, active, verified, count|
        data[[prov, active, verified]] = count
    end

    provinces = Carmen::Country.coded("ES").subregions.map {|p| [ "%02d" % + p.index, p.name ] }

    provinces.each do |province_num, province_name|
      autonomy_name = Podemos::GeoExtra::AUTONOMIES["p_#{province_num}"].last
      total_sum = 0
      UserVerification.statuses.each do |name, status|
        count = data[[province_num, status]] || 0
        @report[:provincias][province_name][name.to_sym] = count
        @report[:autonomias][autonomy_name][name.to_sym] += count
        total_sum += count
      end
      @report[:provincias][province_name][:total] = total_sum
      @report[:autonomias][autonomy_name][:total] += total_sum
      
      active_verified = data[[province_num, true, true]] || 0
      active = active_verified + (data[[province_num, true, false]] || 0)
      inactive_verified = data[[province_num, false, true]] || 0
      inactive = inactive_verified + (data[[province_num, false, false]] || 0)

      @report[:provincias][province_name][:users] = active + inactive
      @report[:provincias][province_name][:verified] = active_verified + inactive_verified
      @report[:autonomias][autonomy_name][:users] += active + inactive
      @report[:autonomias][autonomy_name][:verified] += active_verified + inactive_verified
      @report[:provincias][province_name][:active] = active
      @report[:provincias][province_name][:active_verified] = active_verified
      @report[:autonomias][autonomy_name][:active] += active
      @report[:autonomias][autonomy_name][:active_verified] += active_verified
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
