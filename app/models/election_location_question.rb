class ElectionLocationQuestion < ActiveRecord::Base
  belongs_to :election_location

  VOTING_SYSTEMS = { "plurality-at-large" => "Elección entre todas las respuestas", "pairwise-beta" => "Comparaciones uno a uno (requiere layout simple)" }
  TOTALS = { "over-total-valid-votes" => "Sobre votos válidos" }

end
