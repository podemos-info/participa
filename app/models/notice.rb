class Notice < ActiveRecord::Base

  validates :title, :body, presence: true
  default_scope { order('created_at DESC') }
  paginates_per 5

  def broadcast!
    self.broadcast_gcm(title, body, link)
    self.update_attribute(:sent_at, DateTime.now)
  end

  def broadcast_gcm(title, message, link=false) 
    # TODO: lib / worker async
    require 'pushmeup'
    GCM.host = 'https://android.googleapis.com/gcm/send'
    GCM.format = :json
    GCM.key = Rails.application.secrets.gcm["key"]
    destination = NoticeRegistrar.pluck(:registration_id)
    if link
      data = { title: title, message: message, msgcnt: "1", soundname: "beep.wav" }
    else
      data = { title: title, message: message, url: link, msgcnt: "1", soundname: "beep.wav" }
    end
    # TODO: if destination.count > 1000 then split 
    GCM.send_notification( destination, data)
  end

  def has_sent
    self.sent_at?
  end

end
