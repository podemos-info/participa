class ElectionLocation < ActiveRecord::Base
  belongs_to :election
  has_many :election_location_questions, -> { order(:id) }, dependent: :destroy

  accepts_nested_attributes_for :election_location_questions, :reject_if => :all_blank, :allow_destroy => true

  validates :title, :layout, :theme, presence: true, if: -> { self.has_voting_info }

  LAYOUTS = { "simple" => "Listado de respuestas simple",
              "accordion" => "Listado de respuestas agrupadas por categoría",
              "pcandidates-election" => "Listado respuestas agrupadas por categoría y pregunta",
              "simultaneous-questions" => "Listado de preguntas con 2 respuestas",
              "2questions-conditional" => "Pregunta con 2 respuestas, si se elige la segunda puede aparecer otra con hasta 4 respuestas"
            }
  ELECTION_LAYOUTS = [ "pcandidates-election", "2questions-conditional" ]

  def self.themes
    @@themes ||= Rails.application.secrets.agora["themes"]
  end

  after_initialize do
    if !self.persisted?
      self.agora_version = 0 if self.agora_version.nil?
      self.new_agora_version = self.agora_version if self.new_agora_version.nil?
      self.location = "00" if self.location.blank?
      self.has_voting_info = false
      self.layout = LAYOUTS.keys.first
      self.theme = ElectionLocation.themes.first
    end
    self.has_voting_info = !self.title.blank?
  end

  def has_voting_info
    @has_voting_info
  end

  def has_voting_info= value
    @has_voting_info = ( value==true || value=="true" || value=="1" )
  end

  before_save do
    if !self.has_voting_info
      self.clear_voting
    end
  end

  def clear_voting
    self.title = self.layout = self.description = self.share_text = self.theme = nil
    self.election_location_questions.destroy_all
  end

  def territory
    begin
      spain = Carmen::Country.coded("ES")
      case election.scope
        when 0 then
          "Estatal"
        when 1 then
          autonomy = Podemos::GeoExtra::AUTONOMIES.values.uniq.select {|a| a[0][2..-1]==location } .first
          autonomy[1]
        when 2 then
          province = spain.subregions[location.to_i-1]
          province.name
        when 3 then
          town = spain.subregions[location[0..1].to_i-1].subregions.coded("m_%s_%s_%s" % [location[0..1], location[2..4], location[5]])
          town.name
        when 4 then
          island = Podemos::GeoExtra::ISLANDS.values.uniq.select {|i| i[0][2..-1]==location } .first
          island[1]
        when 5 then
          "Exterior"
      end + " (#{location})"
    rescue
      location
    end
  end

  def new_version_pending
    agora_version != new_agora_version
  end

  def vote_location
    if election.scope==3
      location[0..4]
    else
      location
    end
  end

  def vote_id
    "#{election.agora_election_id}#{override.blank? ? vote_location : override}#{agora_version}".to_i
  end

  def new_vote_id
    "#{election.agora_election_id}#{override.blank? ? vote_location : override}#{new_agora_version}".to_i
  end

  def link
    "#{election.server_url}booth/#{vote_id}/vote"
  end

  def new_link
    "#{election.server_url}booth/#{new_vote_id}/vote"
  end

  def election_layout
    if ELECTION_LAYOUTS.member? layout
      layout
    else
      ""
    end
  end

  def valid_votes_count
    election.votes.with_deleted.where(agora_id: vote_id).where("deleted_at is null or deleted_at>?", election.ends_at).select(:user_id).distinct.count
  end

  def counter_token
    @counter_token ||= election.generate_access_token("#{created_at.to_i} #{id}")
  end

end
