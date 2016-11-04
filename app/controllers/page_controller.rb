require 'securerandom'
class PageController < ApplicationController

  before_action :authenticate_user!, except: [ :privacy_policy, :faq, :guarantees, :funding, :guarantees_form, :show_form,
                                              :circles_validation, :primarias_andalucia, :listas_primarias_andaluzas,
                                              :responsables_organizacion_municipales, :count_votes,
                                              :responsables_municipales_andalucia, :plaza_podemos_municipal,
                                              :portal_transparencia_cc_estatal, :mujer_igualdad, :alta_consulta_ciudadana,
                                              :representantes_electorales_extranjeros, :responsables_areas_cc_autonomicos,
                                              :apoderados_campana_autonomica_andalucia, :comparte_cambio_valoracion_propietarios,
                                              :comparte_cambio_valoracion_usuarios, :avales_candidaturas_primarias, :iniciativa_ciudadana]

  before_filter :set_metas

  def set_metas
    @current_elections = Election.active
    election = @current_elections.select {|election| election.meta_description if !election.meta_description.blank? } .first

    
    @meta_description = Rails.application.secrets.metas["description"] if @meta_description.nil?
    @meta_image = Rails.application.secrets.metas["image"] if @meta_description.nil?
  end

  def show_form
    @page = Page.find(params[:id])
  	raise("not found") unless @page

    @meta_description = @page.meta_description if !@page.meta_description.blank?
    @meta_image = @page.meta_image if !@page.meta_image.blank?
    if @page.require_login && !user_signed_in?
      flash[:metas] = { description: @meta_description, image: @meta_image }
      authenticate_user! 
    end
    
  	if /https:\/\/[a-z]*\.podemos.info\/.*/.match(@page.link)
  		render :formview_iframe, locals: { title: @page.title, url: @page.link }
  	else
      render :form_iframe, locals: { title: @page.title, form_id: @page.id_form, extra_qs:"" }
  	end
  end

  def privacy_policy
  end

  def faq
  end

  def guarantees
  end

  def funding
  end

  def guarantees_form
    render :form_iframe, locals: { title: "Comunicación a Comisiones de Garantías Democráticas", form_id: 77, extra_qs:"", return_path: guarantees_path }
  end

  def circles_validation
    render :form_iframe, locals: { title: "Validación de Círculos", form_id: 45, extra_qs:"" }
  end

  def list_register
    render :form_iframe, locals: { title: "Listas autonómicas", form_id: 20, extra_qs:"" }
  end

  def offer_hospitality
    render :form_iframe, locals: { title: "Comparte tu casa", form_id: 71, extra_qs:"", return_path: root_path }
  end
  def find_hospitality
    render :formview_iframe, locals: { title: "Encuentra alojamiento", url: "https://forms.podemos.info/compartir-casa/"}
  end
  def share_car_sevilla
    render :form_iframe, locals: { title: "Comparte tu coche: Destino Sevilla", form_id: 72, extra_qs:"", return_path: root_path }
  end
  def find_car_sevilla
    render :formview_iframe, locals: { title: "Encuentra coche a Sevilla", url: "https://forms.podemos.info/compartir-viaje-sevilla/"}
  end
  def share_car_doshermanas
    render :form_iframe, locals: { title: "Comparte tu coche: Destino Dos Hermanas", form_id: 73, extra_qs:"", return_path: root_path }
  end
  def find_car_doshermanas
    render :formview_iframe, locals: { title: "Encuentra coche a Dos Hermanas", url: "https://forms.podemos.info/compartir-viaje-dos-hermanas/"}
  end

  def town_legal
    render :form_iframe, locals: { title: "Responsables de finanzas y legal", form_id: 14, extra_qs:"" }
  end


  def avales_barcelona
    render :form_iframe, locals: { title: "Avales Barcelona", form_id: 22, extra_qs:"" }
  end

  def primarias_andalucia
    render :form_iframe, locals: { title: "Primarias Andalucía", form_id: 21, extra_qs:"" }
  end

  def listas_primarias_andaluzas
    render :form_iframe, locals: { title: "Listas Primarias Andalucía", form_id: 23, extra_qs:"" }
  end

  def responsables_organizacion_municipales
    render :form_iframe, locals: { title: "Responsable del área de Organización / Extensión en los órganos municipales", form_id: 26, extra_qs:"" }
  end

  def responsables_municipales_andalucia
    render :form_iframe, locals: { title: "Elecciones Andalucía 2015 - Personas de contacto", form_id: 51, extra_qs:"" }
  end

  def plaza_podemos_municipal
    render :form_iframe, locals: { title: "Plaza Podemos municipales", form_id: 52, extra_qs:"" }
  end

  def portal_transparencia_cc_estatal
    render :form_iframe, locals: { title: "Portal de Transparencia - CC Estatal", form_id: 54, extra_qs:"" }
  end

  def mujer_igualdad
    render :form_iframe, locals: { title: "Área de mujer e igualdad - Encuentro", form_id: 55, extra_qs:"" }
  end

  def alta_consulta_ciudadana
    render :form_iframe, locals: { title: "Formulario para activar la Consulta Ciudadana acerca de las candidaturas de unidad popular", form_id: 57, extra_qs:"" }
  end

  def representantes_electorales_extranjeros
    render :form_iframe, locals: { title: "Elecciones Andaluzas: Representantes electorales de Podemos en Consulados extranjeros", form_id: 60, extra_qs:"" }
  end

  def representantes_electorales_extranjeros
    render :form_iframe, locals: { title: "Elecciones Andaluzas: Representantes electorales de Podemos en Consulados extranjeros", form_id: 60, extra_qs:"" }
  end

  def responsables_areas_cc_autonomicos
    render :form_iframe, locals: { title: "Responsables de Áreas de los Consejos Ciudadanos Autonómicos", form_id: 61, extra_qs:"" }
  end

  def boletin_correo_electronico
    render :form_iframe, locals: { title: "Envío de boletín por correo electrónico", form_id: 62, extra_qs:"" }
  end

  def candidaturas_primarias_autonomicas
    render :form_iframe, locals: { title: "Formulario de candidaturas", form_id: 63, extra_qs:"" }
  end

  def listas_primarias_autonomicas
    render :form_iframe, locals: { title: "Formulario de listas de primarias Forales Euskadi", form_id: 67, extra_qs:"" }
  end
  
  def apoderados_campana_autonomica_andalucia
    render :form_iframe, locals: { title: "Apoderados para la campaña autonómica en Andalucía", form_id: 64, extra_qs:"" }
  end

  def comparte_cambio_valoracion_propietarios
    render :form_iframe, locals: { title: "Cuéntanos como fue la experiencia compartiendo tu casa o coche", form_id: 65, extra_qs:"" }
  end

  def comparte_cambio_valoracion_usuarios
    render :form_iframe, locals: { title: "Cuéntanos que tal te acogieron en su casa o coche", form_id: 66, extra_qs:"" }
  end

  def responsable_web_autonomico
    render :form_iframe, locals: { title: "Responsables webs autonómicos", form_id: 68, extra_qs:"" }
  end

  def avales_candidaturas_primarias
    render :form_iframe, locals: { title: "Avales para candidaturas de primarias", form_id: 83, extra_qs:"" }
  end

  def iniciativa_ciudadana
    render :form_iframe, locals: { title: "Iniciativa ciudadana", form_id: 84, extra_qs:"" }
  end

  def cuentas_consejos_autonomicos
    render :form_iframe, locals: { title: "Solicitud de cuentas institucionales para consejos Autonómicos", form_id: 79, extra_qs:"" }
  end

  def condiciones_uso_correo
    render :form_iframe, locals: { title: "Condiciones de uso del correo electrónico PODEMOS", form_id: 80, extra_qs:"" }
  end
  
end
