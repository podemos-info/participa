class NoticeController < ApplicationController

  def index
    @notices = Notice.page params[:page]
  end

end
