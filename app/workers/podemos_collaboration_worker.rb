class PodemosCollaborationWorker

  @queue = :podemos_collaboration_queue

  def self.perform collaboration_id
    collaboration = Collaboration.find(collaboration_id)
    collaboration.charge
  end

end