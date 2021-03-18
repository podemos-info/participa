class Api::V2Controller < ActionController::Base
  skip_before_filter :verify_authenticity_token

  respond_to :json
  before_action :log_api_call
  COMMANDS = ["militants_from_territory"]
  RANGE_NAMES = {exterior: 'exterior'}

  def get_data()
    params.permit(:action, :email, :territory,:timestamp, :command, :signature, :range_name)
    @result = ""
    url_verified, data = self.verify_sign_url(request.original_url,["email", "territory", "timestamp","range_name","command"])
    if url_verified
      columns = [:first_name,:phone,:autonomy_name,:province_name,:island_name,:town_name].join(',')
      vc_data = []
      command = params[:command].strip.downcase
      return @result unless params[:command].present? && COMMANDS.include?(command)
      case command
      when "militants_from_territory"
        @result = nil
        @result += "Email parameter missing " unless params[:email].present?
        @result += "Territory parameter missing " unless params[:territory].present?
        params[:user] = User.find_by_email(params[:email].strip) unless @result
        @result += "User email unknown" unless params[:user].present? && params[:user].present?
        @result ||= get_militants_from_territory params
      else
        @result = "unknown command"
      end
    else
      @result = "signatureError #{data}"
    end
    render json: @result
  end

  def verify_sign_url(url,param_list,len = nil)
    host = Rails.application.secrets.host
    secret = Rails.application.secrets.forms["secret"]
    uri   = URI(url)
    params_hash = URI::decode_www_form(uri.query).to_h
    timestamp = params_hash['timestamp']

    data = "#{uri.scheme}://"
    data += "#{uri.userinfo}@" if uri.userinfo.present?
    data += "#{host}"
    data += "#{uri.path}"
    max = param_list.size
    i = 0
    param_list.each do |k,v|
      sep = i ==0 ? "?" : "&"
      data += "#{sep}#{k}=#{params_hash[k]}" if params_hash[k].present?
      i +=1
    end
    signature = Base64.urlsafe_encode64(OpenSSL::HMAC.digest("SHA256", secret, "#{timestamp}::#{data}"))
    signature = signature[0..len] unless len.nil?
    [signature == params_hash['signature'],data]
  end

  def get_militants_from_territory(params)
    app_user = params[:user]

    territory = nil
    query = User.none
    case params[:territory]
    when "autonomy"
      territory||= app_user.vote_circle.autonomy_code
      vc_query = VoteCircle.where(autonomy_code: territory).pluck(:id,:original_name)
    when "province"
      territory||= app_user.vote_circle.province_code
      vc_query = VoteCircle.where(province_code: territory).pluck(:id,:original_name)
    when "town"
      territory||= app_user.vote_circle.town
      vc_query = VoteCircle.where(town: territory).pluck(:id,:original_name)
    when "island"
      territory||= app_user.vote_circle.island_code
      vc_query = VoteCircle.where(island_code: territory).pluck(:id,:original_name)
    when "circle"
      territory = VoteCircle.exterior.pluck(:id) if params[:range_name] && params[:range_name].downcase == RANGE_NAMES[:exterior]
      territory||= app_user.vote_circle_id
      vc_query = VoteCircle.where(id: territory).pluck(:id,:original_name)
    else
      vc_query = VoteCircle.none
    end
    if vc_query.any?
      data = []
      vc_hash = vc_query.to_h
      vc_ids = vc_hash.keys
      User.militant.where(vote_circle_id: vc_ids).find_each do |u|
        data << {first_name: u.first_name,phone: u.phone,country_name: u.country_name, autonomy_name: u.autonomy_name,province_name: u.province_name,island_name: u.island_name,town_name: u.town_name,circle_name: u.vote_circle.original_name}
      end
      @result = data
    else
      @result = []
    end
    @result
  end

  private



  def api_logger
    @@api_logger ||= Logger.new("#{Rails.root}/log/api.log").tap do |logger|
      logger.formatter = proc do |severity, time, progname, msg|
        "#{time.iso8601} | #{msg}\n"
      end
    end
  end

  def log_api_call
    #api_logger.info "#{request.remote_ip} | #{request.path[1..Float::INFINITY]} | #{request.query_string.split("&").sort.join(" ")}"
    api_logger.info "#{request.remote_ip} | #{request.query_string.split("&").sort.join(" ")}"
  end
end