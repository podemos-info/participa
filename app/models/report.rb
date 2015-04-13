class Report < ActiveRecord::Base

  def self.serialize_relation_query relation
    relation.to_sql.sub(/ LIMIT \d+/, ' ').sub(/ OFFSET \d+/, ' ').strip
  end

  after_initialize do |report|
    if report.persisted?
      table_name = query.match(/\s*SELECT\s*.*\s*FROM\s*\"?(\w+)\"?\s*/)
      table_name = table_name.captures.first if table_name

      if table_name
        @model = ActiveRecord::Base.send(:descendants).select do |m| m.table_name==table_name end .first

        @main_group = YAML.load(report.main_group) if report.main_group
        @groups = YAML.load(report.groups)
      end
    end
  end

  def batch_process batch_size=1000
    offset = 0
    begin 
      results = @model.find_by_sql("#{query} OFFSET #{offset} LIMIT #{batch_size}")
      offset += batch_size
      
      results.each do |row|
        yield row
      end
    end while not results.empty?
  end

  def run!
    # Initialize
    tmp_results = { data: Hash.new { |h, main_group| h[main_group] = Hash.new { |h2, group| h2[group] = [] } }, errors: { fetch: [] } }

    folder = "#{Rails.root}/tmp/report/#{id}"
    raw_folder = "#{folder}/raw"
    rank_folder = "#{folder}/rank"
    
    # Aggregation data
    id_width = @model.maximum(:id).to_s.length

    FileUtils.mkdir_p(raw_folder) unless File.directory?(raw_folder)
    FileUtils.mkdir_p(rank_folder) unless File.directory?(rank_folder)

    @groups.each { |group| group.create_temp_file raw_folder }
    # Browse data
    main_name = ""
    self.batch_process do |row|
      row_id = row.id.to_s.ljust(id_width)

      main_name = @main_group.format_group_name(@main_group.process(row)[0][0]) if @main_group

      @groups.each do |group|
        width = group.width
        begin
          group.process(row).each do |name, data|
            group.write "#{row_id}#{main_name}#{group.format_group_name(name)} #{data}"
          end
        rescue Exception => e
          tmp_results[:errors][:fetch] = [ e.message, e.backtrace.inspect ]
        end
      end
    end
    @groups.each { |group| group.close_temp_file }

    # Generate rank
    main_width = @main_group ? @main_group.width : 0
    @groups.each do |group|
      width = group.width

      %x(cut -c#{id_width+1}- #{raw_folder}/#{group.id}.dat | sort | uniq -w#{width+main_width+1} -c | sort -rn > #{rank_folder}/#{group.id}.dat)
      rest = Hash.new {|h,k| h[k] = []}
      separator = nil
      File.open( "#{rank_folder}/#{group.id}.dat", 'r:UTF-8' ).each do |line|
        separator = line.index " ", line.index(/\d/) if not separator
        count = line[0..separator-1].to_i
        info = line[separator+1..-2]

        main_name = @main_group ? info[0..(main_width-1)].strip : nil
        name = info[main_width..(main_width+width-1)].strip
        
        if group.whitelist? name or (count <= group.minimum and not group.blacklist? name)
          rest[main_name] << { count: count, name: name }
        else
          result = { count: count, name: name, users:[], samples:Hash.new(0)}
          %x(grep "#{'.'*id_width}#{@main_group.format_group_name(main_name) if @main_group}#{group.format_group_name(name)} " #{raw_folder}/#{group.id}.dat | head -n#{[count,101].min}).split("\n").each do |s|
            result[:users] << s[0..id_width-1].to_i
            sample = s[(id_width+main_width+width)..-1].strip
            result[:samples][sample] += 1
            result[:users].uniq!
          end

          result[:users] = result[:users].first(20)
          tmp_results[:data][main_name][group.id] << result
        end
      end

      rest.each do |main_name, entries|
        count = entries.map {|e| e[:count] } .sum
        result = { count: count, name: group.minimum_label, samples:Hash.new(0)}
        entries.each {|e| result[:samples][e[:name]] += e[:count] }
        result[:samples] = Hash[result[:samples].sort_by {|k,v| [-v, k]}]
        if result[:samples].length>100
          result[:samples] = Hash[result[:samples].first(100)]
          result[:samples]["+"] = count - (result[:samples].map {|k,v| v} .sum)
        end
        tmp_results[:data][main_name][group.id] << result
      end
    end

    self.results = tmp_results.to_yaml
    self.save
  end
end