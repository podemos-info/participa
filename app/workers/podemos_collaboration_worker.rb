class PodemosCollaborationWorker

  @queue = :podemos_collaboration_queue

  def self.perform collaboration
    
    order = collaboration.get_orders(Date.today, Date.today)[0]
    if order.is_payable?
      order.mark_as_charging
      order.save
      order.redsys_send_request if order.is_credit_card?
    end
  end

end