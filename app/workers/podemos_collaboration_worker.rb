require 'podemos_export'

class PodemosCollaborationWorker
  @queue = :podemos_collaboration_queue

  def self.perform collaboration_id
    if collaboration_id==-1
      today = Date.today
      folder = File.dirname Collaboration.bank_filename(today, true)
      export_data Collaboration.bank_filename(today, false), Collaboration.joins(:order).includes(:user).where.not(payment_type: 1).merge(Order.by_date(today,today)), 
                  folder: folder, col_sep: ',' do |collaboration|
        collaboration.skip_queries_validations = true
        collaboration.get_bank_data today
      end
      Collaboration.bank_file_lock false
    else
      collaboration = Collaboration.find(collaboration_id)
      collaboration.charge! if not collaboration.fix_status!
    end
  end
end
