class ImpulsaController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user_project
 
  def new
    if @edition
      redirect_to edit_impulsa_path if @project
      new_user_project
    else
      @upcoming = ImpulsaEdition.upcoming.first
      render :inactive
    end
  end

  def edit
    redirect_to new_impulsa_path unless @project
    
    if @project.fixes?
      @project.review_fields.each do |field, message|
        @project.errors.add field, message
      end
    end
  end

  def modify
    redirect_to new_impulsa_path unless @project
    @project.preload(params[:impulsa_project])
    @project.assign_attributes project_params

    if params[:commit]
      @project.mark_for_review if params[:commit]==t("podemos.impulsa.mark_for_review")
      if @project.save
        flash[:notice] = "Los cambios han sido guardados"
        redirect_to edit_impulsa_path
        return
      end
    end
    render :edit
  end

  def create
    redirect_to edit_impulsa_path if @project
    new_user_project

    if params[:commit] and @project.save
      redirect_to edit_impulsa_path, notice: "El proyecto ha sido guardado."
      return
    end
    render :new
  end

  private

  def set_user_project
    @edition = ImpulsaEdition.current
    return if @edition.nil?

    @project = @edition.impulsa_projects.where(user:current_user).first

    @available_categories = @edition.impulsa_edition_categories
    @available_categories = @available_categories.non_authors if !current_user.impulsa_author?
  end

  def new_user_project
    @project = ImpulsaEdition.current.impulsa_projects.build
    @project.preload(params[:impulsa_project])
    @project.assign_attributes(project_params) unless params[:impulsa_project].blank?
    @project.user = current_user
  end

  def project_params
    params.require(:impulsa_project).permit(@project.user_editable_fields)
  end
end
