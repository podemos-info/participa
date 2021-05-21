class UsersMailer < ActionMailer::Base
  default from: Rails.application.secrets[:default_from_email]

  def microcredit_email(microcredit, loan, brand_config)
    @microcredit = microcredit
    @microcredit.title = @microcredit.title.gsub('#','')
    @loan = loan
    @brand_config = brand_config
    pdf_name = "IngresoMicrocreditos#{@brand_config["name"]}.pdf"
    attachments[pdf_name] = WickedPdf.new.pdf_from_string(render_to_string pdf: pdf_name, template: 'microcredit/email_guide.pdf.erb', encoding: "UTF-8")
    mail(from: @brand_config["mail_from"], to: @loan.email, subject: t("microcredit.email.subject", name: @brand_config["name"]))
  end

  def remember_email(type, query)
    case type
    when :email
      @user = User.find_by_email query
    when :document_vatid
      @user = User.find_by_document_vatid query
    else
      @user = User.find_by_email query
    end
    mail(
      from: Rails.application.secrets["default_from_email"],
      to: @user.email,
      subject: '[participa.podemos.info] Has intentado registrarte de nuevo'
    )
  end

  def new_militant_email(user_id)
  @user_email = User.find(user_id).email
  mail(
    from: "soportemilitantes@podemos.info",
    to: @user_email,
    subject: 'Enhorabuena, ya eres militante de Podemos'
  )
  end

  def cancel_account_email(user_id)
    @user = User.find(user_id)
    mail(
      from: Rails.application.secrets["default_from_email"],
      to: @user.email,
      bcc: 'bajas@podemos.info',
      subject: 'Te has dado de baja de Podemos'
    )
  end
end
  
