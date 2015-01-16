class ProposalsController < ApplicationController

  def index
    @proposals = Proposal.reddit_proposals
  end

end