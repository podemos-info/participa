ActionMailer::Base.add_delivery_method(:ses,
  credentials: Aws::Credentials.new(
    access_key_id: Rails.application.secrets.aws_ses["access_key_id"],
    secret_access_key: Rails.application.secrets.aws_ses["secret_access_key"]
 ), region: "eu-west-1")