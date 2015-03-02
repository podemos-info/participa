class ProposalsController < ApplicationController

  def index
    @proposals = Proposal.reddit
  end

  def show
    @proposal = Proposal.find(params[:id])
  end

end