class VerificationMailer < ActionMailer::Base
  layout "email"
  default from: Rails.application.secrets.default_from_email

  # user is verified
  def verified user
    @user = user
    mail(to: @user.email, subject: t('verification.mailer.verified.subject'))
  end

  # user is verified by SMS (legacy)
  def verified_legacy user
    @user = user
    mail(to: @user.email, subject: t('verification.mailer.verified_legacy.subject'))
  end

  # user needs to verify
  def to_verify user
    @user = user
    mail(to: @user.email, subject: t('verification.mailer.to_verify.subject'))
  end

  def finish user
    @user = user
    mail(to: @user.email, subject: t('verification.mailer.finish.subject'))
  end

end
