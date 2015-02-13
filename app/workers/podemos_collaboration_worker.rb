class PodemosCollaborationWorker

  @queue = :podemos_collaboration_queue

  def self.perform collaboration_id
    collaboration = Collaboration.find(collaboration_id)
    order = collaboration.get_orders(Date.today, Date.today)[0]
    if order and order.is_payable?
      order.mark_as_charging! if collaboration.is_credit_card?
      order.save
      order.redsys_send_request if collaboration.is_credit_card?
    end
  end

end