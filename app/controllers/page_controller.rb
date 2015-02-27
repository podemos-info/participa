require 'securerandom'
class PageController < ApplicationController

  before_action :authenticate_user!, except: [:privacy_policy, :faq, :guarantees, :guarantees_conflict, :guarantees_compliance, 
                                              :guarantees_ethic, :circles_validation, :primarias_andalucia, :listas_primarias_andaluzas,
                                              :responsables_organizacion_municipales, :credits, :credits_add, :credits_info,
                                              :responsables_municipales_andalucia, :plaza_podemos_municipal,
                                              :portal_transparencia_cc_estatal, :mujer_igualdad, :alta_consulta_ciudadana,
                                              :representantes_electorales_extranjeros, :responsables_areas_cc_autonomicos]

  def privacy_policy
  end

  def faq
  end

  def guarantees
  end

  def guarantees_conflict
    render :form_iframe, locals: { title: "Comisión de Garantías Democráticas - Área de Conflictos y Garantías", form_id: 42, extra_qs:"", return_path: guarantees_path }
  end

  def guarantees_compliance
    render :form_iframe, locals: { title: "Comisión de Garantías Democráticas - Área de Cumplimiento y Transparencia", form_id: 43, extra_qs:"", return_path: guarantees_path }
  end

  def guarantees_ethic
    render :form_iframe, locals: { title: "Comisión de Garantías Democráticas - Área de Etica y Validación", form_id: 46, extra_qs:"", return_path: guarantees_path }
  end

  def circles_validation
  end

  def list_register
    render :form_iframe, locals: { title: "Listas autonómicas", form_id: 20, extra_qs:"" }
  end
  
  def offer_hospitality
    render :form_iframe, locals: { title: "Comparte tu casa", form_id: 6, extra_qs:"", return_path: root_path }
  end
  def find_hospitality
    render :formview_iframe, locals: { title: "Encuentra alojamiento", url: "https://forms.podemos.info/encuentra-alojamiento/"}
  end
  def share_car
    render :form_iframe, locals: { title: "Comparte tu coche", form_id: 13, extra_qs:"", return_path: root_path }
  end
  def find_car
    render :formview_iframe, locals: { title: "Encuentra coche", url: "https://forms.podemos.info/encuentra-viaje/"}
  end

  def town_legal
    render :form_iframe, locals: { title: "Responsables municipales de finanzas y legal", form_id: 14, extra_qs:"" }
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
    render :form_iframe, locals: { title: "Solicitud en envío de boletín por correo electrónico", form_id: 62, extra_qs:"" }
  end

  def credits_status
    Rails.cache.fetch("credits_status", expires_in: 2.minutes) do
      credits = []
      CSV.foreach( "#{Rails.root}/db/podemos/credits.tsv", { :col_sep => "\t"} ) do |c|
        credits << c.map {|i| i.to_i }
      end
      credits
    end
  end

  def credits
    @credits = self.credits_status
    @totals = [@credits.map {|c| c[0]*c[1]} .inject(:+) ]
    @totals << @credits.map {|c| c[0]*c[2]} .inject(:+) 
  end

  def credits_add
    credits_param=self.credits_status.map {|c| [c[1], c[1]-c[2]]} .flatten.join ","
    render :form_iframe, locals: { title: "Microcréditos Podemos - Elecciones al Parlamento de Andalucía", form_id: 25, extra_qs: "&hash=#{SecureRandom.random_number(10000000000)}&credits=#{credits_param}" }
  end

  def credits_info
  end
end
