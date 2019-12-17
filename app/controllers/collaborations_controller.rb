class CollaborationsController < ApplicationController
  helper_method :force_single?, :active_frequencies, :payment_types
  helper_method :pending_single_orders

  before_action :authenticate_user!
  before_action :set_collaboration, only: [:confirm, :confirm_bank, :edit, :modify, :destroy, :OK, :KO]

  def new
    redirect_to edit_collaboration_path and return if current_user.recurrent_collaboration && !force_single?
    @collaboration = Collaboration.new
    @collaboration.for_town_cc = true
    @collaboration.frequency = 0 if force_single?
  end

  def modify
    redirect_to new_collaboration_path and return unless @collaboration
    redirect_to confirm_collaboration_path and return unless @collaboration.has_payment?

    # update collaboration
    @collaboration.assign_attributes create_params

    if @collaboration.save
      flash[:notice] = "Los cambios han sido guardados"
      redirect_to edit_collaboration_path
    else
      render 'edit'
    end
  end

  def create
    @collaboration = Collaboration.new(create_params)
    @collaboration.user = current_user

    if current_user.recurrent_collaboration && create_params[:frequency].to_i > 0
      flash[:alert] = "Ya tienes una colaboración recurrente, solo puedes añadir colaboraciones puntuales"
      render :new
      return
    end

    respond_to do |format|
      if @collaboration.save
        format.html { redirect_to confirm_collaboration_url(force_single:@collaboration.frequency == 0), notice: 'Por favor revisa y confirma tu colaboración.' }
        format.json { render :confirm, status: :created, location: confirm_collaboration_path }
      else
        format.html { render :new }
        format.json { render json: @collaboration.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    redirect_to new_collaboration_path and return unless @collaboration
    redirect_to confirm_collaboration_path and return unless @collaboration.has_payment?
  end

  def destroy
    @collaboration = Collaboration.find(params["single_collaboration_id"].to_i) if params["single_collaboration_id"].present?
    redirect_to new_collaboration_path and return unless @collaboration
    @collaboration.destroy
    respond_to do |format|
      notice_text = 'Hemos dado de baja tu colaboración'
      notice_text +=" puntual" if params["single_collaboration_id"].present?
      notice_text +="."
      format.html { redirect_to new_collaboration_path, notice: notice_text }
      format.json { head :no_content }
    end
  end

  def confirm
    redirect_to new_collaboration_path and return unless @collaboration
    redirect_to edit_collaboration_path if @collaboration.frequency >0 && @collaboration.has_payment?
    # ensure credit card order is not persisted, to allow create a new id for each payment try
    @order = @collaboration.create_order Time.now, true if @collaboration.is_credit_card?
  end

  def single
  end

  def OK
    redirect_to new_collaboration_path and return unless @collaboration || force_single?
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

  def payment_types
    Order::PAYMENT_TYPES.to_a.select { |k, v| [3, @collaboration.payment_type].member? v }
  end

  def force_single?
    params["force_single"].present? && params["force_single"] == "true"
  end

  def active_frequencies
    return Collaboration::FREQUENCIES.to_a.select {|k, v| k == "Puntual" } if force_single?
    return Collaboration::FREQUENCIES.to_a.select {|k, v| k != "Puntual" } if current_user.recurrent_collaboration
    Collaboration::FREQUENCIES.to_a
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_collaboration
    @collaboration = force_single? ? current_user.single_collaboration : current_user.recurrent_collaboration
    return unless @collaboration
    start_date = [@collaboration.created_at.to_date, Date.today - 6.months].max
    if @collaboration.frequency >0
      @orders = @collaboration.get_orders(start_date, start_date + 12.months)[0..(12/@collaboration.frequency-1)]
    else
      @orders  =[@collaboration.get_orders(start_date)[0]]
    end
    @order = @orders[0][-1]
  end

  def pending_single_orders
    @pending_single_orders ||= current_user.pending_single_collaborations.map do |c|
      c.get_orders(Date.today).first
    end
  end

  # def set_pending_single_orders
  #   @collaboration = force_single? ? current_user.single_collaboration : current_user.recurrent_collaboration
  #   return unless @collaboration
  #   start_date = [@collaboration.created_at.to_date, Date.today - 6.months].max
  #
  #   @pending_single_orders = []
  #   current_user.pending_single_collaborations.each do |c|
  #     @orders += [ c.get_orders(start_date)[0]]
  #   end
  #   byebug
  # end

  # Never trust parameters from the scary internet, only allow the white list through.
  def create_params
    params.require(:collaboration).permit(:amount, :frequency, :terms_of_service, :minimal_year_old, :payment_type, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic, :territorial_assignment)
  end
end
