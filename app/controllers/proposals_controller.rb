class ProposalsController < ApplicationController

  def index
    params[:filter] ||= "popular"
    @proposals = Proposal.filter(params[:filter])
    @hot = Proposal.reddit.hot.limit(3)
  end

  def show
    @proposal = Proposal.reddit.find(params[:id])
  end

  def info
  end

end
