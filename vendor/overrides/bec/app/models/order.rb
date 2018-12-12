
require_dependency Rails.root.join('app', 'models', 'order').to_s

class Order

  if Rails.application.secrets.features["collaborations_redsys"]
    PAYMENT_TYPES = {
      I18n.t('podemos.collaboration.order.cc') => 1, 
      I18n.t('podemos.collaboration.order.iban') => 3 
    }
  else
    PAYMENT_TYPES = {
      I18n.t('podemos.collaboration.order.iban') => 3 
    }
  end


end
