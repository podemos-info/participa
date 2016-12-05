# https://github.com/resque/resque#configuration
redis_config = Rails.application.config_for(:redis)
Resque.redis = "#{redis_config['host']}:#{redis_config['port']}"
