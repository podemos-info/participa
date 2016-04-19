
require_dependency Rails.root.join('app', 'models', 'collaboration').to_s

class Collaboration

  FREQUENCIES = {
    I18n.t('podemos.collaboration.freq.first') => 1,
    I18n.t('podemos.collaboration.freq.second') => 3, 
    I18n.t('podemos.collaboration.freq.third') => 12
  }

end
