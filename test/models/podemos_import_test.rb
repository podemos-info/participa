require 'test_helper'
require 'podemos_import'

class PodemosImportTest < ActiveSupport::TestCase

#  test "should #init work" do
#    skip("TODO")
#    csv_file = "#{Rails.root}/test/lib/juntos_test.csv"
#    PodemosImport.init(csv_file)
#    # User.difference N
#    User.count
#  end

  # DOCUMENT: Pasaporte NIE DNI 

  test "should #convert_document_type work" do
    assert_equal 1, PodemosImport.convert_document_type("DNI / NIE", "N888888")
    assert_equal 2, PodemosImport.convert_document_type("DNI / NIE", "X888888")
    assert_equal 3, PodemosImport.convert_document_type("Pasaporte", "D888888")
  end

#  test "should #invalid_record work" do
#    skip("TODO")
#    #PodemosImport.invalid_record(logger)
#  end
#
#  test "should #process_row work" do
#    skip("TODO")
#    #PodemosImport.process_row(logger)
#  end

  test "should #convert_province work" do
    assert_equal PodemosImport.convert_province("28002", "España", "Madrid"), "M"
    assert_equal PodemosImport.convert_province("48002", "Spain", "Bilbao"), "BI"
    assert_equal PodemosImport.convert_province("48002", "España", "Bilbao"), "BI" 
    assert_equal PodemosImport.convert_province("48002", "bla", "Tanganika"), "Tanganika"
  end
  
  test "should #convert_country work" do
    assert_equal PodemosImport.convert_country("Germany"), "DE"
    assert_equal PodemosImport.convert_country("France"), "FR"
    assert_equal PodemosImport.convert_country("Ireland"), "IE"
    assert_equal PodemosImport.convert_country("Brazil"), "BR"
    assert_equal PodemosImport.convert_country("Norway"), "NO"
    assert_equal PodemosImport.convert_country("España"), "ES"
    assert_equal PodemosImport.convert_country("Bélgica"), "BE"
    assert_equal PodemosImport.convert_country("Invalid"), "Invalid"
  end
  
end
