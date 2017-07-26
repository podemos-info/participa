class UserVerification < ActiveRecord::Base
  belongs_to :user, -> { with_deleted }

  has_paper_trail

  has_attached_file :front_vatid, path: ":rails_root/non-public/system/:class/:attachment/:id_partition/:style/:filename", styles: { thumb: ["450x300#", :png] }
  has_attached_file :back_vatid, path: ":rails_root/non-public/system/:class/:attachment/:id_partition/:style/:filename", styles: { thumb: ["450x300#", :png] }

  validates :user, :front_vatid, presence: true #, unless: :not_require_photos?
  validates :back_vatid, presence: true, if: :require_back? #, unless: :not_require_photos?
  validates :terms_of_service, acceptance: true

  validates_attachment_content_type :front_vatid, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :back_vatid, content_type: /\Aimage\/.*\z/

  validates_attachment_size :front_vatid, :back_vatid, less_than: 6.megabyte

  #after_initialize :push_id_to_processing_list

  after_validation do
    errors.each do |attr|
      if attr.to_s.starts_with?("front_vatid_") || attr.to_s.starts_with?("back_vatid_")
        errors.delete(attr)
      end
    end
  end

  enum status: {pending: 0, accepted: 1, issues: 2, rejected: 3, accepted_by_email: 4}

  #scope :pending, -> {where(status: :pending)}
  #scope :accepted, -> {where(status: :accepted)}
  #scope :issues, -> {where(status: :issues)}
  #scope :rejected, -> {where(status: :rejected)}
  #scope :accepted_by_email, -> {where(status: :accepted_by_email)}

  def require_back?
    !user.is_passport?
  end

  def not_require_photos?
    user.photos_unnecessary?
  end
  def self.for(user, params = {})
    current = self.where(" user_id = ? and (status  = 0 or status = 3)",user.id).first
    if current
      current.assign_attributes(params)
    else
      current = UserVerification.new params.merge(user: user)
    end
    current
  end

  def push_id_to_processing_list
    $redis = $redis || Redis::Namespace.new("podemos_queue_validator", :redis => Redis.new)
    array_ids=$redis.lrange("processing",0,-1)
    if :id.in?(array_ids)
      $redis.rpush("processing",:id)
    else

    end
  end

end
