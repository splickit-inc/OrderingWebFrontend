require "request_store"
require "cgi"
require "exceptions"

class ApplicationController < ActionController::Base
  rescue_from StandardError, with: :log_error_and_redirect
  rescue_from OrderingDown, with: :ordering_down

  before_action :set_client_device
  before_action :set_session_uuid, :log_user_agent, :setup_skin_id, :redirect_if_old, :set_user_instance,
                :redirect_unsupported_mobile_browsers, :sign_in_punchh, except: [:ordering_down]
  helper_method :current_user, :current_user_id, :current_user_name, :current_user_email,
                :current_user_auth_token_hash, :order_type, :delivery?, :get_secure_form_data,
                :skin_facebook_app_id, :get_skin_name_from_domain

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  skip_before_action :verify_authenticity_token

  add_flash_types :error, :form_error

  include SessionsHelper

  SENSITIVE_DATA = [:password, :password_confirmation]

  def log_error_and_redirect(exception)
    Rails.logger.error exception.message
    Rails.logger.error exception.backtrace
    if Rails.env.development?
      raise exception
    else
      Airbrake.notify_sync(exception,
                           error_message: "#{ exception.class.name }: #{ exception.message }",
                           parameters: {request: {fullpath: request.fullpath,
                                                  query_parameters: request.query_parameters.inspect,
                                                  params: request.params.inspect,
                                                  original_fullpath: request.original_fullpath,
                                                  original_url: request.original_url,
                                                  url: request.url},
                                        session: {order: session[:order].inspect,
                                                  last_order: session[:last_order],
                                                  current_user: session[:current_user].inspect,
                                                  tip_selected: session[:tip_selected],
                                                  time_selected: session[:time_selected],
                                                  note_value: session[:note_value],
                                                  promo_code_value: session[:promo_code_value],
                                                  uuid: session[:uuid],
                                                  continue: session[:continue],
                                                  override_skin: session[:override_skin],
                                                  location: session[:location],
                                                  lat: session[:lat],
                                                  lng: session[:lng],
                                                  last_merchant_seen: session[:last_merchant_seen]},
                                        cookies: {userPrefs: cookies[:userPrefs].inspect,
                                                  orderDetail: cookies[:orderDetail].inspect}})
      respond_to do |format|
        format.html {redirect_to error_500_path}
        format.json {render json: {error: exception.message}, status: :unprocessable_entity}
      end
    end
  end

  def set_session_uuid
    session[:uuid] = SecureRandom.uuid unless session[:uuid]
    RequestStore.store[:session_uuid] = session[:uuid]
  end

  def log_user_agent
    if RequestStore.store[:user_agent]
      user_agent = UserAgent.parse(request.user_agent)
      Rails.logger.info "User agent browser: #{user_agent.browser}, User agent version: #{user_agent.version}, User agent platform: #{user_agent.platform}"
      RequestStore.store[:user_agent] = request.user_agent
    end
  end

  def redirect_unsupported_mobile_browsers
    user_agent = UserAgent.parse(request.user_agent)
    if user_agent.browser == "Safari" && (user_agent.platform == "iPad" || user_agent.platform == "iPhone") && user_agent.version < "8"
      redirect_to app_path
    end
  end

  def set_client_device
    user_agent = UserAgent.parse(request.user_agent)

    Rails.logger.info "User agent: #{ request.user_agent }"
    Rails.logger.info "User agent browser: #{user_agent.browser}, User agent version: #{user_agent.version}, User agent platform: #{user_agent.platform}"

    if user_agent.mobile? || (user_agent.browser == "Opera" && request.user_agent =~ /Android/)
      RequestStore.store[:client_device] = 'web-mobile'
    else
      RequestStore.store[:client_device] = 'web'
    end

  end

  # Refresh the session_user if the api_request is true and not refresh if api_request is false
  def set_user_instance(api_request = false)
    refresh_user_if_has_cookie(api_request)
    if signed_in?
      if api_request
        @user = User.find(current_user_id,
                          session[:current_user]["splickit_authentication_token"])
        set_user_session(@user)
      else
        @user = User.new(session[:current_user])
      end
    end
  end

  def refresh_user_if_has_cookie(api_request)
    if cookies[:remember_me].present? && !signed_in? && !api_request
      remember_user = JSON.parse(cookies[:remember_me])
      user_params = {
          email: "splickit_authentication_token",
          password: remember_user["splickit_authentication_token"]
      }
      begin
        set_user_session(User.authenticate(user_params))
      rescue
        sign_out
      end
    end
  end

  def set_user_session(user)
    if user.nil?
      sign_out
    else
      session[:current_user] = {"user_id" => user.user_id,
                                "first_name" => user.first_name,
                                "last_name" => user.last_name,
                                "email" => user.email,
                                "contact_no" => user.contact_no,
                                "last_four" => user.last_four,
                                "delivery_locations" => user.delivery_locations,
                                "brand_loyalty" => user.brand_loyalty,
                                "flags" => user.flags,
                                "balance" => user.balance,
                                "group_order_token" => user.group_order_token,
                                "marketing_email_opt_in" => user.marketing_email_opt_in,
                                "zipcode" => user.zipcode,
                                "birthday" => user.birthday,
                                "privileges" => user.privileges,
                                "splickit_authentication_token" => user.splickit_authentication_token}
    end
  end

  def update_current_user(attr = {})
    attr.keys.each {|key| session[:current_user][key.to_s] = attr[key]} if signed_in?
  end

  def sign_in_punchh
    begin
      if params[:security_token].present? && !signed_in?
        sign_in(punch_authentication_token: params[:security_token])
        session[:punch_auth_token] = params[:security_token]
      end
    rescue APIError => e
      flash.now[:error] = e.message
    end
  end

  def current_user
    return @user if @user.present?
    User.new(session[:current_user]) if signed_in?
  end

  def current_user_id
    return session[:current_user]["user_id"] if @user.blank? && signed_in?
    @user.user_id if signed_in?
  end

  def current_user_name
    return "#{ session[:current_user]["first_name"] } #{ session[:current_user]["last_name"] }" if @user.blank? && signed_in?
    @user.full_name if signed_in?
  end

  def current_user_email
    return session[:current_user]["email"] if @user.blank? && signed_in?
    @user.email if signed_in?
  end

  def set_current_group_order_token(token)
    @user.group_order_token = token unless @user == nil
    session[:current_user]["group_order_token"] = token
  end

  def current_user_auth_token_hash
    return {user_auth_token: session[:current_user]["splickit_authentication_token"]} if @user.blank? && signed_in?
    {user_auth_token: @user.splickit_authentication_token} if signed_in?
  end

  def order_type
    @order_type = params[:order_type] || (params[:order] && params[:order][:order_type]) || "pickup"
  end

  def delivery?(other_order_type = nil)
    return other_order_type.downcase == "delivery" if other_order_type.present?
    order_type.downcase == "delivery"
  end

  def is_wtjmmj?
    @skin.external_identifier == "com.splickit.wtjmmj"
  end

  def redirect_if_signed_out
    redirect_to(sign_in_path(continue: request.fullpath)) unless signed_in?
  end

  def redirect_if_guest
    if current_user && current_user.is_guest?
      respond_to do |format|
        format.json {render json: {error: "Unauthorized"}, status: 401}
        format.html {redirect_to root_path}
      end
    end
  end

  def ssl_configured?
    !Rails.env.development? && !Rails.env.test?
  end

  def get_secure_form_data
    vio_credentials = JSON.parse(API.get("/users/credit_card/getviowritecredentials",
                                         {use_admin: true}).body)["data"]["vio_write_credentials"].split(":")
    @account = vio_credentials.first
    @token = vio_credentials[1]
  end

  def decode_params(params)
    params.each do |key, value|
      begin
        params[key] = Base64.strict_decode64(value) if SENSITIVE_DATA.include?(key.to_sym)
      rescue StandardError
        params[key] = value
      end
    end
  end

  def skin_facebook_app_id
    FACEBOOK_CONFIG[get_skin_name_from_domain]
  end

  private

  def ordering_down(exception)
    Rails.logger.error exception.message
    Rails.logger.error exception.backtrace
    if Rails.env.development?
      raise exception
    else
      Airbrake.notify_or_ignore(exception, error_message: "#{ exception.class.name }: #{ exception.message }")
      session[:error_590] = exception.message
      redirect_to error_590_path
    end
  end

  def redirect_to_continue(default = root_path)
    redirect_to CGI::unescape(session[:continue] || default)
    clear_continue!
  end

  def redirect_if_signed_in
    return unless session[:current_user].present?
    flash[:notice] = "You're already logged in with the account: #{session[:current_user]["email"]}"
    redirect_to root_path
  end

  def redirect_if_wrong_delivery_data
    if delivery?
      merchant_id = params[:merchant_id] || params[:id]

      raise MissingAddress.new("Please select a valid delivery address.") if cookies[:userPrefs].blank?

      @user_addr_id = JSON.parse(cookies[:userPrefs])["preferredAddressId"]

      unless Merchant.in_delivery_area?(merchant_id, @user_addr_id, '', current_user_auth_token_hash)
        respond_to do |format|
          format.json {render json: {error: "Sorry, that address isn't in range."}, status: :unprocessable_entity}
          format.html {redirect_to :back, flash: {error: "Sorry, that address isn't in range."}}
        end
      end
    end
  rescue APIError => e
    respond_to do |format|
      format.json {render json: {error: e.message}, status: :unprocessable_entity}
      format.html {redirect_to :back, flash: {error: e.message}}
    end
  rescue MissingAddress => e
    redirect_to root_path, flash: {error: e.message}
  end

  def clear_continue!
    session[:continue] = nil
  end

  def check_continue_to_guest
    if !!session[:continue] && (session[:continue].include? "group_orders")
      clear_continue!
    end
  end

  def set_continue
    session[:continue] = (params_continue || session[:continue])
  end

  def signed_in?
    session[:current_user].present?
  end

  def override_skin?
    (params[:override_skin] || session[:override_skin]) && params[:override_skin] != "clear"
  end

  def setup_skin_id
    Skin.current_name = if override_skin?
                          session[:override_skin] = params[:override_skin] || session[:override_skin]
                        else
                          session.delete(:override_skin)
                          get_skin_name_from_domain
                        end

    setup_skin_for_skin_name(Skin.current_name)
  end

  def get_skin_name_from_subdomain(subdomain)
    subdomain.gsub(/-order.*/, "")
  end

  def get_skin_name_from_domain
    host = request.host.gsub(/^www./, "")

    Rails.logger.info("HOST: #{ host }")
    Rails.logger.info("REQUEST: #{ request.inspect }") unless Rails.env.production?

    case host
      when /localhost|::1|\.dev$/, Resolv::IPv4::Regex then
        "order"
      when /moes-punchh/ then
        "moes"
      when /moes/ then
        "moes"
      when /bibibop/ then
        "bibibop"
      when /getbellyfull/ then
        "bellyfull"
      when /tullyscoffeeshops/ then
        "tullys"
      when /cornercafecs/ then
        "cornercafe"
      when /fuddruckers/ then
        "fuddruckers"
      when /eatchronictacos/ then
        "chronictacos"
      when /goodcentssubs/ then
        "goodcentssubs"
      when /juiceitup/ then
        "juiceitup"
      when /amicis/ then
        "amicis"
      when /vitossm/ then
        "vitossm"
      when /currito/ then
        "currito"
      when /vito\.pizza-order/ then
        "vitossm"
      when /order\.vito/ then
        "vitossm"
      when /substationii/ then
        "substationii"
      when /substationii-order/ then
        "substationii"
      when /citybird/ then
        "citybird"
      when /osf/ then
        "osf"
      when /illegalpetes/ then
        "illegalpetes"
      else
        subdomains = host.split(".")
        skin_name = get_skin_name_from_subdomain(subdomains.first) if subdomains.length > 2
        skin_name = "order" if skin_name.blank?
        skin_name
    end
  end

  def redirect_if_old
    domain_old = 'splickit-test'
    domain_new = 'order140-test'
    if Rails.env.production?
      domain_old = 'splickit'
      domain_new = 'order140'
    end
    if request.host.include? domain_old
       new_host = request.host.gsub(domain_old, domain_new)
      redirect_to "#{request.protocol}#{new_host}#{request.fullpath}", :status => :moved_permanently
    end

  end

  def setup_skin_for_skin_name(skin_name)
    begin
      @skin = Skin.where skin_identifier: skin_name
    rescue
      @skin = Skin.where skin_identifier: "order"
    end
  end

  def params_continue
    if params[:continue].present?
      if !already_escaped(params[:continue])
        CGI::escape(params[:continue])
      else
        params[:continue]
      end
    end
  end

  def delete_checkout_detail_data
    cookies.delete(:orderDetail)
  end

  def already_escaped(str)
    str =~ /%/
  end

  def number_to_phone(number, options = {})
    return unless number
    options = options.symbolize_keys

    parse_float(number, true) if options.delete(:raise)
    ERB::Util.html_escape(ActiveSupport::NumberHelper.number_to_phone(number, options))
  end
end
