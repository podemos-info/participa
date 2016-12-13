Airbrake.configure do |config|
  config.api_key = Rails.application.secrets.airbrake["api_key"]
  config.host    = Rails.application.secrets.airbrake["host"]
  config.port    = Rails.application.secrets.airbrake["port"]
  config.secure  = config.port == 443
end

module Airbrake
  def self.notify_or_raise ex
    if self.configuration.api_key
      self.notify ex
    else
      raise ex
    end
  end
end