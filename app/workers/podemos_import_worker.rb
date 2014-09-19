class PodemosImportWorker

  require 'podemos_import'

  @queue = :podemos_import_queue

  def self.perform row, now
    PodemosImport.process_row(row, now)
  end

end
