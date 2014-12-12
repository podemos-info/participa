class CollaborationsController < ApplicationController

  skip_before_filter :verify_authenticity_token, only: [ :redsys_callback ] 

  before_action :authenticate_user!, except: [ :redsys_callback ] 
  before_action :set_collaboration, only: [:confirm, :confirm_bank, :edit, :destroy]
  # TODO: before_action :check_if_user_over_age
  # TODO: before_action :check_if_user_passport
  # TODO: before_action :check_if_user_already_collaborated
 
  # GET /collaborations/new
  def new
    redirect_to edit_collaboration_path if current_user.collaboration 
    @collaboration = Collaboration.new
  end

  # GET /collaborations/confirm
  def confirm
  end

  # POST /collaborations/confirm_bank
  def confirm_bank
    unless @collaboration.is_credit_card?
      @collaboration.update_attribute(:response_status, "OK")
      redirect_to :validate_ok_collaboration
    end
  end

  # POST /collaborations/validate/callback
  def redsys_callback
    # Callback de Redsys para MerchantURL MerchantURLOK y MerchantURLKO
    # recibe la respuesta en el formato de Redsys y la parsea

    @collaboration = Collaboration.find_by_redsys_order! params["Ds_Order"]
    @collaboration.redsys_parse_response!(params)
    if @collaboration.redsys_response?
      render json: "OK"
    else
      render json: "KO"
    end
  end

  # GET /collaborations/validate/status/:order.json
  def redsys_status
    # Comprobamos y devolvemos el response_status de un Order dado
    # es para la comprobación por AJAX del resultado de la ventana de Redsys

    @collaboration = Collaboration.find_by_redsys_order! params["order"]
    respond_to do |format|
      format.json { render json: { status: @collaboration.response_status } }
    end
  end

  # GET /collaborations/validate/OK
  def OK
    @collaboration = current_user.collaboration
  end

  # GET /collaborations/validate/KO
  def KO
    @collaboration = current_user.collaboration
  end

  # GET /collaborations/edit
  def edit
    # borrar una colaboración
  end

  # POST /collaborations
  # POST /collaborations.json
  def create
    @collaboration = Collaboration.new(collaboration_params)
    @collaboration.user = current_user

    respond_to do |format|
      if @collaboration.save
        format.html { redirect_to confirm_collaboration_url, notice: 'Por favor revisa y confirma tu colaboración.' }
        format.json { render :confirm, status: :created, location: confirm_collaboration_path }
      else
        format.html { render :new }
        format.json { render json: @collaboration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collaborations
  def destroy
    @collaboration.destroy
    respond_to do |format|
      format.html { redirect_to new_collaboration_path, notice: 'Hemos dado de baja tu colaboración.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_collaboration
    @collaboration = current_user.collaboration
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def collaboration_params
    params.require(:collaboration).permit(:amount, :frequency, :terms_of_service, :minimal_year_old, :payment_type, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic)
  end
end
