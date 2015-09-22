class ImpulsaMailer < ActionMailer::Base
  default from: Rails.application.secrets[:default_from_email]

  def on_review(id_project_impulsa)
    mail(
      from: Rails.application.secrets["default_from_email"],
      to: current_user.email,
      subject: '[PODEMOS IMPULSA] Inscripción realizada correctamente'
    )
  end

  def on_fixes(id_project_impulsa)
    mail(
      from: Rails.application.secrets["default_from_email"],
      to: current_user.email,
      subject: '[PODEMOS IMPULSA] Necesaria subsanación'
    )
  end

  def on_validate1(id_project_impulsa)
    mail(
      from: Rails.application.secrets["default_from_email"],
      to: current_user.email,
      subject: '[PODEMOS IMPULSA] Proyecto Validado en la categoría 1 Impulsa tu país.'
    )
  end

  def on_validate2(id_project_impulsa)
    mail(
      from: Rails.application.secrets["default_from_email"],
      to: current_user.email,
      subject: '[PODEMOS IMPULSA] Proyecto Validado en la categoría 2 Impulsa tu entorno'
    )
  end

  def on_invalidated(id_project_impulsa)
    mail(
      from: Rails.application.secrets["default_from_email"],
      to: current_user.email,
      subject: '[PODEMOS IMPULSA] Proyecto Invalidado'
    )
  end
end
  
