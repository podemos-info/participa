class SpamFilter < ActiveRecord::Base
  scope :active, -> { where(active:true) }

  after_initialize do |filter|
    if persisted?
      @proc = eval("Proc.new { |user, data| #{filter.code} }")
      @data = filter.data.split("\r\n")
    end
  end

  def process user
    @proc.call user, @data
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

  def self.any? user
    SpamFilter.active.each do |filter|
      return true if filter.process user
    end
    false
  end
end