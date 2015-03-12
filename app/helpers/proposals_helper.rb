module ProposalsHelper

  def time_left(proposal)
    distance_of_time_in_words(proposal.finishes_at, Time.now)
  end

  def formatted_description(proposal)
    auto_link(proposal.description, html: { target: '_blank' }) do |text|
      simple_format(text)
    end
  end

  def formatted_support_count(proposal)
    number_with_delimiter(@proposal.supports.count) + 
    " de " +
    number_with_delimiter(proposal.agoravoting_required_votes)
  end

  def formatted_support_percentage(proposal, options={})
    number_to_percentage(proposal.support_percentage, options)
  end

  def support_button
    "#support_proposal_#{@proposal.id} input[type=submit]"
  end

  def filtered_proposals(text, filter)
    link_to text, proposals_path(filter: filter), :class => active?(filter)
  end

  def active?(filter)
    params[:filter] == filter ? 'active' : ''
  end

end