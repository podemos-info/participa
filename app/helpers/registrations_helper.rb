module RegistrationsHelper
  require "ffi-icu"
  
  def self.region_comparer
    @collator ||= ICU::Collation::Collator.new("es_ES")
    @comparer ||= lambda {|a, b| @collator.compare(a.name, b.name)}
  end

  # lists of countries, current country provinces and current province towns, sorted with spanish collation
  def get_countries
    Carmen::Country.all.sort &RegistrationsHelper.region_comparer
  end

  def get_provinces country
    c = Carmen::Country.coded(country)
    if not (c and c.subregions)
      []
    else
      c.subregions.sort &RegistrationsHelper.region_comparer
    end
  end

  def get_towns country, province
    p = if province && country =="ES" then 
          Carmen::Country.coded("ES").subregions.coded(province) 
        end

    if not (p and p.subregions)
      []
    else
      p.subregions.sort &RegistrationsHelper.region_comparer
    end
  end
end
