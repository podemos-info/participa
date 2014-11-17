class Notice < ActiveRecord::Base

  validates :title, :body, presence: true
  default_scope { order('created_at DESC') }
  paginates_per 5

  def broadcast!
    self.broadcast_gcm(title, body, link)
    self.update_attribute(:sent_at, DateTime.now)
  end

  def broadcast_gcm(title, message, link) 
    # TODO: lib / worker async
    require 'pushmeup'
    GCM.host = 'https://android.googleapis.com/gcm/send'
    GCM.format = :json
    GCM.key = Rails.application.secrets.gcm["key"]

    data = { title: title, message: message, url: link, msgcnt: "1", soundname: "beep.wav" }
    # for every 1000 devices we send only a notification
    NoticeRegistrar.pluck(:registration_id).in_groups_of(1000) do |destination|
      GCM.send_notification( destination, data)
    end
  end

  def has_sent
    self.sent_at?
  end

end
