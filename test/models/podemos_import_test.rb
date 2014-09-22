require 'test_helper'
require 'podemos_import'

class PodemosImportTest < ActiveSupport::TestCase

  test "should #init work" do
    skip("TODO")
    csv_file = "#{Rails.root}/test/lib/juntos_test.csv"
    PodemosImport.init(csv_file)
    # User.difference N
    User.count
  end

  # DOCUMENT: Pasaporte NIE DNI 

  test "should #convert_document_type work" do
    assert_equal 1, PodemosImport.convert_document_type("DNI / NIE", "N888888")
    assert_equal 2, PodemosImport.convert_document_type("DNI / NIE", "X888888")
    assert_equal 3, PodemosImport.convert_document_type("Pasaporte", "D888888")
  end

  test "should #invalid_record work" do
    skip("TODO")
    #PodemosImport.invalid_record(logger)
  end

  test "should #process_row work" do
    skip("TODO")
    #PodemosImport.process_row(logger)
  end

end
