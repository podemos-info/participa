module Api::V2
  class UsersController < ::ApplicationController

    skip_before_filter :verify_authenticity_token
    before_action -> { doorkeeper_authorize! :public }, only: :show

    def show
      render json: current_resource_owner.to_json(only: [:id, :admin, :email], methods: [:username, :full_name])
    end

    private

    # Find the user that owns the access token
    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

  end
end
