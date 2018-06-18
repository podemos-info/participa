require 'test_helper'

class AbilityTest < ActiveSupport::TestCase

  setup do 
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user, document_type: 3, document_vatid: "22222D")
    @admin = FactoryBot.create(:user, :admin)
    @superadmin = FactoryBot.create(:user, :admin, :superadmin)
    @notice = FactoryBot.create(:notice)
  end

  test "should not an anon user read any user data" do
    user = User.new
    ability = Ability.new user
    assert ability.can?(:show, user)
    assert ability.cannot?(:show, @user1)
    assert ability.cannot?(:show, @user2)
  end

  test "should a user read user data" do
    ability = Ability.new @user1
    assert ability.can?(:show, @user1)
    assert ability.cannot?(:show, @user2)
  end

  test "should an admin read user data" do
    ability = Ability.new @admin
    assert ability.can?(:show, @user1)
    assert ability.can?(:show, @user2)
    assert ability.can?(:manage, @user2)
  end

  test "should not an user create/edit a notice" do
    ability = Ability.new @user1
    assert ability.can?(:show, @notice)
    assert ability.cannot?(:create, Notice.new)
    assert ability.cannot?(:edit, @notice)
    assert ability.cannot?(:manage, @notice)
  end

  test "should an admin create a notice" do
    ability = Ability.new @superadmin
    assert ability.can?(:create, Notice.new)
    assert ability.can?(:edit, @notice)
    assert ability.can?(:manage, @notice)
  end

end
