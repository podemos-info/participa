require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  setup do 
    @group = FactoryBot.create(:group)
  end

  test "should validate presence on name" do
    g = Group.new
    g.valid?
    puts g.errors.to_s
    assert(g.errors[:name].include? "no puede estar en blanco")
  end

  test "a group should have users" do 
    assert_equal @group.users.count, 1
    user = FactoryBot.create(:user)
    @group.users += [ user ]
    assert_equal @group.users.count, 2
  end

end
