class Order < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  acts_as_paranoid
  has_paper_trail

  belongs_to :collaboration

  validates :collaboration_id, :payable_at, presence: true

  after_create :set_as_due

  STATUS = [["pendiente", 1], ["pagado", 2], ["error", 3]]

  def set_as_due
    self.status = 1
    self.save
  end

  def mark_as_payed_on!(date)
    self.status = 2 
    self.payed_at = date
    self.save
  end

  def status_name
    Order::STATUS.select{|v| v[1] == self.status }[0][0]
  end

  def receipt
    # TODO order receipt
    # Es el identificador del cargo a todos los efectos y no se ha de repetir en la remesa y en las remesas sucesivas. Es un nº correlativo
  end

  def due_code
    # CÓDIGO DE ADEUDO  Se pondra FRST cuando sea el primer cargo desde la fecha de alta, y RCUR en los siguientes sucesivos
    # TODO codigo de adeudo
    "TODO"
  end

  def url_source
    # URL FUENTE  "Este campo no se si existira en el nuevo entorno. Si no es asi poner por defecto https://podemos.info/participa/colaboraciones/colabora/
    # TODO url_source
    "https://podemos.info/participa/colaboraciones/colabora/"
  end

  def concept
    # COMPROBACIÓN  Es el texto que aparecefrá en el recibo. Sera "Colaboracion "mes x"
    # TODO comprobación / concepto
    "Colaboración mes de XXXX"
  end

  def admin_permalink
    admin_order_path(self)
  end

end
