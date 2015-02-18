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
    redirect_to confirm_collaboration_path unless @collaboration.is_active?
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
    @order = @orders[0]
  end

  # GET /collaborations/ok
  def OK
    if @collaboration 
      if @collaboration.is_credit_card?
        if not @collaboration.first_order or not @collaboration.first_order.is_paid?
          @collaboration.set_warning
        end
      else
        @collaboration.set_active
      end
    end
  end

  # GET /collaborations/ko
  def KO
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_collaboration
    @collaboration = current_user.collaboration

    start_date = [@collaboration.created_at, Date.today - 6.months].max
    @orders = @collaboration.get_orders start_date, start_date + 12.months
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def collaboration_params
    params.require(:collaboration).permit(:amount, :frequency, :terms_of_service, :minimal_year_old, :payment_type, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic)
  end
end
