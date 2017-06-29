class UserVerification < ActiveRecord::Base
  belongs to :user, -> { with_deleted }

  validates :user, uniqueness: {scope: :user}, allow_blank: false, allow_nil: false

  scope :needed, -> {where(result: nil)}
  scope :passed, -> {where(result: true)}
  scope :failed, -> {where(result: false)}

  def files_folder
    "#{Rails.application.root}/non-public/system/verification_vatid/#{id}/"
  end

end
