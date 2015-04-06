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


  def query_count
    User.confirmed.not_verified.not_banned.where(query).count
  end

  def run offset, limit
    matches = []
    User.confirmed.not_verified.not_banned.where(query).offset(offset).limit(limit).each do |user|
      matches << user if @proc.call user, @data
    end
    matches
  end

  def self.any? user
    SpamFilter.active.each do |filter|
      return filter.name if filter.process user
    end
    false
  end
end