module ProposalsHelper

  def time_left(proposal)
    distance_of_time_in_words(proposal.created_at, proposal.finishes_at)
  end

end