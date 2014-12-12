require 'test_helper'

class CollaborationsHelperTest < ActionView::TestCase

  test "should new_or_edit_collaboration_path work" do
    skip("TODO")
  end

  test "should number_to_euro work" do 
    assert_equal( "20,00 €", number_to_euro(2000) )
    assert_equal( "1,00 €", number_to_euro(100) )
    assert_equal( "0,00 €", number_to_euro(0) )
    assert_equal( "-2,00 €", number_to_euro(-200) )
    assert_equal( "66.666.666.666,66 €", number_to_euro(6666666666666) )
  end

  test "should show_redsys_response work" do
    assert_equal( "Transacción autorizada para pagos y preautorizaciones", show_redsys_response("0000") )
    assert_equal( "Transacción autorizada para pagos y preautorizaciones", show_redsys_response("0099") )
    assert_equal( "Transacción autorizada para pagos y preautorizaciones", show_redsys_response("99") )
    assert_equal( "Tarjeta ajena al servicio", show_redsys_response("180") )
    assert_equal( "Transacción denegada", show_redsys_response("111111") )
  end

end
