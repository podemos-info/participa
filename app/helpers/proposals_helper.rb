module ProposalsHelper

  def time_left(proposal)
    distance_of_time_in_words(proposal.finishes_at, Time.now)
  end

  def formatted_description(proposal)
    auto_link(proposal.description, html: { target: '_blank' }) do |text|
      simple_format(text)
    end
  end

  def support_button
    "#support_proposal_#{@proposal.id} input[type=submit]"
  end

end