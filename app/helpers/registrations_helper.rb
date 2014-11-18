module RegistrationsHelper
  def self.region_comparer
    @collator ||= ICU::Collation::Collator.new("es_ES")
    @comparer ||= lambda {|a, b| @collator.compare(a.name, b.name)}
  end

  def self.get_user_location(params, current_user)
    # params from edit page
    user_location = { country: params[:user_country], province: params[:user_province], town: params[:user_town] }

    # params from create page
    if params[:user]
      user_location[:country] ||= params[:user][:country]
      user_location[:province] ||= params[:user][:province]
      user_location[:town] ||= params[:user][:town]
    end

    # params from user profile
    if (params[:no_profile]==nil) && current_user
      user_location[:country] ||= current_user.country
      user_location[:province] ||= current_user.province
      user_location[:town] ||= current_user.town
    end

    # default country
    user_location[:country] ||= "ES"

    user_location
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
