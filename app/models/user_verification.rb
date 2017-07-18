class UserVerification < ActiveRecord::Base
  belongs_to :user, -> { with_deleted }

  has_paper_trail

  has_attached_file :front_vatid, path: ":rails_root/non-public/system/:class/:attachment/:id_partition/:style/:filename", styles: { thumb: ["450x300#", :png] }
  has_attached_file :back_vatid, path: ":rails_root/non-public/system/:class/:attachment/:id_partition/:style/:filename", styles: { thumb: ["450x300#", :png] }

  validates :user, :front_vatid, presence: true
  validates :back_vatid, presence: true, if: :require_back?
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

  scope :pending, -> {where(status: 0)}
  scope :accepted, -> {where(status: 1)}
  scope :issues, -> {where(status: 2)}
  scope :rejected, -> {where(status: 3)}

  def require_back?
    !user.is_passport?
  end
  def self.for(user, params = {})
    current = self.where("status  =0 or status = 3",user:user).first
    if current
      current.assign_attributes(params)
      # if the validation was rejected, restart it
      current.status = 0 if current.status == 3
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
