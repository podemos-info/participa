class UserVerification < ActiveRecord::Base
  belongs_to :user, -> { with_deleted }

  has_attached_file :front_vatid, path: ":rails_root/non-public/system/:class/:attachment/:id_partition/:style/:filename", styles: { thumb: ["450x300#", :png] }
  has_attached_file :back_vatid, path: ":rails_root/non-public/system/:class/:attachment/:id_partition/:style/:filename", styles: { thumb: ["450x300#", :png] }

  validates :user, :front_vatid, presence: true
  validates :back_vatid, presence: true, if: :require_back?
  validates :terms_of_service, acceptance: true

  validates_attachment_content_type :front_vatid, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :back_vatid, content_type: /\Aimage\/.*\z/

  validates_attachment_size :front_vatid, :back_vatid, less_than: 1.megabyte

  after_validation do
    errors.each do |attr|
      if attr.to_s.starts_with?("front_vatid_") || attr.to_s.starts_with?("back_vatid_")
        errors.delete(attr)
      end
    end
  end

  scope :pending, -> {where(result: nil)}
  scope :passed, -> {where(result: true)}
  scope :failed, -> {where(result: false)}

  def require_back?
    !user.is_passport?
  end

  def self.for(user, params = {})
    current = self.pending.where(user:user).first
    if current
      current.assign_attributes(params)
    else
      UserVerification.new params.merge(user: user)
    end
    current
  end
end
