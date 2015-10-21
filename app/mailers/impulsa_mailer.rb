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
    @invalid_reasons = project.evaluator2_invalid_reasons
    mail(
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Proyecto invalidado'
    )
  end

  def on_validated1(project)
    @voting_dates = project.votings_dates
    @winners = project.impulsa_edition_category.winners
    @prewinners = project.impulsa_edition_category.prewinners

    mail(
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Proyecto validado en la categoría "Impulsa tu país"'
    )
  end

  def on_validated2(project)
    @voting_dates = project.votings_dates
    mail(
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Proyecto validado en la categoría "Impulsa tu entorno"'
    )
  end
end
  
