class ProposalsController < ApplicationController

  def index
    @proposals = Proposal.reddit
  end

  def show
    @proposal = Proposal.reddit_proposal(params[:reddit_id])
  end

end