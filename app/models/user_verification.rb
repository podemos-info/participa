class UserVerification < ActiveRecord::Base
  belongs_to :user, -> { with_deleted }

  has_paper_trail

  has_attached_file :front_vatid, path: ":rails_root/non-public/system/:class/:attachment/:id_partition/:style/:filename", styles: { thumb: ["450x300", :png] }, processors: [:rotator]
  has_attached_file :back_vatid, path: ":rails_root/non-public/system/:class/:attachment/:id_partition/:style/:filename", styles: { thumb: ["450x300", :png] }, processors: [:rotator]

  def rotate
    @rotate ||= HashWithIndifferentAccess.new
  end

  validates :user, :front_vatid, presence: true, unless: :not_require_photos?
  validates :back_vatid, presence: true, if: :require_back?, unless: :not_require_photos?
  validates :terms_of_service, acceptance: true

  validates_attachment_content_type :front_vatid, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :back_vatid, content_type: /\Aimage\/.*\z/

  validates_attachment_size :front_vatid, less_than: 6.megabyte
  validates_attachment_size :back_vatid, less_than: 6.megabyte

  #after_initialize :push_id_to_processing_list

  after_validation do
    errors.each do |attr|
      if attr.to_s.starts_with?("front_vatid_") || attr.to_s.starts_with?("back_vatid_")
        errors.delete(attr)
      end
    end
  end

  enum status: {pending: 0, accepted: 1, issues: 2, rejected: 3, accepted_by_email: 4, discarded: 5, paused: 6}

  scope :not_discarded, -> { where.not status: 5 }
  scope :discardable, -> { where status: [0, 2] }
  scope :not_sended, -> {where wants_card: true, born_at: nil  }

  def discardable?
    status == :pending || status == :issues
  end

  def require_back?
    !user.is_passport?
  end

  def not_require_photos?
    user.photos_unnecessary?
  end
  def self.for(user, params = {})
    current = self.where(user: user, status: [0, 2, 3]).first
    if current
      current.assign_attributes(params)
    else
      current = UserVerification.new params.merge(user: user)
    end
    current
  end

  def active?
    $redis = $redis || Redis::Namespace.new("podemos_queue_validator", :redis => Redis.new)
    current_hash = $redis.hget(:processing,id)
    current_verification = UserVerification.find(id) if UserVerification.where(id: id).any?
    if current_verification && current_hash
      # convert hash in string to hash
      current_hash = current_hash.gsub(/[{}:]/,'').split(', ').map{|h| h1,h2 = h.split('=>'); {h1 => h2}}.reduce(:merge)
      current_hash = Hash[current_hash.map{ |k, v| [k.to_sym, v] }]
      # end convert hash in string to hash
      DateTime.now.utc <= (current_hash[:locked_at].gsub(/[\"]/,'').gsub(/[|]/,':').to_datetime + Rails.application.secrets.user_verifications["time_to_expire_session"].minutes)
    else
      false
    end
  end

  def get_current_verifier
    $redis = $redis || Redis::Namespace.new("podemos_queue_validator", :redis => Redis.new)
    current_hash = $redis.hget(:processing,id)
    if current_hash
      # convert hash in string to hash
      current_hash = current_hash.gsub(/[{}:]/,'').split(', ').map{|h| h1,h2 = h.split('=>'); {h1 => h2}}.reduce(:merge)
      current_hash = Hash[current_hash.map{ |k, v| [k.to_sym, v] }]
      # end convert hash in string to hash
      User.find(current_hash[:author_id].to_i)
    else
      nil
    end
  end
end
