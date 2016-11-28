class ImpulsaController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]
  before_action :set_variables
  before_action :check_project, except: [ :index ]
 
  def index
    @upcoming = ImpulsaEdition.upcoming.first if @edition.nil?
  end

  def project
  end

  def evaluation
  end

  def project_step
    @show_errors = @project.wizard_status[@step][:filled]
    @project.valid? & @project.wizard_step_valid? if @show_errors
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
    if @project.deleteable?
      if @project.destroy
        flash[:notice] = "El proyecto ha sido borrado."
        redirect_to impulsa_path
      else
        flash[:error] = "El proyecto no ha podido ser borrado."
        redirect_to project_impulsa_path
      end
    else
      if @project.mark_as_resigned
        flash[:notice] = "Tu renuncia a realizar el proyecto ha sido registrada."
      else
        flash[:error] = "No se ha podido registrar la renuncia al proyecto."
      end
      redirect_to project_impulsa_path
    end
  end

  def update_step
    redirect_to project_impulsa_path and return unless @project.saveable?

    changes = (@project.changes.keys-["wizard_step"]).any?

    if @project.save
      if @project.wizard_step_errors.any?
        redirect_to project_step_impulsa_path(step: @project.wizard_step)
      elsif @project.wizard_next_step
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
      if @project.editable? then params.require(:impulsa_project).permit(:name) else {} end
    else
      params.require(:impulsa_project).permit(*@project.wizard_step_params)
    end
  end

  def check_project
    redirect_to impulsa_path if @project.nil?
  end

end
