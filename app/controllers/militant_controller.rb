class MilitantController < ActionController::Base
  before_filter :authenticate_user!

  def get_militant_info
    pc =PageController.new
    @result = ""
    url_verified, data = self.verify_sign_url(request.original_url)
    if url_verified
      exemption = params[:exemption]
      current_user.update(exempt_from_payment: exemption)
      current_user.update(militant:current_user.still_militant?)
      #redirect_to(session.delete(:return_to)||root_path, flash: { notice: "El formulario ha sido rellenado y procesado correctamente" })
      @result = "OK#{exemption} #{data}"
    else
      @result = "signatureError #{data}"
    end
  end

  def verify_sign_url(url)
    host = Rails.application.secrets.host
    secret = Rails.application.secrets.forms["secret"]
    uri   = URI(url)
    params_hash = URI::decode_www_form(uri.query).to_h
    timestamp =params_hash['timestamp']

    data = "#{uri.scheme}://"
    data += "#{uri.userinfo}@" if uri.userinfo.present?
    data += "#{host}"
    data += "#{uri.path}"
    data += "?participa_user_id=#{current_user.id}"
    data += "&exemption=#{params_hash['exemption']}"

    signature = Base64.urlsafe_encode64(OpenSSL::HMAC.digest("SHA256", secret, "#{timestamp}::#{data}"))[0..27]
    [signature == params_hash['signature'],data]
  end
end