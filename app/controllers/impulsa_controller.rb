class ImpulsaController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user_project
 
  def new
    if @edition
      redirect_to edit_impulsa_path if @project
      @project = ImpulsaEdition.current.impulsa_projects.build
      @project.user = current_user
    else
      @upcoming = ImpulsaEdition.upcoming.first
      render :inactive
    end
  end

  def edit
    redirect_to new_impulsa_path unless @project
  end

  def modify
    redirect_to new_impulsa_path unless @project

    # update collaboration
    @project.assign_attributes project_params

    if @project.save
      flash[:notice] = "Los cambios han sido guardados"
      redirect_to edit_impulsa_path
    else
      render 'edit'
    end
  end

  def create
    @project = ImpulsaEdition.current.impulsa_projects.build(project_params)
    @project.user = current_user

    respond_to do |format|
      if @project.save
        redirect_to edit_impulsa_path, notice: "El proyecto ha sido guardado."
      else
        render :new
      end
    end
  end

  private

  def set_user_project
    @edition = ImpulsaEdition.current
    @project = @edition.impulsa_projects.where(user:current_user) if @edition
  end
    
  def project_params
    if @project 
      params.require(:impulsa_project).permit(@project.review_fields.symbolize_keys.keys) if @project.editable?
    else
      params.require(:impulsa_project).permit(ImpulsaProject::USER_EDITABLE_FIELDS)
    end
  end

end
