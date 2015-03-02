module ProposalsHelper

  def time_left(proposal)
    distance_of_time_in_words(proposal.created_at, proposal.finishes_at)
  end

  def formatted_description(proposal)
    auto_link(proposal.description, html: { target: '_blank' }) do |text|
      simple_format(text)
    end
  end

end