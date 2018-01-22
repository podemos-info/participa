class Microcredit < ActiveRecord::Base
  include FlagShihTzu

  has_flags 1 => :mailing


  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  acts_as_paranoid
  has_many :loans, class_name: "MicrocreditLoan"

  has_attached_file :renewal_terms

  validates_attachment_content_type :renewal_terms, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_size :renewal_terms, less_than: 2.megabyte
 
  # example: "100€: 100\r500€: 22\r1000€: 10"
  validates :limits, format: { with: /\A(\D*\d+\D*\d+\D*)+\z/, message: "Introduce pares (monto, cantidad)"}
  validate :check_limits_with_phase

  scope :active, -> {where("? between starts_at and ends_at", DateTime.now)}
  scope :upcoming_finished, -> { where("ends_at > ? AND starts_at < ?", 7.days.ago, 1.day.from_now).order(:title)}
  scope :non_finished, -> { where("ends_at > ?", DateTime.now) }
  scope :renewables, -> { where.not( renewal_terms_file_name: nil ) }
  scope :standard, ->{where("flags = 0")}
  scope :mailing, ->{where("flags = 1")}
  def is_standard?
    (!self.mailing)
  end
  def is_mailing?
    (self.mailing)
  end
  def is_active?
    ( self.starts_at .. self.ends_at ).cover? DateTime.now
  end

  def is_upcoming?
    self.starts_at > DateTime.now and self.starts_at < 1.day.from_now
  end

  def has_finished?
    self.ends_at < DateTime.now
  end

  def recently_finished?
    self.ends_at > 7.days.ago and self.ends_at < DateTime.now 
  end

  def limits
    @limits ||= parse_limits self[:limits]
  end

  def limits=(l)
    self[:limits] = l
    @limits = parse_limits self[:limits]
  end

  def single_limit
    @limits
  end
  
  def method_missing(name, *args, &blk)
    if name.to_s.start_with? "single_limit_"
      amount = name[13..-1].to_i
      if @limits.include? amount
        @limits[amount]
      end
    else
      super
    end
  end

  def parse_limits limits_string
    Hash[* limits_string.scan(/\d+/).map {|x| x.to_i} ] if limits_string
  end

  def campaign_status
    # field IS NOT NULL returns integer on SQLite and boolean in postgres, so both values are checked and converted to boolean
    @campaign_status ||= loans.group(:amount, "confirmed_at IS NOT NULL", "counted_at IS NOT NULL", "discarded_at IS NOT NULL").pluck(:amount, "confirmed_at IS NOT NULL", "counted_at IS NOT NULL", "discarded_at IS NOT NULL", "COUNT(*)").sort_by(&:first).map {|x| [x[0], (x[1]==true||x[1]==1), (x[2]==true||x[2]==1), (x[3]==true||x[3]==1), x[4]] }
  end

  def phase_status
    # field IS NOT NULL returns integer on SQLite and boolean in postgres, so both values are checked and converted to boolean
    @phase_status ||= loans.phase.group(:amount, "confirmed_at IS NOT NULL", "counted_at IS NOT NULL", "discarded_at IS NOT NULL").pluck(:amount, "confirmed_at IS NOT NULL", "counted_at IS NOT NULL", "discarded_at IS NOT NULL", "COUNT(*)").sort_by(&:first).map {|x| [x[0], (x[1]==true||x[1]==1), (x[2]==true||x[2]==1), (x[3]==true||x[3]==1), x[4]] }
  end

  def remaining_percent
    time = 1-[ [(DateTime.now.to_f-starts_at.to_f) / (ends_at.to_f-starts_at.to_f), 0.0].max, 1.0].min
    progress = 1-[ [1.0*self.campaign_counted_amount / self.total_goal, 0.0].max, 1.0].min
    progress*time
  end

  def current_percent amount
    current = campaign_status.collect {|x| x[4] if x[0]==amount and not x[1] and (not x[3] or x[2])} .compact.sum
    current_counted = campaign_status.collect {|x| x[4] if x[0]==amount and not x[1] and x[2]} .compact.sum
    current==0 ? 0.0 : 1.0*current_counted/current
  end

  def next_percent amount
    current = campaign_status.collect {|x| x[4] if x[0]==amount and not x[1] and (not x[3] or x[2])} .compact.sum
    current_counted = campaign_status.collect {|x| x[4] if x[0]==amount and not x[1] and x[2]} .compact.sum
    current==0 ? 1.0 : (current_counted+1.0)/(current)
  end

  def has_amount_available? amount
    current = phase_status.collect {|x| x[4] if x[0]==amount and x[2] } .compact.sum
    limits[amount] and limits[amount] > current
  end

  def should_count? amount, confirmed
    # check that there is any remaining loan for this amount and phase
    remaining = phase_remaining(amount)
    return false if (remaining.none? || remaining.first.last<=0)
    
    if confirmed
      return true
    else
      next_percent(amount)<self.remaining_percent
    end
  end

  def phase_current_for_amount amount
    phase_status.collect {|x| x[4] if x[0]==amount and x[2]} .compact.sum
  end

  def phase_remaining filter_amount=nil
    limits.map do |amount, limit|
      [amount, [0, limit-phase_status.collect {|x| x[4] if x[0]==amount and x[2]} .compact.sum].max ] if filter_amount.nil? or filter_amount==amount
    end .compact
  end

  def phase_limit_amount
    limits.map do |k,v| k*v end .sum
  end

  def check_limits_with_phase
    if self.limits.any? { |amount, limit| limit < self.phase_current_for_amount(amount) }
      self.errors.add(:limits, "No puedes establecer un limite para un monto por debajo de los microcréditos visibles en la web con ese monto en la fase actual.")
    end
  end

  def phase_counted_amount
    phase_status.collect {|x| x[0]*x[4] if x[2] } .compact.sum
  end

  def campaign_created_amount
    campaign_status.collect {|x| x[0]*x[4] } .compact.sum
  end

  def campaign_unconfirmed_amount
    campaign_status.collect {|x| x[0]*x[4] if not x[1] } .compact.sum
  end

  def campaign_confirmed_amount
    campaign_status.collect {|x| x[0]*x[4] if x[1] } .compact.sum
  end

  def campaign_not_counted_amount
    campaign_status.collect {|x| x[0]*x[4] if not x[2] } .compact.sum
  end

  def campaign_counted_amount
    campaign_status.collect {|x| x[0]*x[4] if x[2] } .compact.sum
  end

  def campaign_discarded_amount
    campaign_status.collect {|x| x[0]*x[4] if x[3] } .compact.sum
  end

  def campaign_created_count
    campaign_status.collect {|x| x[4] } .compact.sum
  end

  def campaign_unconfirmed_count
    campaign_status.collect {|x| x[4] if not x[1] } .compact.sum
  end

  def campaign_confirmed_count
    campaign_status.collect {|x| x[4] if x[1] } .compact.sum
  end

  def campaign_not_counted_count
    campaign_status.collect {|x| x[4] if not x[2] } .compact.sum
  end

  def campaign_counted_count
    campaign_status.collect {|x| x[4] if x[2] } .compact.sum
  end

  def campaign_discarded_count
    campaign_status.collect {|x| x[4] if x[3] } .compact.sum
  end

  def completed
    self.campaign_confirmed_amount>=self.total_goal
  end

  def change_phase!
    if self.update_attribute(:reset_at, DateTime.now)
      self.clear_cache
      self.loans.where.not(confirmed_at:nil).where(counted_at:nil).each do |loan|
        loan.update_counted_at
      end
    end
  end

  def slug_candidates
    [
      :title,
      [:title, DateTime.now.year],
      [:title, DateTime.now.year, DateTime.now.month],
      [:title, DateTime.now.year, DateTime.now.month, DateTime.now.day]
    ]
  end

  def self.total_current_amount
    Microcredit.upcoming_finished.sum(:total_goal)
  end

  def subgoals
    @subgoals ||= YAML.load(self[:subgoals]) if self[:subgoals]
  end

  def renewable?
    self.has_finished? && self.renewal_terms.exists?
  end

  def clear_cache
    @subgoals = @phase_status = @campaign_status = nil
  end
end
