class ImpulsaMailer < ActionMailer::Base
  default from: Rails.application.secrets.impulsa["from_email"]

  def on_spam(project)
    mail(
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Proyecto desestimado'
    )
  end

  def on_fixes(project)
    @fixes_limit = I18n.l(project.impulsa_edition.review_projects_until.to_date, format: :medium)
    @project_url = edit_impulsa_url

    mail(
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Necesaria subsanación'
    )
  end

  def on_validable(project)
    mail(
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Tu proyecto ha sido revisado y está completo'
    )
  end

  def on_invalidated(project)
    mail(
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Proyecto invalidado'
    )
  end

  def on_validated1(project)
    @voting_dates = "#{I18n.l(project.impulsa_edition.validation_projects_until.to_date, format: :medium)} al #{I18n.l(project.impulsa_edition.ends_at.to_date, format: :medium)}"
    @winners = project.winners
    @prewinners = project.prewinners

    mail(
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Proyecto validado en la categoría "Impulsa tu país"'
    )
  end

  def on_validated2(project)
    @voting_dates = "#{I18n.l(project.impulsa_edition.validation_projects_until.to_date, format: :medium)} al #{I18n.l(project.impulsa_edition.ends_at.to_date, format: :medium)}"
    mail(
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Proyecto validado en la categoría "Impulsa tu entorno"'
    )
  end
end
  
