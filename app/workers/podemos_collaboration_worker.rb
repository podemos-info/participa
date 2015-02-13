class PodemosCollaborationWorker

  @queue = :podemos_collaboration_queue

  def self.perform collaboration_id
    collaboration = Collaboration.find(collaboration_id)
    order = collaboration.get_orders(Date.today, Date.today)[0]
    if order and order.is_payable?
      if collaboration.is_credit_card?
        order.redsys_send_request 
      else
        order.save
      end
    end
  end

end