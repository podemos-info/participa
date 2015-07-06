class ReportGroup < ActiveRecord::Base
  def process row
    get_proc.call row
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

  def get_proc
    @proc ||= eval("Proc.new { |row| #{self[:proc]} }")
  end
  def get_whitelist
    @whitelist ||= self[:whitelist].split("\r\n")
  end
  def get_blacklist
    @blacklist ||= self[:blacklist].split("\r\n")
  end
  
  def proc= value
    @proc = nil
    self[:proc] = value
  end

  def whitelist= value
    @whitelist = nil
    self[:whitelist] = value
  end

  def whitelist? value
    get_whitelist.include? value
  end

  def blacklist= value
    @blacklist = nil
    self[:blacklist] = value
  end
  
  def blacklist? value
    get_blacklist.include? value
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
