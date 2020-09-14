module ApplicationHelper
  def route
    "#{ params[:controller] }/#{ params[:action] }"
  end

  def sign_in_url
    continue = session[:continue] || request.fullpath
    if ssl_configured?
      sessions_url(protocol: "https", continue: continue)
    else
      sessions_url(protocol: "http", continue: continue)
    end
  end

  def sign_up_url
    continue = session[:continue] || request.fullpath
    if ssl_configured?
      user_url(protocol: "https", continue: continue)
    else
      user_url(continue: continue)
    end
  end

  def secure_update_password_url
    if ssl_configured?
      update_password_url(protocol: 'https')
    else
      update_password_url
    end
  end

  def secure_request_token_url
    if ssl_configured?
      request_token_url(protocol: 'https')
    else
      request_token_url
    end
  end

  def signed_in?
    session[:current_user].present?
  end

  def ssl_configured?
    !Rails.env.development? && !Rails.env.test?
  end

  def show_card?
    @skin && (@skin.loyalty_features["supports_history"] || @skin.loyalty_features["supports_join"] || @skin.loyalty_features["supports_link_card"])
  end

  def redirect_to_continue(default = root_path)
    return CGI::unescape(session['continue'] || default)
  end

  def clear_continue!
    session[:continue] = nil
  end

  def my_order_text
    if !params["group_order_token"].blank? || (session[:order] && !session[:order][:meta][:group_order_token].blank?)
      "My group order"
    elsif is_wtjmmj?
      "My reservation"
    else
      "My order"
    end
  end

  def loyalty_link_text
    "Rewards"
  end

  def navbar_logo_url
    "//d38o1hjtj2mzwt.cloudfront.net/#{ @skin.external_identifier }/web/brand-assets/logo.png"
  end

  def is_punchh?
    session[:punch_auth_token].present?
  end

  def is_wtjmmj?
    @skin.external_identifier == "com.splickit.wtjmmj"
  end

  def is_pitapit?
    @skin.external_identifier == "com.splickit.pitapit"
  end

  def title(text)
    text.to_s.gsub("_", " ")
  end

  def css_class(text)
    text.to_s.gsub(" ", "-").downcase
  end

  def to_js(hash)
    Oj.dump(hash).html_safe
  end

  def confirmation_page?
    route.downcase == "checkouts/show"
  end

  def static_mapbox_url(params = {})
    lat = params[:lat]
    lng = params[:lng]
    size = params[:size] || "516x300"
    zoom = params[:zoom] || "17"
    "https://api.mapbox.com/styles/v1/mapbox/streets-v9/static/geojson(%7B%22type%22%3A%22Point%22%2C%22coordinates%22%3A%5B#{ lng }%2C#{ lat }%5D%7D)/#{ lng },#{ lat },#{ zoom }/#{ size }?access_token=#{ Rails.application.config.mapbox_token }#15/48.8446/2.3114"
  end

  def get_loyalty_logo_url
    if Rails.env.production?
      "//d38o1hjtj2mzwt.cloudfront.net/#{ @skin.external_identifier }/web/brand-assets/loyalty_logo.png"
    end
    if Rails.env.previewprod?
      "//s3.amazonaws.com/com.splickit.products.preview/#{ @skin.external_identifier }/web/brand-assets/loyalty_logo.png"
    end
    if Rails.env.development? || Rails.env.staging? || Rails.env.test? || Rails.env.preview?
      "//s3.amazonaws.com/com.splickit.products.test/#{ @skin.external_identifier }/web/brand-assets/loyalty_logo.png"
    end
  end
end
