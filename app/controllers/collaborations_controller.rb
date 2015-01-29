class CollaborationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_collaboration, only: [:confirm, :confirm_bank, :edit, :destroy, :OK, :KO]
  # TODO: before_action :check_if_user_over_age
  # TODO: before_action :check_if_user_passport
  # TODO: before_action :check_if_user_already_collaborated
 
  # GET /collaborations/new
  def new
    redirect_to edit_collaboration_path if current_user.collaboration 
    @collaboration = Collaboration.new
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

  # GET /collaborations/edit
  def edit
    # borrar una colaboración
    redirect_to confirm_collaboration_path unless @collaboration.is_valid?
  end

  # DELETE /collaborations
  def destroy
    @collaboration.destroy
    respond_to do |format|
      format.html { redirect_to new_collaboration_path, notice: 'Hemos dado de baja tu colaboración.' }
      format.json { head :no_content }
    end
  end

  # GET /collaborations/confirm
  def confirm
    if @collaboration.is_credit_card?
      @order = @collaboration.create_order Time.now
    end
  end

  # POST /collaborations/confirm_bank
  def confirm_bank
    unless @collaboration.is_credit_card?
      @collaboration.update_attribute(:response_status, "OK")
      redirect_to :validate_ok_collaboration
    end
  end

  # GET /collaborations/OK
  def OK
    #redirect_to edit_collaboration_path, flash: { notice: "Has dado de alta correctamente tu colaboración" } 
  end

  # GET /collaborations/KO
  def KO
    #confirm_collaboration_url
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
