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

  MAX_TEST_ROWS = 100000
  MAX_TEST_MATCHES = 10000
  def test
    matches = []
    total = User.where(query).count
    offset = total > MAX_TEST_ROWS ? rand(total-MAX_TEST_ROWS) : 0

    User.where(query).offset(offset).limit(MAX_TEST_ROWS).find_each do |user|
      matches << user.id if @proc.call user, @data
      break if matches.length > MAX_TEST_MATCHES
    end
    matches
  end
end