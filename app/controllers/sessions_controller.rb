class SessionsController < Devise::SessionsController
  after_filter :after_login, :only => :create

  def new
    @upcoming_election = Election.upcoming_finished.show_on_index.first
    super
  end

  def after_login
    v = current_user.verification_to_be_prioritized
    v.update(priority: 1) if v
  end
end