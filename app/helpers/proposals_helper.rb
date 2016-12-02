module ProposalsHelper

  def time_left(proposal)
    distance_of_time_in_words_to_now(proposal.finishes_at)
  end

  def formatted_created_at(proposal)
    distance_of_time_in_words_to_now(proposal.created_at)
  end

  def formatted_description(proposal)
    auto_link(simple_format(proposal.description), :html => { :target => "_blank" })
  end

  def formatted_support_count(proposal)
    number_with_delimiter(@proposal.supports_count) + 
    " de " +
    number_with_delimiter(proposal.agoravoting_required_votes)
  end

  def formatted_support_percentage(proposal, options={})
    number_to_percentage(proposal.support_percentage, options)
  end

  def proposal_image(proposal)
    proposal.image_url.present? ? proposal.image_url : "proposal-example.jpg"
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