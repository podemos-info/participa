class PodemosImportWorker

  require 'podemos_import'

  @queue = :podemos_import_queue

  def self.perform row
    PodemosImport.process_row(row)
  end

end
