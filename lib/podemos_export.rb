require 'csv'

def export_data(filename, query)
  # Usage: export_data {filename}, {query (ej: User.select(:id).where(born_at: nil))} do |row| [ { row.field, row.field, ... } ] end
  # Output will be located at tmp/export folder.
  FileUtils.mkdir_p("tmp/export") unless File.directory?("tmp/export")
  CSV.open( "tmp/export/#{filename}.tsv", 'w', { :col_sep => "\t"} ) do |writer|
    query.find_each do |item|
      res = yield(item)
      if res
        writer << res
      end
    end
  end
end

def export_data_slow(filename, query)
  # Usage: export_data {filename}, {query (ej: User.select(:id).where(born_at: nil))} do |row| [ { row.field, row.field, ... } ] end
  # Output will be located at tmp/export folder.
  FileUtils.mkdir_p("tmp/export") unless File.directory?("tmp/export")
  CSV.open( "tmp/export/#{filename}.tsv", 'w', { :col_sep => "\t"} ) do |writer|
    query.each do |item|
      res = yield(item)
      if res
        writer << res
      end
    end
  end
end