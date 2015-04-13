require 'test_helper'
 
class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  attr_reader :request 

  test "should nav_menu_link_to work" do 
    response = nav_menu_link_to "Salir", destroy_user_session_path, [destroy_user_session_path], method: :delete, title: "Cerrar sesión" 
    expected = "<a class=\"\" data-method=\"delete\" href=\"/users/sign_out\" rel=\"nofollow\" title=\"Cerrar sesión\"><span>Salir</span></a>"
    assert_equal expected, response
    response = nav_menu_link_to "Herramientas", root_path, [root_path], title: "Herramientas" 
    expected = "<a class=\"\" href=\"/\" title=\"Herramientas\"><span>Herramientas</span></a>"
    assert_equal expected, response
    response = nav_menu_link_to "Equipos de Participación", participation_teams_path, [participation_teams_path], title: "Equipos de Participación"
    expected = "<a class=\"\" href=\"/equipos-de-accion-participativa\" title=\"Equipos de Participación\"><span>Equipos de Participación</span></a>"
    assert_equal expected, response
    response = nav_menu_link_to "Avisos", notices_path, [notices_path], class: new_notifications_class 
    expected = "<a class=\"\" href=\"/notices\"><span>Avisos</span></a>"
    assert_equal expected, response
    response = nav_menu_link_to "Colaboración económica", new_collaboration_path, [new_collaboration_path], title: "Colaboración económica"
    expected = "<a class=\"\" href=\"/colabora\" title=\"Colaboración económica\"><span>Colaboración económica</span></a>"
    assert_equal expected, response
    response = nav_menu_link_to "Datos personales", edit_user_registration_url, [edit_user_registration_path], title: "Datos personales"
    expected = "<a class=\"\" href=\"http://test.host/users/edit\" title=\"Datos personales\"><span>Datos personales</span></a>"
    assert_equal expected, response
  end

  test "should new_notifications_class work" do 
    assert_equal "", new_notifications_class
  end

  test "should current_lang? work" do 
    I18n.locale = :ca 
    assert_equal true, current_lang?(:ca)
    assert_equal false, current_lang?(:es)
    I18n.locale = :es 
    assert_equal false, current_lang?(:ca)
    assert_equal true, current_lang?(:es)
  end

  test "should current_lang_class work" do 
    I18n.locale = :ca 
    assert_equal "active", current_lang_class(:ca)
    assert_equal "", current_lang_class(:es)
    I18n.locale = :es 
    assert_equal "active", current_lang_class(:es)
    assert_equal "", current_lang_class(:ca)
  end

  test "should info_box work" do 
    skip("TODO")
    #result = "<%= info_box do %><p>Según nuestra base de datos estás inscrito con un número de pasaporte.</p><% end %>"
    #template = ERB.new(result, nil, "%")
    #assert_equal "", template.result
  end

  test "should alert_box work" do 
    skip("TODO")
  end

  test "should error_box work" do 
    skip("TODO")
  end

  test "should render_flash work" do 
    skip("TODO")
  end

  test "should field_notice_box work" do 
    skip("TODO")
  end

  test "should errors_in_form work" do 
    skip("TODO")
  end

  test "should steps_nav work" do 
    skip("TODO")
  end

  test "should body_class work" do 
    skip("TODO")
  end
end
