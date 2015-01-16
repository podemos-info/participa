class ProposalsController < ApplicationController

  def index
    @proposals = Proposal.reddit_proposals(params[:filter])
  end

  def show
    @proposal = Proposal.reddit_proposal(params[:reddit_id])
  end

end