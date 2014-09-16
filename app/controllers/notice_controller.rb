class NoticeController < ApplicationController

  def index
    @notices = Notice.all
  end

end
