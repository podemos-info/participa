class PodemosReportWorker
  @queue = :podemos_report_queue

  def self.perform report_id
    report = Report.find(report_id)
    report.run!
  end
end
