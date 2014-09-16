module SMS
  module Sender
    def self.send_message(to, code)
      sms = Esendex::Account.new
      sms.send_message( to: to, body: "Tu código de activación es #{code}") 
    end
  end
end
