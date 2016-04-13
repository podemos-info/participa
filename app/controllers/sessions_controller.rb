class SessionsController < Devise::SessionsController
  def new
    @upcoming_election = Election.upcoming_finished.show_on_index.first
    super
  end

end