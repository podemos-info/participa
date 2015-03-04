class Report < ActiveRecord::Base

  def self.serialize_relation_query relation
    query = [relation.name]


    if relation.model.methods.include? :with_deleted
      query << "with_deleted"
    else
      query << "all"
    end

    relation.includes_values.each do |_include|
      query << "includes(#{_include.inspect})"
    end

    relation.joins_values.each do |join|
      query << "joins(#{join.inspect})"
    end

    relation.where_values.each do |condition|
      condition = condition.to_sql if not condition.is_a? String
      query << "where(#{condition.inspect})"
    end

    query.join "."
  end

  after_initialize do |report|
    if report.persisted?
      @relation = eval(report.query)
      @main_group = YAML.load(report.main_group) if report.main_group
      @groups = YAML.load(report.groups)
    end
  end

  def run!
    return if not results.nil?

    # Initialize
    tmp_results = { data: {}, errors: { fetch: [] } }

    folder = "#{Rails.root}/tmp/report/#{id}"
    raw_folder = "#{folder}/raw"
    rank_folder = "#{folder}/rank"
    
    # Aggregation data
    id_width = @relation.maximum(:id).to_s.length
    total = @relation.count

    if not File.directory?(raw_folder)
      FileUtils.mkdir_p(raw_folder) unless File.directory?(raw_folder)
      FileUtils.mkdir_p(rank_folder) unless File.directory?(rank_folder)

      @groups.each { |group| group.create_temp_file raw_folder }
      # Browse data
      main_name = ""
      @relation.find_each do |row|
        row_id = row.id.to_s.ljust(id_width)

        main_name = @main_group.format_group_name(@main_group.process(row)[0]) if @main_group

        @groups.each do |group|
          width = group.width
          begin
            group.process(row).each do |name, data|
              group.write "#{row_id} #{main_name}#{group.format_group_name(name)} #{data}"
            end
          rescue Exception => e
            tmp_results[:errors][:fetch] = [ e.message, e.backtrace.inspect ]
          end
        end
      end
      @groups.each { |group| group.close_temp_file }
    end

    # Generate rank
    main_width = @main_group ? @main_group.width : 0
    @groups.each do |group|
      rest = total
      width = group.width
      %x(sort -k2,2 #{raw_folder}/#{group.id}.dat | uniq -s#{id_width+1} -w#{width+main_width} -c | sort -rn > #{rank_folder}/#{group.id}.dat)

      tmp_results[:data][group.id] = @main_group ? Hash.new { |h,k| h[k] = [] } : []

      File.open( "#{rank_folder}/#{group.id}.dat", 'r:UTF-8' ).each do |line|
        data = line.split("\s", 3)
        count = data[0].to_i

        if count <= group.minimum
          result = { count: rest, name: group.minimum_label }
          tmp_results[:data][group.id] << result
          break
        else
          rest -= count

          main_name = @main_group.format_group_name(data[2][0..(main_width-1)]) if @main_group
          name = data[2][main_width..(main_width+width-1)]

          result = { count: count, name: name.strip, users:[], samples:[]}
          %x(grep  "#{'.'*id_width} #{main_name}#{group.format_group_name(name)} " #{raw_folder}/#{group.id}.dat | head -n#{[count,100].min}).split("\n").each do |s|
            result[:users] << s[0..id_width].to_i
            sample = s[(id_width+1+main_width+width+1)..-1].strip
            result[:samples] << sample if not sample.empty?
          end

          result[:samples].uniq!
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