class BankCccValidator < ActiveModel::Validator
  # miguel.camba / cibernox
  # https://github.com/cibernox/spanish_ccc_validator/blob/master/lib/spanish_ccc_validator/custom_ccc_validator.rb

  # Gets a string and extracts the number from it
  # Example: canonize("1234-5678-90-3344556677") returns "12345678903344556677"
  def self.canonize(str)
    str.gsub(/\D/,'')
  end

  # Main algorithm
  def self.calculate_digit(ary)
    key = [1,2,4,8,5,10,9,7,3,6]
    sumatory = 0
    key.each_with_index { |number, index| sumatory += number * ary[index] }
    result = 11 - (sumatory % 11)
    result = 1 if result == 10
    result = 0 if result == 11
    result
  end

  # Validates size and checks control-digits corelation
  def self.validate(str)
    ary = canonize(str).split('').map(&:to_i)
    return false unless ary.size == 20
    (calculate_digit([0,0] + ary[0..7]) == ary[8]) && (calculate_digit(ary[10..19]) == ary[9])
  end
end
