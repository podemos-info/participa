class ProposalsController < ApplicationController

  def index
    @proposals = Proposal.reddit
    @hot = Proposal.reddit.hot
  end

  def show
    @proposal = Proposal.find(params[:id])
  end

end