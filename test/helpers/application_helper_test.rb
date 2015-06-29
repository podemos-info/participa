require 'test_helper'
 
class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper
  include FontAwesome::Rails::IconHelper

  attr_reader :request 

  test "should nav_menu_link_to work" do 
    response = nav_menu_link_to "Salir", "sign-out", destroy_user_session_path, [destroy_user_session_path], method: :delete, title: "Cerrar sesión"
    expected = "<a title=\"Cerrar sesión\" class=\"\" rel=\"nofollow\" data-method=\"delete\" href=\"/users/sign_out\"><i class=\"fa fa-sign-out\"></i><span>Salir</span></a>"
    assert_equal expected, response
    response = nav_menu_link_to "Inicio", "home", root_path, [root_path], title: "Inicio"
    expected = "<a title=\"Inicio\" class=\"\" href=\"/\"><i class=\"fa fa-home\"></i><span>Inicio</span></a>"
    assert_equal expected, response
    response = nav_menu_link_to "Equipos de Participación", "users", participation_teams_path, [participation_teams_path], title: "Equipos de Participación"
    expected = "<a title=\"Equipos de Participación\" class=\"\" href=\"/equipos-de-accion-participativa\"><i class=\"fa fa-users\"></i><span>Equipos de Participación</span></a>"
    assert_equal expected, response
    response = nav_menu_link_to "Colaboración económica", "euro", new_collaboration_path, [new_collaboration_path], title: "Colaboración económica"
    expected = "<a title=\"Colaboración económica\" class=\"\" href=\"/colabora\"><i class=\"fa fa-euro\"></i><span>Colaboración económica</span></a>"
    assert_equal expected, response
    response = nav_menu_link_to "Datos personales", "user", edit_user_registration_path, [edit_user_registration_path], title: "Datos personales"
    expected = "<a title=\"Datos personales\" class=\"\" href=\"/users/edit\"><i class=\"fa fa-user\"></i><span>Datos personales</span></a>"
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
    result = info_box do "bla" end
    expected = "<div class=\"box\">\n  <div class=\"box-info\">\n    \n  </div>\n</div>\n"
    assert_equal expected, result
  end

  test "should alert_box work" do 
    result = alert_box("Alerta") do "bla" end
    expected = "<div class=\"box\">\n  <div class=\"box-ok\">\n    <p><strong>Alerta</strong></p>\n      <p></p>\n    <a class=\"box-close\" href=\"#\">\n      <span></span>\n    </a>\n  </div>\n</div>\n"
    assert_equal expected, result
  end

  test "should error_box work" do 
    result = error_box("title") do "bla" end
    expected = "<div class=\"box\">\n  <div class=\"box-ko\">\n    <p><strong>title</strong></p>\n\n    <p></p>\n\n        <a class=\"box-close\" href=\"#\">\n          <span></span>\n        </a>\n  </div>\n</div>\n"
    assert_equal expected, result
  end

  test "should render_flash work" do 
    result = render_flash "application/error", "Error", "" do "bla" end 
    expected = "<div class=\"box\">\n  <div class=\"box-ko\">\n    <p><strong>Error</strong></p>\n\n    <p></p>\n\n        <a class=\"box-close\" href=\"#\">\n          <span></span>\n        </a>\n  </div>\n</div>\n"
    assert_equal expected, result
  end

  test "should field_notice_box work" do 
    result = field_notice_box
    expected = "<div class=\"alert-nexttolabel\">\n  <p>Revisa este campo.</p>\n  <div class=\"alert-ico\">\n    <span></span>\n  </div>\n</div>\n"
    assert_equal expected, result
  end

  test "should errors_in_form work" do 
    user = FactoryGirl.create(:user)
    user.born_at = DateTime.now
    result = errors_in_form user
    assert_equal "", result
  end
1
  test "should steps_nav work" do 
    result = steps_nav(1, ["primero", "segundo", "tercero"])
    expected = "<nav class=\"steps3\">\n  <ul>\n    <li class=active>\n      <span class=\"block\">\n        <span class=\"tab-number\">1)</span>\n        <span class=\"tab-text\">[&quot;primero&quot;, &quot;segundo&quot;, &quot;tercero&quot;]</span>\n      </span>\n    </li>\n    <li >\n      <span class=\"block\">\n        <span class=\"tab-number\">2)</span>\n        <span class=\"tab-text\"></span>\n      </span>\n    </li>\n    <li >\n      <span class=\"block\">\n        <span class=\"tab-number\">3)</span>\n        <span class=\"tab-text\"></span>\n      </span>\n    </li>\n  </ul>\n</nav>\n\n<h3>\n  <span>[&quot;primero&quot;, &quot;segundo&quot;, &quot;tercero&quot;]</span>\n</h3>\n"
    assert_equal expected, result
  end

  test "should body_class work" do 
    result = body_class(true, "sessions", "new")
    expected = "signed-in"
    assert_equal expected, result

    result = body_class(true, "sessions", "edit")
    expected = "signed-in"
    assert_equal expected, result

    result = body_class(false, "sessions", "new")
    expected = "logged-out"
    assert_equal expected, result
  end

end
