  class ElectionLocationQuestion < ActiveRecord::Base
  belongs_to :election_location

  VOTING_SYSTEMS = { "plurality-at-large" => "Elección entre todas las respuestas", "pairwise-beta" => "Comparaciones uno a uno (requiere layout simple)" }
  TOTALS = { "over-total-valid-votes" => "Sobre votos válidos" }

  validates :title, :voting_system, :winners, :minimum, :maximum, :totals, :options, presence: true

  after_initialize do
    if self.title.blank?
      self.voting_system = VOTING_SYSTEMS.keys.first
      self.totals = TOTALS.keys.first
      self.random_order = true
      self.winners = 1
      self.minimum = 0
      self.maximum = 1
    end
  end

  def layout
    if self.voting_system=="pairwise-beta"
      "simple"
    elsif ElectionLocation::ELECTION_LAYOUTS.member? election_location.layout
      ""
    else
      election_location.layout
    end
  end

  def self.headers
    @@headers ||= Rails.application.secrets.agora["options_headers"]
  end

  def options_headers
    if self[:options_headers]
      self[:options_headers].split("\t") 
    else
      ElectionLocationQuestion.headers.keys[0..0] 
    end
  end

  def options_headers= value
    if value
      vs = value.select(&:present?) 
      self[:options_headers] = vs.join("\t") if vs.length>0
    end
  end

  def options= value
    line_length = self.options_headers.length
    opt = []
    value.strip.split("\n").each do |line|
      fields = line.strip.split("\t")
      opt << fields.map(&:strip).join("\t") if fields.length>0
    end
    self[:options] = opt.join("\n")
  end
end
