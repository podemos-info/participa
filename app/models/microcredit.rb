class Microcredit < ActiveRecord::Base
  acts_as_paranoid
  has_many :loans, class_name: "MicrocreditLoan"

  # example: "100€: 100\r500€: 22\r1000€: 10"
  validates :limits, format: { with: /\A(\D*\d+\D*\d+\D*)+\z/, message: "Introduce pares (monto, cantidad)"}

  scope :current, -> {where("? between starts_at and ends_at", DateTime.now)}

  def limits
    parse_limits self[:limits]
  end

  def limits=(l)
    self[:limits] = l 
  end

  def parse_limits limits_string
    Hash[* limits_string.scan(/\d+/).map {|x| x.to_i} ]
  end

  def current_remaining
    limits.map do |k,v|
      [k, v-loans.current.where(amount:k).count]
    end
  end

  def current_lent
    loans.current.sum(:amount)
  end

  def current_confirmed
    loans.current.confirmed.sum(:amount)
  end

  def current_limit
    limits.map do |k,v| k*v end .sum
  end

  def total_lent
    loans.sum(:amount)
  end

  def total_confirmed
    loans.confirmed.sum(:amount)
  end

  def reset
    self.reset_at = DateTime.now
    save
  end
end
