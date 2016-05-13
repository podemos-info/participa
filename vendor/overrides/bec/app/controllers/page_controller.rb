require_dependency Rails.root.join('app', 'controllers', 'page_controller').to_s

class PageController < ApplicationController

  def votacio_preacord
    render layout: 'minimal'
  end

end
