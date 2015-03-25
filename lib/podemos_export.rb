require 'csv'

def export_data(filename, query, options={})
  # Usage: export_data {filename}, {query (ej: User.select(:id).where(born_at: nil))} do |row| [ { row.field, row.field, ... } ] end
  # Output will be located at tmp/export folder.

  headers = options.fetch(:headers, nil)
  folder = options.fetch(:folder, "tmp/export")
  col_sep = options.fetch(:col_sep, "\t")
  force_quotes = options.fetch(:force_quotes, false)
  extension = col_sep == "\t" ? "tsv" : "csv"

  FileUtils.mkdir_p(folder) unless File.directory?(folder)
  CSV.open( "#{folder}/#{filename}.#{extension}", 'w', { :col_sep => col_sep, encoding: 'utf-8', force_quotes: force_quotes} ) do |writer|
    writer << headers if headers
    query.find_each do |item|
      res = yield(item)
      if res
        writer << res
      end
    end
  end
end

def export_raw_data(filename, data, options = {})
  # Output will be located at tmp/export folder.
  headers = options.fetch(:headers, nil)
  folder = options.fetch(:folder, "tmp/export")
  col_sep = options.fetch(:col_sep, "\t")
  force_quotes = options.fetch(:force_quotes, false)
  extension = col_sep == "\t" ? "tsv" : "csv"

  FileUtils.mkdir_p(folder) unless File.directory?(folder)
  CSV.open( "#{folder}/#{filename}.#{extension}", 'w', { :col_sep => col_sep, encoding: 'utf-8', force_quotes: force_quotes} ) do |writer|
    writer << headers if headers
    data.each do |item|
      res = yield(item)
      if res
        writer << res
      end
    end
  end
end