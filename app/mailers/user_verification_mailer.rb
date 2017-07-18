class UserVerificationMailer < ActionMailer::Base
  def on_accepted(user_id)
    @user_email = User.find(user_id).email
    mail(
        from: "verificaciones@soporte.podemos.info",
        to: @user_email,
        subject: 'Podemos, Datos verificados'
    )
  end

  def on_rejected(user_id)
    @user_email = User.find(user_id).email

    mail(
        from: "verificaciones@soporte.podemos.info",
        to: @user_email,
        subject: 'Podemos, no hemos podido realizar la verificación'
    )
  end
end




