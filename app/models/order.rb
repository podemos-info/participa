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

  def self.by_month(date)
    # Recieves a DateTime object, returns Orders for all the month
    # dt = DateTime.new(2014,12,1) 
    # Order.payable_by_date_month(dt)
    date_start = date.beginning_of_month
    date_end = date.end_of_month
    where("payable_at >= ? and payable_at <= ?", date_start, date_end)
  end

  def self.by_month_count(date)
    self.by_month(date).count
  end

  def self.by_month_amount(date)
    self.by_month(date).includes(:collaboration).sum(:amount) / 100.0
  end

  def self.by_collaboration_period(collaboration, date=DateTime.now)
    date_start = date.beginning_of_month - (collaboration.frequency-1).months
    date_end = date.end_of_month
    where(collaboration_id: collaboration.id, payable_at: (date_start..date_end)).limit(1)[0]
  end

end
