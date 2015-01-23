class PageController < ApplicationController

  before_action :authenticate_user!, except: [:privacy_policy, :faq, :guarantees, :guarantees_conflict, :guarantees_compliance, 
                                              :guarantees_ethic, :circles_validation]

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
    render :form_iframe, locals: { title: "Candidaturas autonómicas", form_id: 20 }
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
end
