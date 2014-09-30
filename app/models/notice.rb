class Notice < ActiveRecord::Base
  validates :title, :body, presence: true

  default_scope { order('created_at DESC') }

  paginates_per 5

  after_create :broadcast_gcm

  def broadcast_gcm 
    # TODO: lib / worker async
    require 'pushmeup'
    GCM.host = 'https://android.googleapis.com/gcm/send'
    GCM.format = :json
    GCM.key = Rails.application.secrets.gcm["key"]
    destination = NoticeRegistrar.pluck(:registration_id)
    data = {:title => self.title, :message => self.body, :msgcnt => "1", :soundname => "beep.wav"}
    # TODO: if destination.count > 1000 then split 
    GCM.send_notification( destination, data)
  end

end
