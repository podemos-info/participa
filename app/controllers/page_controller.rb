class PageController < ApplicationController

  before_action :authenticate_user!, except: [:privacy_policy, :faq, :guarantees, :guarantees_conflict, :guarantees_compliance, 
                                              :guarantees_ethic, :circles_validation, :primarias_andalucia, :listas_primarias_andaluzas]

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
    render :form_iframe, locals: { title: "Listas autonómicas", form_id: 20 }
  end
  
  def offer_hospitality
    render :form_iframe, locals: { title: "Comparte tu casa", form_id: 6, return_path: root_path }
  end
  def find_hospitality
    render :formview_iframe, locals: { title: "Encuentra alojamiento", url: "https://forms.podemos.info/encuentra-alojamiento/"}
  end
  def share_car
    render :form_iframe, locals: { title: "Comparte tu coche", form_id: 13, return_path: root_path }
  end
  def find_car
    render :formview_iframe, locals: { title: "Encuentra coche", url: "https://forms.podemos.info/encuentra-viaje/"}
  end

  def town_legal
    render :form_iframe, locals: { title: "Responsables municipales de finanzas y legal", form_id: 14 }
  end


  def avales_barcelona
    render :form_iframe, locals: { title: "Avales Barcelona", form_id: 22 }
  end

  def primarias_andalucia
    render :form_iframe, locals: { title: "Primarias Andalucía", form_id: 21 }
  end

  def listas_primarias_andaluzas
    render :form_iframe, locals: { title: "Listas Primarias Andalucía", form_id: 23 }
  end
  
end
