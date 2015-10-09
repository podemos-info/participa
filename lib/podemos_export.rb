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

def fill_data(filename, data, options = {})
  col_sep = options.fetch(:col_sep, "\t")
  folder = options.fetch(:folder, "tmp/export")
  force_quotes = options.fetch(:force_quotes, false)
  data = {}
  headers = nil
  CSV.foreach(filename, headers: true, col_sep: col_sep, encoding: 'utf-8') do |row|
    headers = row.headers if headers.nil?
    data[row[0]] = Hash[headers[1..-1].map{|h| [h,row[h]] }] if !row[0].nil?
  end
  data.where(headers[0]=>data.map{|k,h| [k.upcase, k.downcase]} .flatten.uniq).find_each do |item|
    row = data[item.send(headers[0])]
    headers[1..-1].map do |h| 
      if item.respond_to? h
        value = item.send(h)
        data[item.send(headers[0])][h] = value if !value.nil?
      end
    end if row && row.length>1
  end
  CSV.open( "#{filename}.filled.csv", 'w', { col_sep: col_sep, encoding: 'utf-8', force_quotes: force_quotes} ) do |writer|
    writer << headers
    data.each do |key, item|
      writer << [ key ] + headers[1..-1].map{|h|item[h]}
    end
  end
end