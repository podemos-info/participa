class ErrorsController < ApplicationController

  def show
    @code = params[:code] || 500
  end
end
