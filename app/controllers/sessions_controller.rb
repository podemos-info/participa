class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create

  def new
    @upcoming_election = Election.upcoming_finished.show_on_index.first
    super
  end

  def after_login
    current_user.imperative_verification&.update(priority: 1)
  end
end