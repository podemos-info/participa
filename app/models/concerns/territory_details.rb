module TerritoryDetails
  extend ActiveSupport::Concern

  def calc_muni_dc (m)
    w = [[0,1,2,3,4,5,6,7,8,9],[0,3,8,2,7,4,1,5,9,6],[0,2,4,6,8,1,3,5,7,9]]
    c = m.to_s.rjust(5,'0').split('').map(&:to_i)
    dc = (10-(0..4).map {|d| w[2 - d % 3][c[d]]}.reduce(:+)) % 10
  end

  def get_valid_town_code town_code,country_code = "ES",generate_dc = false
    # only works with carmen-rails gem

    result = nil
    if (Float(town_code)!= nil rescue false) && town_code.to_i.between?(1000,529999)
      town_code = town_code.to_s + calc_muni_dc(town_code).to_s if town_code.to_i < 53000 && generate_dc
      code = town_code.to_s.rjust(6,'0')
      result = "m_#{code[0..1]}_#{code[2..4]}_#{code[5]}"
    elsif town_code.is_a?(String) && /m_\d\d_\d\d\d_\d/.match?(town_code)
      result = town_code
    elsif town_code.is_a?(String) && /m_\d\d\d\d\d\d/.match?(town_code)
      result = "#{town_code[0..3]}_#{town_code[4..6]}_#{town_code[7]}"
    else
      result = nil
    end

    puts result
    if defined?(Carmen) && result
      country = Carmen::Country.coded(country_code)
      result  = country.subregions[result[2,2].to_i-1].subregions.coded(result) ? result : nil
    end

    return result
  end

  def territory_details (options)
    # only works with carmen-rails gem
    # town_code, country_code = "ES", generate_dc = false, unknown = "Desconocido", result_as = :hash

    unknown = "Desconocido"
    if options.is_a?(Hash)
      options ={town_code: options[:town_code] || nil, country_code: options[:country_code] || "ES", generate_dc: options[:generate_dc] || false, unknown: options[:unknown] || unknown, result_as: options[:result_as]  || :hash}
    elsif options.is_a?(Numeric) || options.is_a?(String)
      generate_dc = (options.to_s.length == 5)
      options ={town_code: options, country_code: "ES", generate_dc: generate_dc, unknown: unknown, result_as: :hash}
    else
      options ={town_code: nil, country_code: "ES", generate_dc:false, unknown: unknown, result_as: :hash}
    end

    town_code = get_valid_town_code(options[:town_code],options[:country_code],options[:generate_dc])

    if town_code
      country = Carmen::Country.coded(options[:country_code])
      town_name = country.subregions[town_code[2,2].to_i-1].subregions.coded(town_code).name
      province_code= "p_#{town_code[2,2]}"
      province_name = country.subregions[town_code[2,2].to_i-1].name
      autonomy_code = Podemos::GeoExtra::AUTONOMIES[province_code][0]
      autonomy_name = Podemos::GeoExtra::AUTONOMIES[province_code][1]
    else
      unknown = options[:unknown]
      town_code = unknown
      town_name = unknown
      province_code = unknown
      province_name = unknown
      autonomy_code = unknown
      autonomy_name = unknown
    end
    return nil unless town_code
    result = {town_code: town_code, town_name: town_name, province_code: province_code, province_name: province_name, autonomy_code: autonomy_code, autonomy_name: autonomy_name}
    result = OpenStruct.new(result) if (defined?(OpenStruct) && options[:result_as] == :struct)

    return result
  end
end