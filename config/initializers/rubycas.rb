
Rails.application.config.cas_auth = Rails.application.secrets.admin_access["mode"]=="cas"

if Rails.application.config.cas_auth
  require 'casclient'
  require 'casclient/frameworks/rails/filter'

  CASClient::Frameworks::Rails::Filter.configure(
    Rails.application.secrets.admin_access["settings"].symbolize_keys
  )
end
