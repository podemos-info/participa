class CollaborationsController < ApplicationController
  before_action :authenticate_user! 
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
    # TODO check if collaboration_id and user_id and Date/Time are correct 
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

    @collaboration = Collaboration.find_by_redsys_order params["order"]
    respond_to do |format|
      msg = { :status => @collaboration.response_status }
      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  # GET /collaborations/validate/OK
  def OK
  end

  # GET /collaborations/validate/KO
  def KO
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
        format.html { redirect_to confirm_collaboration_url, notice: 'Hemos dado de alta tu colaboración.' }
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
