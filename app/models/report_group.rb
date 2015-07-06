class ReportGroup < ActiveRecord::Base

  after_initialize do |group|
    if persisted?
      @proc = eval("Proc.new { |row| #{group.proc} }")
      @whitelist = whitelist.split("\r\n")
      @blacklist = blacklist.split("\r\n")
    end
  end

  def process row
    @proc.call row
  end

  def format_group_name name
    name.ljust(width)[0..width-1]
  end

  def create_temp_file folder
    @file = File.open( "#{folder}/#{self.id}.dat", 'w:UTF-8' )
  end

  def write data
    @file.puts data
  end

  def close_temp_file
    @file.close
  end

  def whitelist? value
    @whitelist.include? value
  end
  
  def blacklist? value
    @blacklist.include? value
  end

  def self.serialize data
    if data.is_a? Array
      data.map {|d| d.attributes.to_yaml } .to_yaml
    else
      data.attributes.to_yaml
    end
  end

  def self.unserialize value
    data = YAML.load(value)
    if data.is_a? Array
      data.map { |d| ReportGroup.new YAML.load(d) }
    else
      ReportGroup.new data
    end
  end
end
