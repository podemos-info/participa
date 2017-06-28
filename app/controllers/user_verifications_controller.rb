class UserVerificationsController < InheritedResources::Base

  private

    def user_verification_params
      params.require(:user_verification).permit(:user_id, :author_id, :procesed_at, :result)
    end
end

