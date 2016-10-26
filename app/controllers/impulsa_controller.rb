class ImpulsaController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]
  before_action :set_variables
  before_action :check_project, except: [ :index ]
 
  def index
    @upcoming = ImpulsaEdition.upcoming.first if @edition.nil?
  end

  def project
  end

  def project_step
    @project.update_column :wizard_step, @step if @project.wizard_step != @step
    @show_errors = @project.wizard_status[@step][:filled]
    @project.valid? & @project.wizard_valid? if @show_errors
  end

  def update
    redirect_to project_impulsa_path and return unless @project.editable?
    if @project.save
      redirect_to project_step_impulsa_path(step: @project.wizard_step) 
    else
      render :project
    end
  end

  def review
    if @project.mark_for_review
      flash[:notice] = "El proyecto ha sido marcado para ser revisado."
    else
      flash[:error] = "El proyecto no puede ser marcado para ser revisado."
    end
    redirect_to project_impulsa_path
  end

  def delete
    redirect_to project_impulsa_path and return unless @project.deleteable?
    if @project.delete
      flash[:notice] = "El proyecto ha sido borrado."
      redirect_to impulsa_path
    else
      flash[:error] = "El proyecto no ha podido ser borrado."
      redirect_to project_impulsa_path
    end
  end

  def update_step
    redirect_to project_impulsa_path and return unless @project.saveable?

    changes = (@project.changes.keys-["wizard_step"]).any?

    if @project.save
      if @project.wizard_next_step
        redirect_to project_step_impulsa_path(step: @project.wizard_next_step)
      else
        redirect_to project_impulsa_path
      end
      return
    end
    render :edit
  end

  def upload
    gname, fname = params[:field].split(".")
    result = @project.assign_wizard_value(gname, fname, params[:file])
    errors = [
            case result
              when :wrong_extension
                "El tipo de fichero subido no es correcto."
              when :wrong_size
                "El tamaño del fichero subido supera el límite permitido."
              when :wrong_field
                "El fichero subido no corresponde a ningún campo. Por favor, recarga la página e intenta subirlo nuevamente."
            end 
          ]

    if errors.any?
      render json: errors, status: :unprocessable_entity
    else
      @project.save
      filename = @project.wizard_values[params[:field]]
      ret = {
              name: filename,
              path: download_impulsa_path(field: filename)
            }
      render json: ret
    end
  end

  def delete_file
    gname, fname = params[:field].split(".")
    result = @project.assign_wizard_value(gname, fname, nil)
    errors = [
            case result
              when :wrong_field
                "El fichero indicado no corresponde a ningún campo. Por favor, recarga la página e intenta borrarlo nuevamente."
            end 
          ]

    if errors.any?
      render json: errors, status: :unprocessable_entity
    else
      @project.save
      render json: {}
    end
  end

  def download
    gname, fname, extension = params[:field].split(".")
    send_file @project.wizard_path(gname, fname)
  end

private
  def set_variables
    @edition = ImpulsaEdition.current
    return if @edition.nil? || !current_user

    @step = params[:step]
    @project = @edition.impulsa_projects.where(user:current_user).first
    if @project.nil? && @edition.allow_creation?
      @project = ImpulsaProject.new user: current_user
    end

    @available_categories = @edition.impulsa_edition_categories
    @available_categories = @available_categories.non_authors if !current_user.impulsa_author?

    if @project.present? then
      @project.wizard_step = @step if @step
      @project.assign_attributes(project_params) unless params[:impulsa_project].blank?
    end
  end

  def project_params
    if !@project.persisted?
      params.require(:impulsa_project).permit(:name, :impulsa_edition_category_id)
    elsif @step.blank?
      if @project.editable? then params.require(:impulsa_project).permit(:name) else [] end
    else
      params.require(:impulsa_project).permit(*@project.wizard_step_params)
    end
  end

  def check_project
    redirect_to impulsa_path if @project.nil?
  end


'''
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
'''
end
