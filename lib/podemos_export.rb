require 'csv'

def export_data(filename, query, headers = nil, folder = "tmp/export")
  # Usage: export_data {filename}, {query (ej: User.select(:id).where(born_at: nil))} do |row| [ { row.field, row.field, ... } ] end
  # Output will be located at tmp/export folder.
  FileUtils.mkdir_p(folder) unless File.directory?(folder)
  CSV.open( "#{folder}/#{filename}.tsv", 'w', { :col_sep => "\t"} ) do |writer|
    writer << headers if headers
    query.find_each do |item|
      res = yield(item)
      if res
        writer << res
      end
    end
  end
end

def export_raw_data(filename, data, headers = nil, folder = "tmp/export")
  # Output will be located at tmp/export folder.
  FileUtils.mkdir_p(folder) unless File.directory?(folder)
  CSV.open( "#{folder}/#{filename}.tsv", 'w', { :col_sep => "\t"} ) do |writer|
    writer << headers if headers
    data.each do |item|
      res = yield(item)
      if res
        writer << res
      end
    end
  end
end