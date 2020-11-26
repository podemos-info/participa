module Airbrake
  def self.notify_or_raise ex
    if self.configuration.api_key
      self.notify ex
    else
      raise ex
    end
  end
end