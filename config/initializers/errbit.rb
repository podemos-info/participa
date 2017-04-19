if Rails.env.production?
  Airbrake.configure do |config|
    airbrake_secrets = Rails.application.secrets.airbrake

    protocol = "http#{airbrake_secrets['port'].to_i == 443 ? 's' : ''}"
    host = airbrake_secrets['host']
    port = airbrake_secrets['port']

    config.project_key = airbrake_secrets["api_key"]
    config.host = "#{protocol}://#{host}:#{port}"
    config.project_id = 1
  end
end
