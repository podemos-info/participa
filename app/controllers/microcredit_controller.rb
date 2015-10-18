class MicrocreditController < ApplicationController
  include CollaborationsHelper
  before_action :check_brand
  layout :external_layout

  def provinces
    render partial: 'subregion_select', locals:{ country: (params[:microcredit_loan_country] or "ES"), province: params[:microcredit_loan_province], disabled: false, required: true, title:"Provincia"}
  end

  def towns
    render partial: 'municipies_select', locals:{ country: (params[:microcredit_loan_country] or "ES"), province: params[:microcredit_loan_province], town: params[:microcredit_loan_town], disabled: false, required: true, title:"Municipio"}
  end

  def check_brand
    default_brand = Rails.application.secrets.microcredits["default_brand"]
    @brand = params[:brand]
    @brand_config = Rails.application.secrets.microcredits["brands"][@brand]
    if @brand_config.blank?
      @brand = default_brand
      @brand_config = Rails.application.secrets.microcredits["brands"][default_brand]
    end
    @external = Rails.application.secrets.microcredits["brands"][@brand]["external"]
  end

  def external_layout
    @external ? "noheader" : "application"
  end

  def index
    @all_microcredits = Microcredit.upcoming_finished

    @microcredits = @all_microcredits.select { |m| m.is_active? }

    if @microcredits.length == 0
      @upcoming_microcredits = @all_microcredits.select { |m| m.is_upcoming? } .sort_by(&:starts_at)
      @finished_microcredits = @all_microcredits.select { |m| m.recently_finished? } .sort_by(&:ends_at).reverse
    end
  end

  def login
    authenticate_user!
    redirect_to new_microcredit_loan_path(params[:id], brand:@brand)
  end

  def new_loan
    @microcredit = Microcredit.find(params[:id])
    redirect_to microcredit_path(brand:@brand) and return unless @microcredit and @microcredit.is_active?

    @loan = MicrocreditLoan.new
    @user_loans = current_user ? @microcredit.loans.where(user:current_user) : []
  end

  def create_loan
    @microcredit = Microcredit.find(params[:id])
    redirect_to microcredit_path(brand:@brand) and return unless @microcredit and @microcredit.is_active?
    @user_loans = current_user ? @microcredit.loans.where(user:current_user) : []

    @loan = MicrocreditLoan.new(loan_params) do |loan|
      loan.microcredit = @microcredit
      loan.user = current_user if current_user
      loan.ip = request.remote_ip
    end

    if not current_user
      @loan.set_user_data loan_params
    end 

    @loan.transaction do
      if (current_user or @loan.valid_with_captcha?) and @loan.save
        @loan.update_counted_at
        UsersMailer.microcredit_email(@microcredit, @loan, @brand_config).deliver_now
        redirect_to microcredit_path(brand:@brand), notice: t('microcredit.new_loan.will_receive_email', name: @brand_config["name"], main_url: @brand_config["main_url"], twitter_account: @brand_config["twitter_account"])
      else
        render :new_loan
      end
    end
  end

  def loans_renewal
    @microcredit = Microcredit.find(params[:id])
    @renewal = get_renewal
  end

  def loans_renew
    @microcredit = Microcredit.find(params[:id])
    @renewal = get_renewal(true)
    if @renewal.valid
      total_amount = 0
      MicrocreditLoan.transaction do
        @renewal.loan_renewals.each do |l|
          l.renew! @microcredit
          total_amount += l.amount
        end
      end
    end
    render :loans_renewal
  end

  private

  def loan_params
    if current_user
      params.require(:microcredit_loan).permit(:amount, :terms_of_service, :minimal_year_old)
    else
      params.require(:microcredit_loan).permit(:first_name, :last_name, :document_vatid, :email, :address, :postal_code, :town, :province, :country, :amount, :terms_of_service, :minimal_year_old, :captcha, :captcha_key)
    end
  end

  def get_renewal validate = false
    if params[:loan_id]
      loan = MicrocreditLoan.find_by(id: params[:loan_id])
    else
      loan = MicrocreditLoan.where(document_vatid: current_user.document_vatid).first
    end
    return nil unless @microcredit && !@microcredit.has_finished? && loan && loan.microcredit.renewable? && (current_user || loan.unique_hash==params[:hash])

    loans = MicrocreditLoan.renewables.not_renewed.where(microcredit_id:loan.microcredit_id, document_vatid: loan.document_vatid)
    other_loans = MicrocreditLoan.renewables.where.not(microcredit_id:loan.microcredit_id).where(document_vatid: loan.document_vatid).to_a.uniq(&:microcredit_id)
    recently_renewed_loans = MicrocreditLoan.recently_renewed.where(microcredit_id:loan.microcredit_id, document_vatid: loan.document_vatid)

    require 'ostruct'
    if validate
      renewal = OpenStruct.new( params.require(:renewals).permit(:renewal_terms, :terms_of_service, loan_renewals: []))
    else
      renewal = OpenStruct.new( renewal_terms: false, terms_of_service: false, loan_renewals: [])
    end
    renewal.loans = loans
    renewal.loan_renewals = renewal.loans.select {|l| renewal.loan_renewals.member? l.id.to_s }
    renewal.other_loans = other_loans
    renewal.recently_renewed_loans = recently_renewed_loans
    renewal.loan = loans.first || recently_renewed_loans.first
    renewal.errors = {}
    if validate
      renewal.errors[:renewal_terms] = t("errors.messages.accepted") if renewal.renewal_terms=="0"
      renewal.errors[:terms_of_service] = t("errors.messages.accepted") if renewal.terms_of_service=="0"
      renewal.errors[:loan_renewals] = t("microcredit.loans_renewal.none_selected") if renewal.loan_renewals.length==0
    end
    renewal.valid = renewal.errors.length==0
    renewal
  end

end

class OpenStruct                                                                                                                    
  def self.human_attribute_name(name)                                                                                               
    I18n::t("formtastic.labels.#{name}")
  end                                                                                                                               
end
