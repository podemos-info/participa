class ImpulsaMailer < ActionMailer::Base
  def on_spam(project)
    @edition_email = project.impulsa_edition.email
    mail(
      from: project.impulsa_edition.email,
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Proyecto desestimado'
    )
  end

  def on_fixes(project)
    @fixes_limit = I18n.l(project.impulsa_edition.review_projects_until.to_date-1.second, format: :long)
    @edition_email = project.impulsa_edition.email
    @project_url = project_impulsa_url

    mail(
      from: project.impulsa_edition.email,
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Necesaria subsanación'
    )
  end

  def on_validable(project)
    mail(
      from: project.impulsa_edition.email,
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Tu proyecto ha sido revisado y está completo'
    )
  end

  def on_invalidated(project)
    @evaluation_url = evaluation_impulsa_url
    mail(
      from: project.impulsa_edition.email,
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Tu proyecto no ha superado la fase de evaluación'
    )
  end

  def on_validated(project)
    @evaluation_url = evaluation_impulsa_url
    @voting_dates = project.voting_dates if project.impulsa_edition_category.has_votings
    @winners = project.impulsa_edition_category.winners

    mail(
      from: project.impulsa_edition.email,
      to: project.user.email,
      subject: '[PODEMOS IMPULSA] Tu proyecto ha superado la fase de evaluación'
    )
  end
end
  
