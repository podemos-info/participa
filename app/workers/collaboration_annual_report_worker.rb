# frozen_string_literal: true

class CollaborationAnnualReportWorker
  def self.get_users
    User.joins(:orders).where('orders.payed_at' => Time.current.beginning_of_year..Time.current.end_of_year) 
  end
end
