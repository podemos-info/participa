require 'podemos_export'

class PodemosCollaborationWorker
  @queue = :podemos_collaboration_queue

  def self.perform collaboration_id
    if collaboration_id==-1
      today = Date.today
      export_data Collaboration.temp_bank_filename(today, false), Collaboration.joins(:order).includes(:user).where.not(payment_type: 1).merge(Order.by_date(today,today)), 
                  folder: "tmp/collaborations", force_quotes: true, col_sep: ',' do |collaboration|
        collaboration.skip_queries_validations = true
        collaboration.get_bank_data today
      end
      FileUtils.mv Collaboration.temp_bank_filename(today), Collaboration.bank_filename(today)
    else
      collaboration = Collaboration.find(collaboration_id)
      collaboration.charge!
    end
  end
end
