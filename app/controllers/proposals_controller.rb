class ProposalsController < ApplicationController

  def index
    @proposals = Proposal.filter(params[:filter])
    @hot = Proposal.hot.limit(3)
  end

  def show
    @proposal = Proposal.find(params[:id])
  end

  def info
  end

end