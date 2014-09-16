require 'test_helper'
 
class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  attr_reader :request 

  test "should work bootstrap_class_for" do
    assert_equal bootstrap_class_for(:success), "alert-success"
    assert_equal bootstrap_class_for(:error), "alert-danger"
    assert_equal bootstrap_class_for(:alert), "alert-warning"
    assert_equal bootstrap_class_for(:notice), "alert-info"
    assert_equal bootstrap_class_for(:another), "another"
  end

  test "should work bootstrap_nav_link" do
    request.path = authenticated_root_path 
    assert_equal bootstrap_nav_link("Herramientas", authenticated_root_path, "glyphicon-link"), "<li class=\"active\"><a href=\"/\"><i class=\"glyphicon glyphicon-link\"></i> Herramientas</a></li>"
    assert_equal bootstrap_nav_link("Perfil", edit_user_registration_path, "glyphicon-cog"), "<li><a href=\"/users/edit\"><i class=\"glyphicon glyphicon-cog\"></i> Perfil</a></li>"

    request.path = edit_user_registration_path 
    assert_equal bootstrap_nav_link("Herramientas", authenticated_root_path, "glyphicon-link"), "<li><a href=\"/\"><i class=\"glyphicon glyphicon-link\"></i> Herramientas</a></li>"
    assert_equal bootstrap_nav_link("Perfil", edit_user_registration_path, "glyphicon-cog"), "<li class=\"active\"><a href=\"/users/edit\"><i class=\"glyphicon glyphicon-cog\"></i> Perfil</a></li>"
  end

  test "should work bootstrap_class_for_steps" do
    assert_equal bootstrap_class_for_steps(1,1), "active"
    assert_equal bootstrap_class_for_steps(1,2), ""
    assert_equal bootstrap_class_for_steps(3,2), "disabled"
    assert_equal bootstrap_class_for_steps(2,1), "disabled"
  end

end
