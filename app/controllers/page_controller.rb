require 'securerandom'
class PageController < ApplicationController

  before_action :authenticate_user!, except: [:privacy_policy, :faq, :guarantees, :guarantees_conflict, :guarantees_compliance, 
                                              :guarantees_ethic, :circles_validation, :primarias_andalucia, :listas_primarias_andaluzas,
                                              :responsables_organizacion_municipales, :credits, :credits_add, :credits_info,
                                              :responsables_municipales_andalucia, :plaza_podemos_municipal]

  def privacy_policy
  end

  def faq
  end

  def guarantees
  end

  def guarantees_conflict
  end

  def guarantees_compliance
  end

  def guarantees_ethic
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

  def credits_status
    Rails.cache.fetch("credits_status", expires_in: 2.minutes) do
      credits = []
      CSV.foreach( "#{Rails.root}/db/podemos/credits.tsv", { :col_sep => "\t"} ) do |c|
        break if c[0].nil? or c[1].nil? or c[2].nil?
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
