class SessionsController < Devise::SessionsController
  def new
    @upcoming_election = Election.upcoming_finished.first
    super
  end

end