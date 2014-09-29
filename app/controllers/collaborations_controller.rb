class CollaborationsController < ApplicationController
  before_action :authenticate_user! 
  before_action :set_collaboration, only: [:confirm, :edit, :destroy]

  # GET /collaborations/new
  # GET /colabora/
  def new
    redirect_to edit_collaboration_path if current_user.collaboration 
    @collaboration = Collaboration.new
  end

  # GET /colabora/confirmar
  # GET /collaborations/confirm
  def confirm
  end

  # POST /collaborations/validate/callback
  # POST /colabora/validar/callback
  def callback
    @collaboration = Collaboration.find_by_order params["Ds_Order"]
    @collaboration.parse_response(params)
  end

  # GET /collaborations/validate/status/:order.json
  # FIXME: .json
  def status
    # Comprobamos y devolvemos el response_status de un Order dado
    @collaboration = Collaboration.find_by_order params["order"]
    respond_to do |format|
      msg = { :status => @collaboration.response_status }
      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  # GET /collaborations/validate/OK
  # GET /colabora/validar/OK
  def OK
  end

  # GET /collaborations/validate/KO
  # GET /colabora/validar/error
  def KO
  end

  # GET /collaborations/edit
  # GET /colabora/edita
  def edit
    # borrar una colaboración
  end

  # POST /collaborations
  # POST /collaborations.json
  # POST /colabora
  # POST /colabora.json
  def create
    @collaboration = Collaboration.new(collaboration_params)
    @collaboration.user = current_user

    respond_to do |format|
      if @collaboration.save
        format.html { redirect_to confirm_collaboration_url, notice: 'Collaboration was successfully created.' }
        format.json { render :confirm, status: :created, location: confirm_collaboration_path }
      else
        format.html { render :new }
        format.json { render json: @collaboration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /colabora
  # DELETE /colabora
  def destroy
    @collaboration.destroy
    respond_to do |format|
      format.html { redirect_to new_collaboration_path, notice: 'Collaboration was successfully destroyed.' }
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
    params.require(:collaboration).permit(:user_id, :amount, :frequency, :terms_of_service, :minimal_year_old)
  end
end
