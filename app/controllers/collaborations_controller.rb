class CollaborationsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_collaboration, only: [:confirm, :confirm_bank, :edit, :modify, :destroy, :OK, :KO]
 
  def new
    redirect_to edit_collaboration_path if current_user.collaboration 
    @collaboration = Collaboration.new
  end

  def modify
    redirect_to new_collaboration_path unless @collaboration
    redirect_to confirm_collaboration_path unless @collaboration.has_payment?

    # update collaboration
    @collaboration.assign_attributes collaboration_params

    if @collaboration.save
      flash[:notice] = "Los cambios han sido guardados"
      redirect_to edit_collaboration_path
    else
      render 'edit'
    end
  end

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

  def edit
    redirect_to new_collaboration_path unless @collaboration
    redirect_to confirm_collaboration_path unless @collaboration.has_payment?
  end

  def destroy
    redirect_to new_collaboration_path unless @collaboration
    @collaboration.destroy
    respond_to do |format|
      format.html { redirect_to new_collaboration_path, notice: 'Hemos dado de baja tu colaboración.' }
      format.json { head :no_content }
    end
  end

  def confirm
    redirect_to new_collaboration_path unless @collaboration
    redirect_to edit_collaboration_path if @collaboration.has_payment?
    # ensure credit card order is not persisted, to allow create a new id for each payment try
    @order = @collaboration.create_order Time.now, true if @collaboration.is_credit_card?
  end

  def OK
    redirect_to new_collaboration_path unless @collaboration
    if not @collaboration.is_active?
      if @collaboration.is_credit_card?
        @collaboration.set_warning! "Marcada como alerta porque se ha visitado la página de que la colaboración está pagada pero no consta el pago."
      else
        @collaboration.set_active!
      end
    end
  end

  def KO
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_collaboration
    @collaboration = current_user.collaboration

    if @collaboration
      start_date = [@collaboration.created_at, Date.today - 6.months].max
      @orders = @collaboration.get_orders(start_date, start_date + 12.months)[0..(12/@collaboration.frequency-1)]
      @order = @orders[0][-1]
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def collaboration_params
    if current_user.collaboration and current_user.collaboration.has_payment?
      params.require(:collaboration).permit(:amount, :frequency, :terms_of_service, :minimal_year_old, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic, :for_autonomy_cc, :for_town_cc)
    else
      params.require(:collaboration).permit(:amount, :frequency, :terms_of_service, :minimal_year_old, :payment_type, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic, :for_autonomy_cc, :for_town_cc)
    end
  end
end
