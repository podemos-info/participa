class ImpulsaController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_project
 
  def new
    if @edition
      redirect_to edit_impulsa_path and return if @project
      new_user_project
    else
      @upcoming = ImpulsaEdition.upcoming.first
      render :index
    end
  end

  def index
    @upcoming = ImpulsaEdition.upcoming.first
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
        # send mails
        ImpulsaMailer.on_review(@project) if @project.mark_for_review
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
    project = ImpulsaProject.find(params[:id]) # important to avoid users viewing other users attachments
    path = "#{Rails.application.root}/non-public/system/impulsa_projects/#{project.id}/#{params[:field]}/#{params[:style]}/#{params[:filename]}.#{params[:extension]}"

    send_file path if project.has_attachment_field?(params[:field])
  end

  private

  def cache_files
    @project.cache_project_files
  end

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
    if @project.user_edit_field?(:impulsa_edition_topics)
      params.require(:impulsa_project).permit(@project.user_editable_fields + @project.user_editable_cache_fields , impulsa_edition_topic_ids:[])
    else
      params.require(:impulsa_project).permit(@project.user_editable_fields + @project.user_editable_cache_fields)
    end
  end
end
