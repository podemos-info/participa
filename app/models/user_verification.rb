class UserVerification < ActiveRecord::Base
  belongs_to :user, -> { with_deleted }

  has_attached_file :front_vatid
  has_attached_file :back_vatid

  validates :user, presence: true

  scope :pending, -> {where(result: nil)}
  scope :passed, -> {where(result: true)}
  scope :failed, -> {where(result: false)}

  def files_folder
    "#{Rails.application.root}/non-public/system/user_verifications/#{id_partition}/"
  end

end
