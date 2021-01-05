class CollaborationsMailer < ActionMailer::Base
  def creditcard_error_email(user)
    @brand_config = Rails.application.secrets.microcredits["brands"][Rails.application.secrets.microcredits["default_brand"]]
    @user = user
    mail(
      from: 'administracion@podemos.info',
      to: user.email,
      subject: 'Problema en el pago con tarjeta de su colaboración'
    ) do |format|
      format.text
      end
  end

  def creditcard_expired_email(user)
    @brand_config = Rails.application.secrets.microcredits["brands"][Rails.application.secrets.microcredits["default_brand"]]
    @user = user
    mail(
        from: 'administracion@podemos.info',
        to: user.email,
        subject: 'Problema en el pago con tarjeta de su colaboración'
    ) do |format|
      format.text
      end
  end

  def receipt_returned(user)
    @brand_config = Rails.application.secrets.microcredits["brands"][Rails.application.secrets.microcredits["default_brand"]]
    @user = user
    mail(
        from: 'administracion@podemos.info',
        to: user.email,
        subject: 'Problema en la domiciliación del recibo de su colaboración'
      ) do |format|
      format.text
      end
  end

  def receipt_suspended(user)
    @brand_config = Rails.application.secrets.microcredits["brands"][Rails.application.secrets.microcredits["default_brand"]]
    @user = user
    mail(
        from: 'administracion@podemos.info',
        to: user.email,
        subject: 'Problema en la domicilación de sus recibos, colaboración suspendida temporalmente'
      ) do |format|
      format.text
      end
  end

  def order_returned_militant(collaboration)
    @brand_config = Rails.application.secrets.microcredits["brands"][Rails.application.secrets.microcredits["default_brand"]]
    @user = collaboration.get_user
    @order = collaboration.order.returned.last
    @payment_day = Order.payment_day
    @month = I18n.localize(@order.created_at, :format => "%B")
    @date = I18n.localize(@order.created_at, :format => "%B %Y")
    mail(
      from: 'colaboraciones@podemos.info',
      to: @user.email,
      subject: "Devolución cuota #{@date}"
    )
  end

  def order_returned_user(collaboration)
    @brand_config = Rails.application.secrets.microcredits["brands"][Rails.application.secrets.microcredits["default_brand"]]
    @user = collaboration.get_user
    @order = collaboration.order.returned.last
    @payment_day = Order.payment_day
    @month = I18n.localize(@order.created_at, :format => "%B")
    @date = I18n.localize(@order.created_at, :format => "%B %Y")
    mail(
      from: 'colaboraciones@podemos.info',
      to: @user.email,
      subject: "Devolución colaboración #{@date}"
    )
  end

  def collaboration_suspended_user(collaboration)
    @brand_config = Rails.application.secrets.microcredits["brands"][Rails.application.secrets.microcredits["default_brand"]]
    @user = collaboration.get_user

    mail(
      from: 'colaboraciones@podemos.info',
      to: @user.email,
      subject: "Suspensión colaboración"
    )
  end

  def collaboration_suspended_militant(collaboration)
    @brand_config = Rails.application.secrets.microcredits["brands"][Rails.application.secrets.microcredits["default_brand"]]
    @user = collaboration.get_user

    mail(
      from: 'colaboraciones@podemos.info',
      to: @user.email,
      subject: "Suspensión cuota"
    )
  end
end
