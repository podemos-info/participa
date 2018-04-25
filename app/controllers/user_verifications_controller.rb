class UserVerificationsController < ApplicationController
  before_action :check_valid_and_verified, only: [:new, :create]

  def new
    @user_verification = UserVerification.for current_user
  end

  def create
    @user_verification = UserVerification.for current_user, user_verification_params
    # if the validation was rejected, restart it
    #@user_verification.status = UserVerification.statuses[:paused] if current_user.autonomy_code == "c_14" # Euskadi convertir en parametro y sacarlo al formulario
    @user_verification.status = UserVerification.statuses[:pending] if @user_verification.rejected? or @user_verification.issues?
    @user_verification.status = UserVerification.statuses[:accepted_by_email] if current_user.photos_unnecessary?
    if @user_verification.save
      if @user_verification.wants_card
        redirect_to(edit_user_registration_path ,flash: { notice: [t('podemos.user_verification.documentation_received'), t('podemos.user_verification.please_check_details')].join("<br>")})
      else
        redirect_to(create_vote_path(election_id: params[:election_id])) and return if params[:election_id]
        redirect_to(root_path, flash: { notice: t('podemos.user_verification.documentation_received')})
      end
    else
      render :new
    end
  end

  def report
    aacc_code = Rails.application.secrets.user_verifications[params[:report_code]]
    filas=[]
    @report = {
                provincias: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } },
                autonomias: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } }
              }

    base_query = User.confirmed.where("vote_town ilike 'm\\___%'")

    # get totals by prov and status
    data = Hash[
              base_query.joins(:user_verifications).group(:prov, :status)
              .pluck("right(left(vote_town,4),2) as prov", "status", "count(distinct users.id)").map { |prov, status, count| [[prov, status], count] }
            ]
    
    # add users totals by prov
    active_date = Date.today - eval(Rails.application.secrets.users["active_census_range"])
    base_query.group(:prov, :active, :verified).pluck(
        "right(left(vote_town,4),2) as prov", 
        "(current_sign_in_at IS NOT NULL AND current_sign_in_at > '#{active_date.to_datetime.iso8601 }') as active", 
        "#{User.verified_condition} as verified", 
        "count(distinct users.id)"
      ).each do |prov, active, verified, count|
        data[[prov, active, verified]] = count
    end

    provinces = Carmen::Country.coded("ES").subregions.map {|p| [ "%02d" % + p.index, p.name ] }

    provinces.each do |province_num, province_name|
      autonomy_code = Podemos::GeoExtra::AUTONOMIES["p_#{province_num}"].first
      autonomy_name = Podemos::GeoExtra::AUTONOMIES["p_#{province_num}"].last
      total_sum = 0
      if aacc_code == 'c_00' or autonomy_code == aacc_code
        UserVerification.statuses.each do |name, status|
          count = data[[province_num, status]] || 0
          @report[:provincias][province_name][name.to_sym] = count
          @report[:autonomias][autonomy_name][name.to_sym] += count
          total_sum += count
        end
        @report[:provincias][province_name][:total] = total_sum
        @report[:autonomias][autonomy_name][:total] += total_sum

        active_verified = data[[province_num, true, true]] || 0
        active = active_verified + (data[[province_num, true, false]] || 0)
        inactive_verified = data[[province_num, false, true]] || 0
        inactive = inactive_verified + (data[[province_num, false, false]] || 0)

        @report[:provincias][province_name][:users] = active + inactive
        @report[:provincias][province_name][:verified] = active_verified + inactive_verified
        @report[:autonomias][autonomy_name][:users] += active + inactive
        @report[:autonomias][autonomy_name][:verified] += active_verified + inactive_verified
        @report[:provincias][province_name][:active] = active
        @report[:provincias][province_name][:active_verified] = active_verified
        @report[:autonomias][autonomy_name][:active] += active
        @report[:autonomias][autonomy_name][:active_verified] += active_verified
        end
      end

    @report
  end

  def report_town
    aacc_code = Rails.application.secrets.user_verifications[params[:report_code]]
    towns_ids = ['m_04_066_9', 'm_04_100_2', 'm_11_015_9', 'm_11_022_3', 'm_11_008_6', 'm_11_028_2', 'm_11_031_6',
             'm_11_035_5', 'm_11_032_1', 'm_11_012_5', 'm_18_089_6', 'm_18_101_5', 'm_18_911_5', 'm_18_140_0',
             'm_18_087_7', 'm_21_072_0', 'm_21_041_2', 'm_23_009_8', 'm_23_053_1', 'm_23_055_9', 'm_23_044_9',
             'm_29_069_1', 'm_29_082_5', 'm_29_901_8', 'm_29_025_2', 'm_29_070_5', 'm_41_004_2', 'm_41_038_4',
             'm_41_070_4', 'm_41_040_1', 'm_41_041_8', 'm_41_081_9', 'm_41_017_2', 'm_41_086_1', 'm_41_091_7',
             'm_33_004_5', 'm_33_024_1', 'm_33_044_7', 'm_35_003_8', 'm_35_018_9', 'm_35_021_3', 'm_35_015_4',
             'm_35_006_9', 'm_35_022_8', 'm_35_026_5', 'm_35_028_7', 'm_35_009_4', 'm_35_016_7', 'm_38_010_3',
             'm_38_032_1', 'm_38_046_6', 'm_38_048_8', 'm_38_038_0', 'm_38_001_2', 'm_38_023_9', 'm_05_014_7',
             'm_05_019_8', 'm_09_219_4', 'm_09_018_3', 'm_24_222_5', 'm_24_202_9', 'm_24_115_2', 'm_24_142_2',
             'm_34_023_1', 'm_34_120_2', 'm_40_194_5', 'm_42_173_6', 'm_47_010_5', 'm_47_076_1', 'm_47_186_8',
             'm_49_275_5', 'm_28_013_3', 'm_28_014_8', 'm_28_045_5', 'm_28_007_2', 'm_28_047_4', 'm_28_049_3',
             'm_28_065_0', 'm_28_006_6', 'm_28_106_5', 'm_28_123_0', 'm_28_115_0', 'm_28_134_3', 'm_28_113_2',
             'm_28_096_7', 'm_28_130_0', 'm_28_903_6', 'm_28_061_1', 'm_10_023_2', 'm_28_181_6', 'm_28_054_9',
             'm_28_141_5', 'm_28_167_8', 'm_28_046_8', 'm_28_005_3', 'm_28_148_9', 'm_28_127_7', 'm_28_108_7',
             'm_28_145_4', 'm_28_095_4', 'm_28_082_2', 'm_28_092_0', 'm_28_074_5', 'm_28_058_7', 'm_08_169_1',
             'm_08_284_5', 'm_08_904_5', 'm_08_196_0', 'm_08_155_5', 'm_08_279_8', 'm_08_096_1', 'm_08_089_8',
             'm_08_266_5', 'm_08_124_9', 'm_08_209_3', 'm_08_019_3', 'm_08_101_7', 'm_08_187_8', 'm_17_079_2',
             'm_25_120_7', 'm_43_904_4', 'm_43_148_2', 'm_03_049_4', 'm_03_009_2', 'm_03_104_0', 'm_03_122_5',
             'm_03_079_7', 'm_03_139_5', 'm_03_071_0', 'm_03_090_9', 'm_03_099_3', 'm_03_050_7', 'm_03_018_7',
             'm_03_066_4', 'm_03_014_9', 'm_03_065_1', 'm_12_138_4', 'm_12_077_0', 'm_12_126_4', 'm_12_084_6',
             'm_12_027_1', 'm_12_040_2', 'm_46_147_7', 'm_46_184_6', 'm_46_094_5', 'm_46_233_1', 'm_46_214_0',
             'm_46_021_4', 'm_46_005_7', 'm_46_177_0', 'm_46_202_1', 'm_46_190_1', 'm_46_230_3', 'm_03_096_8',
             'm_17_197_8', 'm_46_078_7', 'm_46_013_7', 'm_46_070_6', 'm_46_105_6', 'm_46_031_2', 'm_46_256_7',
             'm_46_258_9', 'm_46_249_5', 'm_46_213_5', 'm_46_126_5', 'm_46_035_1', 'm_46_102_2', 'm_46_131_1',
             'm_46_250_8', 'm_01_059_0', 'm_48_002_5', 'm_48_027_4', 'm_48_032_9', 'm_48_902_6', 'm_48_044_8',
             'm_48_054_5', 'm_48_071_5', 'm_48_083_4', 'm_48_078_9', 'm_48_084_9', 'm_48_085_2', 'm_48_080_6',
             'm_48_089_0', 'm_48_045_1', 'm_48_013_9', 'm_48_036_6', 'm_48_069_4', 'm_48_082_8', 'm_48_020_9',
             'm_20_030_0', 'm_20_045_4', 'm_20_064_6', 'm_20_071_8', 'm_20_067_8', 'm_06_015_3', 'm_07_011_0',
             'm_07_033_7', 'm_07_015_9', 'm_07_026_0', 'm_07_061_9', 'm_07_003_3', 'm_07_062_4', 'm_07_010_3',
             'm_07_056_3', 'm_07_046_6', 'm_07_054_7', 'm_07_036_8', 'm_07_048_8', 'm_07_050_4', 'm_07_029_5',
             'm_31_060_8', 'm_31_902_4', 'm_30_003_2', 'm_30_019_6', 'm_30_027_5', 'm_30_017_7', 'm_30_008_5',
             'm_30_005_0', 'm_30_024_3', 'm_30_035_4', 'm_30_026_9', 'm_30_038_9', 'm_30_030_8', 'm_30_016_1',
             'm_52_001_8', 'm_33_011_7']
    towns_hash = {"p_01"=>["m_01_059_0"],
                  "p_02"=>[],
                  "p_03"=>["m_03_009_2", "m_03_014_9", "m_03_018_7", "m_03_049_4", "m_03_050_7", "m_03_065_1", "m_03_066_4", "m_03_071_0", "m_03_079_7", "m_03_090_9", "m_03_096_8", "m_03_099_3", "m_03_104_0", "m_03_122_5", "m_03_139_5"],
                  "p_04"=>["m_04_066_9", "m_04_100_2"],
                  "p_05"=>["m_05_014_7", "m_05_019_8"],
                  "p_06"=>["m_06_015_3"],
                  "p_07"=>["m_07_003_3", "m_07_010_3", "m_07_011_0", "m_07_015_9", "m_07_026_0", "m_07_029_5", "m_07_033_7", "m_07_036_8", "m_07_046_6", "m_07_048_8", "m_07_050_4", "m_07_054_7", "m_07_056_3", "m_07_061_9", "m_07_062_4"],
                  "p_08"=>["m_08_019_3", "m_08_089_8", "m_08_096_1", "m_08_101_7", "m_08_124_9", "m_08_155_5", "m_08_169_1", "m_08_187_8", "m_08_196_0", "m_08_209_3", "m_08_266_5", "m_08_279_8", "m_08_284_5", "m_08_904_5"],
                  "p_09"=>["m_09_018_3", "m_09_219_4"],
                  "p_10"=>["m_10_023_2"],
                  "p_11"=>["m_11_008_6", "m_11_012_5", "m_11_015_9", "m_11_022_3", "m_11_028_2", "m_11_031_6", "m_11_032_1", "m_11_035_5"],
                  "p_12"=>["m_12_027_1", "m_12_040_2", "m_12_077_0", "m_12_084_6", "m_12_126_4", "m_12_138_4"],
                  "p_13"=>[],
                  "p_14"=>[],
                  "p_15"=>[],
                  "p_16"=>[],
                  "p_17"=>["m_17_079_2", "m_17_197_8"],
                  "p_18"=>["m_18_087_7", "m_18_089_6", "m_18_101_5", "m_18_140_0", "m_18_911_5"],
                  "p_19"=>[],
                  "p_20"=>["m_20_030_0", "m_20_045_4", "m_20_064_6", "m_20_067_8", "m_20_071_8"],
                  "p_21"=>["m_21_041_2", "m_21_072_0"],
                  "p_22"=>[],
                  "p_23"=>["m_23_009_8", "m_23_044_9", "m_23_053_1", "m_23_055_9"],
                  "p_24"=>["m_24_115_2", "m_24_142_2", "m_24_202_9", "m_24_222_5"],
                  "p_25"=>["m_25_120_7"],
                  "p_26"=>[],
                  "p_27"=>[],
                  "p_28"=>["m_28_005_3", "m_28_006_6", "m_28_007_2", "m_28_013_3", "m_28_014_8", "m_28_045_5", "m_28_046_8", "m_28_047_4", "m_28_049_3", "m_28_054_9", "m_28_058_7", "m_28_061_1", "m_28_065_0", "m_28_074_5", "m_28_082_2", "m_28_092_0", "m_28_095_4", "m_28_096_7", "m_28_106_5", "m_28_108_7", "m_28_113_2", "m_28_115_0", "m_28_123_0", "m_28_127_7", "m_28_130_0", "m_28_134_3", "m_28_141_5", "m_28_145_4", "m_28_148_9", "m_28_167_8", "m_28_181_6", "m_28_903_6"],
                  "p_29"=>["m_29_025_2", "m_29_069_1", "m_29_070_5", "m_29_082_5", "m_29_901_8"],
                  "p_30"=>["m_30_003_2", "m_30_005_0", "m_30_008_5", "m_30_016_1", "m_30_017_7", "m_30_019_6", "m_30_024_3", "m_30_026_9", "m_30_027_5", "m_30_030_8", "m_30_035_4", "m_30_038_9"],
                  "p_31"=>["m_31_060_8", "m_31_902_4"],
                  "p_32"=>[],
                  "p_33"=>["m_33_004_5", "m_33_011_7", "m_33_024_1", "m_33_044_7"],
                  "p_34"=>["m_34_023_1", "m_34_120_2"],
                  "p_35"=>["m_35_003_8", "m_35_006_9", "m_35_009_4", "m_35_015_4", "m_35_016_7", "m_35_018_9", "m_35_021_3", "m_35_022_8", "m_35_026_5", "m_35_028_7"],
                  "p_36"=>[],
                  "p_37"=>[],
                  "p_38"=>["m_38_001_2", "m_38_010_3", "m_38_023_9", "m_38_032_1", "m_38_038_0", "m_38_046_6", "m_38_048_8"],
                  "p_39"=>[],
                  "p_40"=>["m_40_194_5"],
                  "p_41"=>["m_41_004_2", "m_41_017_2", "m_41_038_4", "m_41_040_1", "m_41_041_8", "m_41_070_4", "m_41_081_9", "m_41_086_1", "m_41_091_7"],
                  "p_42"=>["m_42_173_6"],
                  "p_43"=>["m_43_148_2", "m_43_904_4"],
                  "p_44"=>[],
                  "p_45"=>[],
                  "p_46"=>["m_46_005_7", "m_46_013_7", "m_46_021_4", "m_46_031_2", "m_46_035_1", "m_46_070_6", "m_46_078_7", "m_46_094_5", "m_46_102_2", "m_46_105_6", "m_46_126_5", "m_46_131_1", "m_46_147_7", "m_46_177_0", "m_46_184_6", "m_46_190_1", "m_46_202_1", "m_46_213_5", "m_46_214_0", "m_46_230_3", "m_46_233_1", "m_46_249_5", "m_46_250_8", "m_46_256_7", "m_46_258_9"],
                  "p_47"=>["m_47_010_5", "m_47_076_1", "m_47_186_8"],
                  "p_48"=>["m_48_002_5", "m_48_013_9", "m_48_020_9", "m_48_027_4", "m_48_032_9", "m_48_036_6", "m_48_044_8", "m_48_045_1", "m_48_054_5", "m_48_069_4", "m_48_071_5", "m_48_078_9", "m_48_080_6", "m_48_082_8", "m_48_083_4", "m_48_084_9", "m_48_085_2", "m_48_089_0", "m_48_902_6"],
                  "p_49"=>["m_49_275_5"],
                  "p_50"=>[],
                  "p_51"=>[],
                  "p_52"=>["m_52_001_8"]}

    filas=[]
    @report_town = {
        provincias: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } },
        autonomias: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } },
        municipios: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } },
    }

    base_query = User.confirmed.where("vote_town in (?)", towns_ids)

    # get totals by prov and status
    data = Hash[
        base_query.joins(:user_verifications).group(:prov, :status)
            .pluck("right(left(vote_town,4),2) as prov", "status", "count(distinct users.id)").map { |prov, status, count| [[prov, status], count] }
    ]

    # add users totals by prov
    active_date = Date.today - eval(Rails.application.secrets.users["active_census_range"])
    base_query.group(:prov, :active, :verified).pluck(
        "right(left(vote_town,4),2) as prov",
        "(current_sign_in_at IS NOT NULL AND current_sign_in_at > '#{active_date.to_datetime.iso8601 }') as active",
        "#{User.verified_condition} as verified",
        "count(distinct users.id)"
    ).each do |prov, active, verified, count|
      data[[prov, active, verified]] = count
    end

    # get totals by town and status
    data_town = Hash[
        base_query.joins(:user_verifications).group(:vote_town, :status)
            .pluck("vote_town", "status", "count(distinct users.id)").map { |town, status, count| [[town, status], count] }
    ]

    # add users totals by town
    active_date = Date.today - eval(Rails.application.secrets.users["active_census_range"])
    base_query.group(:vote_town, :active, :verified).pluck(
        "vote_town",
        "(current_sign_in_at IS NOT NULL AND current_sign_in_at > '#{active_date.to_datetime.iso8601 }') as active",
        "#{User.verified_condition} as verified",
        "count(distinct users.id)"
    ).each do |town, active, verified, count|
      data_town[[town, active, verified]] = count
    end

    provinces = Carmen::Country.coded("ES").subregions.map {|p| [ "%02d" % + p.index, p.name ] }
    provinces.each do |province_num, province_name|
      towns_hash["p_#{province_num}"].each do |vote_town_num|
        autonomy_code = Podemos::GeoExtra::AUTONOMIES["p_#{province_num}"].first
        autonomy_name = Podemos::GeoExtra::AUTONOMIES["p_#{province_num}"].last
        puts("#{province_num}  #{vote_town_num}")
        vote_town_name = Carmen::Country.coded("ES").subregions[province_num.to_i - 1].subregions.coded(vote_town_num).name
        total_mun_sum = 0
        if aacc_code == 'c_00' or autonomy_code == aacc_code
          UserVerification.statuses.each do |name, status|
            count = data_town[[vote_town_num, status]] || 0
            @report_town[:municipios][vote_town_name][name.to_sym] = count
            total_mun_sum += count
          end
          @report_town[:municipios][vote_town_name][:total] = total_mun_sum

          town_active_verified = data_town[[vote_town_num, true, true]] || 0
          town_active = town_active_verified + (data_town[[vote_town_num, true, false]] || 0)
          town_inactive_verified = data_town[[vote_town_num, false, true]] || 0
          town_inactive = town_inactive_verified + (data_town[[vote_town_num, false, false]] || 0)

          @report_town[:municipios][vote_town_name][:users] = town_active + town_inactive
          @report_town[:municipios][vote_town_name][:verified] = town_active_verified + town_inactive_verified
          @report_town[:provincias][vote_town_name][:active] = town_active
          @report_town[:provincias][vote_town_name][:active_verified] = town_active_verified
        end
      end

      total_sum = 0
      autonomy_code = Podemos::GeoExtra::AUTONOMIES["p_#{province_num}"].first
      autonomy_name = Podemos::GeoExtra::AUTONOMIES["p_#{province_num}"].last
      if aacc_code == 'c_00' or autonomy_code == aacc_code
        UserVerification.statuses.each do |name, status|
          count = data[[province_num, status]] || 0
          @report_town[:provincias][province_name][name.to_sym] = count
          @report_town[:autonomias][autonomy_name][name.to_sym] += count
          total_sum += count
        end
        @report_town[:provincias][province_name][:total] = total_sum
        @report_town[:autonomias][autonomy_name][:total] += total_sum

        active_verified = data[[province_num, true, true]] || 0
        active = active_verified + (data[[province_num, true, false]] || 0)
        inactive_verified = data[[province_num, false, true]] || 0
        inactive = inactive_verified + (data[[province_num, false, false]] || 0)

        @report_town[:provincias][province_name][:users] = active + inactive
        @report_town[:provincias][province_name][:verified] = active_verified + inactive_verified
        @report_town[:autonomias][autonomy_name][:users] += active + inactive
        @report_town[:autonomias][autonomy_name][:verified] += active_verified + inactive_verified
        @report_town[:provincias][province_name][:active] = active
        @report_town[:provincias][province_name][:active_verified] = active_verified
        @report_town[:autonomias][autonomy_name][:active] += active
        @report_town[:autonomias][autonomy_name][:active_verified] += active_verified
      end
    end
    @report_town
  end

  def report_exterior
    aacc_code = Rails.application.secrets.user_verifications[params[:report_code]]
    filas=[]
    @report_exterior = {
        paises: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } }
    }

    base_query = User.confirmed.where("country <> 'ES'")

    # get totals by country and status
    data = Hash[
        base_query.joins(:user_verifications).group(:country, :status)
            .pluck("country", "status", "count(distinct users.id)").map { |country, status, count| [[country, status], count] }
    ]

    # add users totals by country
    active_date = Date.today - eval(Rails.application.secrets.users["active_census_range"])
    base_query.group(:country, :active, :verified).pluck(
        "country",
        "(current_sign_in_at IS NOT NULL AND current_sign_in_at > '#{active_date.to_datetime.iso8601 }') as active",
        "#{User.verified_condition} as verified",
        "count(distinct users.id)"
    ).each do |country, active, verified, count|
      data[[country, active, verified]] = count
    end

    countries = Hash[ Carmen::Country.all.map do |c| [ c.code,c.name ] end ]
    countries["Desconocido"] = [0]*4

    countries.each do |country_cod, country_name|
      total_sum = 0
      if aacc_code =='c_99'
        UserVerification.statuses.each do |name, status|
          count = data[[country_cod, status]] || 0
          @report_exterior[:paises][country_name][name.to_sym] = count
          total_sum += count
        end
        @report_exterior[:paises][country_name][:total] = total_sum

        active_verified = data[[country_cod, true, true]] || 0
        active = active_verified + (data[[country_cod, true, false]] || 0)
        inactive_verified = data[[country_cod, false, true]] || 0
        inactive = inactive_verified + (data[[country_cod, false, false]] || 0)

        @report_exterior[:paises][country_name][:users] = active + inactive
        @report_exterior[:paises][country_name][:verified] = active_verified + inactive_verified
        @report_exterior[:paises][country_name][:active] = active
        @report_exterior[:paises][country_name][:active_verified] = active_verified
      end
    end
    @report_exterior
  end
  private
  def check_valid_and_verified
    if current_user.has_not_future_verified_elections?
      redirect_to(root_path, flash: { notice: t('podemos.user_verification.user_not_valid_to_verify') })
    elsif current_user.verified? && current_user.photos_necessary?
      redirect_to(root_path, flash: { notice: t('podemos.user_verification.user_already_verified') })
    end
  end
  def user_verification_params
    params.require(:user_verification).permit(:procesed_at, :front_vatid, :back_vatid, :terms_of_service, :wants_card)
  end
end
