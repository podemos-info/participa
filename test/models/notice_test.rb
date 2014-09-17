require 'test_helper'

class NoticeTest < ActiveSupport::TestCase

  test "should validate presence:true" do
    n = Notice.new
    n.valid?
    assert(n.errors[:title].include? "no puede estar en blanco")
    assert(n.errors[:body].include? "no puede estar en blanco")
  end

end
