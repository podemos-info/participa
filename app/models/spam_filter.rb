class SpamFilter < ActiveRecord::Base
  after_initialize do |filter|
    if persisted?
      @proc = eval("Proc.new { |user, data| #{filter.code} }")
      @data = filter.data.split("\r\n")
    end
  end

  def process user
    if @proc.call user, @data
      user.banned = true
      user.save
    end
  end

  def test max_rows, max_matches
    matches = []
    percent = 1.0*max_rows/User.where(query).count
    sample = percent<1 ? "random()<#{percent}" : ""
    User.where(query).where(sample).limit(max_rows).find_each do |user|
      matches << user.id if @proc.call user, @data
      break if matches.length > max_matches
    end
    matches
  end
end