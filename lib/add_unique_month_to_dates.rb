class Date
  def unique_month
    return self.year*12+self.month
  end
end

class DateTime
  def unique_month
    return self.year*12+self.month
  end
end

class Time
  def unique_month
    return self.year*12+self.month
  end
end

class ActiveRecord::Base
  def self.unique_month field
    case self.connection.adapter_name
      when 'SQLite' then "strftime('%Y', #{field})*12+strftime('%m', #{field})"
      when 'PostgreSQL' then "extract(year from #{field})*12+extract(month from #{field})"
      else "year(#{field})*12+month(#{field})" # MySQL, SQL Server, ...
    end
  end

  def self.unique_day field
    case self.connection.adapter_name
      when 'SQLite' then "strftime('%Y', #{field})*366+(strftime('%m', #{field})-1)*31+strftime('%d', #{field})"
      when 'PostgreSQL' then "extract(year from #{field})*366+(extract(month from #{field})-1)*31+extract(day from #{field})"
      else "year(#{field})*366+(month(#{field})-1)*31+day(#{field})" # MySQL, SQL Server, ...
    end
  end
end