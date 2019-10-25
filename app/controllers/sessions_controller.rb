class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
  skip_before_action :verify_authenticity_token, only: [:destroy]

  def new
    @upcoming_election = Election.upcoming_finished.show_on_index.first
    super
  end

  def after_login
    current_user.imperative_verification&.update(priority: 1)
  end
end