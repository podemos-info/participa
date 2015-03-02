class Report < ActiveRecord::Base

  after_initialize do |report|
    if report.persisted?
      @relation = YAML.load(report.query)
      if @relation.class == String
        @relation = eval(@relation)
      end

      @main_group = YAML.load(report.main_group)
      @groups = YAML.load(report.groups)
    end
  end

  def relation= _query
    if _query.class != String
      _query = YAML.dump(_query)
    end
    self.query = _query
  end

  def run!
    return if not results.nil?

    # Initialize
    tmp_results = { data: {}, errors: { fetch: [] } }
    folder = "#{Rails.root}/tmp/report/#{id}"
    raw_folder = "#{folder}/raw"
    rank_folder = "#{folder}/rank"
    FileUtils.mkdir_p(raw_folder) unless File.directory?(raw_folder)
    FileUtils.mkdir_p(rank_folder) unless File.directory?(rank_folder)

    @groups.each { |group| group.create_temp_file raw_folder }
    
    # Aggregation data
    id_width = @relation.maximum(:id).to_s.length
    total = @relation.count

    # Browse data
    main_name = ""
    @relation.find_each do |row|
      row_id = row.id.to_s.ljust(id_width)

      main_name = @main_group.format_group_name(@main_group.process(row)[0]) if @main_group

      @groups.each do |group|
        width = group.width
        begin
          group.process(row).each do |name, data|
            group.write "#{row_id}#{main_name}#{group.format_group_name(name)}#{data}"
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
      rest = total
      width = group.width
      %x(sort -k2,2 #{raw_folder}/#{group.id}.dat | uniq -s#{id_width} -w#{width+main_width} -c | sort -rn > #{rank_folder}/#{group.id}.dat)

      tmp_results[:data][group.id] = @main_group ? Hash.new { |h,k| h[k] = [] } : []

      File.open( "#{rank_folder}/#{group.id}.dat", 'r:UTF-8' ).each do |line|
        data = line.split("\s", 2)
        count = data[0].to_i

        if count <= group.minimum
          main_name = nil
          result = { count: rest, name: group.minimum_label }
        else
          rest -= count

          main_name = @main_group.format_group_name(data[1][id_width..(id_width+main_width-1)]) if @main_group
          name = data[1][id_width+main_width..(id_width+main_width+width-1)]

          result = { count: count, name: name.strip, users:[], samples:[]}

          %x(grep  "#{'.'*id_width}#{main_name}#{group.format_group_name(name)}" #{raw_folder}/#{group.id}.dat | head -n1000).split("\n").each do |s|
            result[:users] << s[0..id_width].to_i
            result[:samples] << s[(id_width+main_width+width)..-1]
          end
        end

        if @main_group
          tmp_results[:data][main_name][group.id] << result
        else
          tmp_results[:data][group.id] << result
        end
      end
    end

    self.results = tmp_results.to_yaml
    self.save
  end
end

=begin
            Whitelist
            Blacklist 
=end