class ImpulsaProject < ActiveRecord::Base
  include ImpulsaProjectStates
  include ImpulsaProjectWizard
  include ImpulsaProjectEvaluation

  belongs_to :impulsa_edition_category
  belongs_to :user, -> { with_deleted }
  has_one :impulsa_edition, through: :impulsa_edition_category
  has_many :impulsa_project_state_transitions, dependent: :destroy


  validates :name, :impulsa_edition_category_id, :status, presence: true
  validates :user, uniqueness: {scope: :impulsa_edition_category}, allow_blank: false, allow_nil: false, unless: Proc.new { |project| project.user.nil? || project.user.impulsa_author? }
  
  validates :terms_of_service, :data_truthfulness, :content_rights, acceptance: true
  
  scope :by_status, ->(status) { where( status: status ) }

  scope :first_phase, -> { where( status: [ 0, 1, 2, 3 ] ) }
  scope :second_phase, -> { where( status: [ 4, 6 ]) }
  scope :no_phase, -> { where status: [ 5, 7, 10 ] }
  scope :votable, -> { where status: 6 }
  scope :public_visible, -> { where status: [ 9, 6, 7 ]}

  def method_missing(method_sym, *arguments, &block)
    ret = wizard_method_missing(method_sym, *arguments, &block)
    return ret if ret!=:super
    ret = evaluation_method_missing(method_sym, *arguments, &block)
    return ret if ret!=:super
    super
  end

  def voting_dates
    "#{I18n.l(self.impulsa_edition.votings_start_at.to_date, format: :long)} al #{I18n.l(self.impulsa_edition.ends_at.to_date, format: :long)}"
  end
end