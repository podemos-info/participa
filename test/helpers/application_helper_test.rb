require 'test_helper'
 
class UserHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "should work bootstrap_class_for" do
    assert_equal bootstrap_class_for(:success), "alert-success"
    assert_equal bootstrap_class_for(:error), "alert-danger"
    assert_equal bootstrap_class_for(:alert), "alert-warning"
    assert_equal bootstrap_class_for(:notice), "alert-info"
    assert_equal bootstrap_class_for(:another), "another"
  end
end
