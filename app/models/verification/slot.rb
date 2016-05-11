class Verification::Slot < ActiveRecord::Base
  belongs_to :verification_center, class_name: 'Verification::Center', foreign_key: 'verification_center_id'
end
