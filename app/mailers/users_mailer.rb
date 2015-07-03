class UsersMailer < ActionMailer::Base
  default from: Rails.application.secrets[:default_from_email]

  def microcredit_email(microcredit, loan)
    @microcredit = microcredit
    @loan = loan
    attachments['IngresoMicrocreditosPodemos.pdf'] = WickedPdf.new.pdf_from_string(render_to_string pdf: 'IngresoMicrocreditosPodemos.pdf', template: 'microcredit/email_guide.pdf.erb', encoding: "UTF-8")
    mail(from: '"Podemos" <microcreditos@podemos.info>', to: @loan.email, subject: 'Confirmación microcréditos Podemos')
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
      subject: '[participa.podemos.info] Has intentado de registrarte de nuevo'
    )
  end
end
  
