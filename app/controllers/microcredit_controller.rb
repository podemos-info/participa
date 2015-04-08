class MicrocreditController < ApplicationController

  def provinces
    render partial: 'subregion_select', locals:{ country: (params[:microcredit_loan_country] or "ES"), province: params[:microcredit_loan_province], disabled: false, required: true, title:"Provincia"}
  end

  def towns
    render partial: 'municipies_select', locals:{ country: (params[:microcredit_loan_country] or "ES"), province: params[:microcredit_loan_province], town: params[:microcredit_loan_town], disabled: false, required: true, title:"Municipio"}
  end

  def index
    @microcredits = Microcredit.active

    @box_class = case @microcredits.length
                    when 1 then "full"
                    else "half"
                end       
  end

  def new_loan
    @microcredit = Microcredit.find(params[:id])
    @loan = MicrocreditLoan.new

    @user_loans = current_user ? @microcredit.loans.where(user:current_user) : []
  end

  def create_loan
    @microcredit = Microcredit.find(params[:id])
    @loan = MicrocreditLoan.new(loan_params) do |loan|
      loan.microcredit = @microcredit
      loan.user = current_user if current_user
      loan.ip = request.remote_ip
    end

    @loan.set_user_data loan_params if not current_user

    if verify_recaptcha and @loan.save
      UsersMailer.microcredit_email(@microcredit, @loan).deliver
      redirect_to microcredit_path, notice: 'En unos segundos recibirás un correo electrónico con toda la información necesaria para finalizar el proceso de suscripción del microcrédito Podemos. ¡Gracias por colaborar!'
    else
      flash[:error] = @loan.errors
      render :new_loan
    end
  end

  private

  def loan_params
    if current_user
      params.require(:microcredit_loan).permit(:amount, :terms_of_service, :minimal_year_old)
    else
      params.require(:microcredit_loan).permit(:first_name, :last_name, :document_vatid, :email, :address, :postal_code, :town, :province, :country, :amount, :terms_of_service, :minimal_year_old)
    end
  end
end
