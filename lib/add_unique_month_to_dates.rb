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