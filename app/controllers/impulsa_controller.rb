class ImpulsaController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :categories, :category, :project, :attachment ]
  before_action :set_current_edition
  before_action :set_user_project
 
  def index
    @upcoming = ImpulsaEdition.upcoming.first if @edition.nil?
  end

  def new
    if @edition
      redirect_to edit_impulsa_path and return if @project
      new_user_project
    else
      @upcoming = ImpulsaEdition.upcoming.first
      render :index
    end
  end

  def edit
    redirect_to new_impulsa_path and return unless @project
    if @project.fixes?
      @project.review_fields.each do |field, message|
        @project.errors.add field, message
      end
    end
  end

  def modify
    redirect_to new_impulsa_path and return unless @project

    @project.preload(params[:impulsa_project])
    @project.assign_attributes project_params
    cache_files

    if params[:commit]
      @project.mark_as_new if params[:commit]==t("podemos.impulsa.save_draft")
      @project.mark_for_review if params[:commit]==t("podemos.impulsa.mark_for_review")
      if @project.save
        flash[:notice] = "Los cambios han sido guardados"
        redirect_to edit_impulsa_path
        return
      else
        @project.clear_extra_file_errors
      end
    end
    render :edit
  end

  def create
    redirect_to edit_impulsa_path and return if @project
    new_user_project
    cache_files

    if params[:commit] and @project.save
      redirect_to edit_impulsa_path, notice: "El proyecto ha sido guardado."
      return
    end
    render :new
  end

  def attachment
    project = ImpulsaProject.find(params[:id]) if !["logo", "requested_budget", "schedule"].member? params[:fields] # important to avoid users viewing other users attachments
    path = "#{Rails.application.root}/non-public/system/impulsa_projects/#{project.id}/#{params[:field]}/#{params[:style]}/#{params[:filename]}"
    send_file path
  end

  def categories
    @categories_state = @edition.impulsa_edition_categories.state.select {|c| c.impulsa_projects.public_visible.count>0}
    @categories_territorial = @edition.impulsa_edition_categories.territorial.select {|c| c.impulsa_projects.public_visible.count>0}
    @categories_internal = @edition.impulsa_edition_categories.internal.select {|c| c.impulsa_projects.public_visible.count>0}
  end

  def category
    @category = ImpulsaEditionCategory.find(params[:id])
    @projects = @category.impulsa_projects.public_visible
    redirect_to impulsa_categories_path and return if @category.nil?
  end

  def project
    @project = ImpulsaProject.public_visible.where(id:params[:id]).first
    redirect_to impulsa_categories_path and return if @project.nil?
  end

  private

  def cache_files
    @project.cache_project_files
  end

  def set_current_edition
    @edition = ImpulsaEdition.current
  end

  def set_user_project
    return if @edition.nil? || !current_user
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
    if @project.user_edit_field?(:impulsa_edition_topics) || @project.user_edit_field?(:impulsa_edition_topic_ids)
      params.require(:impulsa_project).permit(@project.user_editable_fields + @project.user_editable_cache_fields, impulsa_edition_topic_ids:[])
    else
      params.require(:impulsa_project).permit(@project.user_editable_fields + @project.user_editable_cache_fields)
    end
  end
end
