SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: true, # mark all cookies as "Secure"
    httponly: true, # mark all cookies as "HttpOnly"
    samesite: {
      lax: true # mark all cookies as SameSite=lax
    }
  }
  # Add "; preload" and submit the site to hstspreload.org for best protection.
  config.hsts = "max-age=#{20.years.to_i}; includeSubDomains"
  config.x_frame_options = "SAMEORIGIN"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = "origin-when-cross-origin"
  config.clear_site_data = %w(storage) # cookies breaks login on mobile, cache seems to hang mobile chrome browser

  trusted_src = ["'self'", "'unsafe-inline'"]
  trusted_src.push Rails.application.secrets.forms['domain']
  Rails.application.secrets[:secure_sites].each do |site|
    trusted_src.push site
  end if Rails.application.secrets[:secure_sites].present?
  Rails.application.secrets.agora["servers"].each do |id, server|
    trusted_src.push server['url'].gsub('https://', '').gsub('http://','').gsub('/','')
  end if Rails.application.secrets.agora["servers"].present?
  trusted_src.uniq!

  # TO-DO: review this
  config.csp = {
    # "meta" values. these will shape the header, but the values are not included in the header.
    preserve_schemes: true, # default: false. Schemes are removed from host sources to save bytes and discourage mixed content.
    # directive values: these values will directly translate into source directives
    default_src: ["https:", "'self'", "data:"],
    # base_uri: %w('self'),
    # block_all_mixed_content: true, # see http://www.w3.org/TR/mixed-content/
    # child_src: %w('self'), # if child-src isn't supported, the value for frame-src will be set.
    # connect_src: %w(https: 'self'),
    font_src: %w('self' https://fonts.gstatic.com),
    # form_action: %w('self' github.com),
    # frame_ancestors: %w('none'),
    # img_src: %w(mycdn.com data:),
    # manifest_src: %w('self'),
    # media_src: %w(utoob.com),
    # object_src: %w('self'),
    # plugin_types: %w(),
    script_src: trusted_src,
    style_src: trusted_src
    # upgrade_insecure_requests: true, # see https://www.w3.org/TR/upgrade-insecure-requests/
    #report_uri: %w(/csp-report)
  }
  # # This is available only from 3.5.0; use the `report_only: true` setting for 3.4.1 and below.
  # config.csp_report_only = config.csp.merge({
  #   img_src: %w(somewhereelse.com),
  #   report_uri: %w(https://report-uri.io/example-csp-report-only)
  # })
end
