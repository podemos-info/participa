require 'test_helper'

class CollaborationsHelperTest < ActionView::TestCase

  test "should new_or_edit_collaboration_path work" do
    collaboration = nil
    assert_equal "/colabora", new_or_edit_collaboration_path(collaboration)
    collaboration = FactoryBot.create(:collaboration)
    assert_equal "/colabora/ver", new_or_edit_collaboration_path(collaboration)
  end

  test "should number_to_euro work" do 
    assert_equal( "20,00€", number_to_euro(2000) )
    assert_equal( "1,00€", number_to_euro(100) )
    assert_equal( "0,00€", number_to_euro(0) )
    assert_equal( "-2,00€", number_to_euro(-200) )
    assert_equal( "66.666.666.666,66€", number_to_euro(6666666666666) )
  end

end
