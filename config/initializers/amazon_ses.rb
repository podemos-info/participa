ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  server:  Rails.application.secrets.aws_ses["server"],
  access_key_id: Rails.application.secrets.aws_ses["access_key_id"],
  secret_access_key: Rails.application.secrets.aws_ses["secret_access_key"]
