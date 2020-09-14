require 'request_store'

class API

  def self.get path, options = {}
    begin
      Rails.logger.debug "--- API.get #{ path }, #{ options }"
      options = Hashie::Mash.new options

      protocol = options[:protocol] || API.protocol
      domain = options[:domain] || API.domain
      base_path = options[:base_path] || API.base_path
      url = "#{ protocol }://#{ domain }"
      client = Skin.current_name || 'order'
      
      response = get_connection(url).get base_path + path do |request|
        request.headers['X_SPLICKIT_CLIENT_VERSION'] = '3'
        request.headers['X_SPLICKIT_CLIENT'] = client
        request.headers['X_SPLICKIT_CLIENT_DEVICE'] = RequestStore.store[:client_device] || 'web'
        request.headers['X_SPLICKIT_CLIENT_ID'] = "com.splickit.#{client}"
        request.headers['X_SPLICKIT_USER_AGENT'] = RequestStore.store[:user_agent] if RequestStore.store[:user_agent].present?
        request.headers['Content-Type'] = "application/json"

        request.headers["punch_authentication_token"] = options[:punch_authentication_token] if options[:punch_authentication_token].present?

        Rails.logger.info "-- API.get headers (minus auth) are #{ request.headers.inspect }"

        auth_token = auth_token(
            options[:user_auth_token],
            options[:email],
            options[:password],
            options[:use_admin]
        )
        request.headers['Authorization'] = "Basic #{ auth_token }" if auth_token.present?
      end

      Rails.logger.info "--- API.get URL: #{ url + base_path + path.gsub(/password=(.)*$/, 'password=[FILTERED]') }"
      Rails.logger.info "--- API.get response: #{ response.body }"
      response
    rescue Exception => e
      Rails.logger.error e.inspect
      Rails.logger.error e.backtrace
      raise e
    end
  end

  def self.post path, data, options = {}
    begin
      Rails.logger.info "--- API.post #{ path }, #{ data.gsub(/password":"([^"])+"/, '"password":"[FILTERED]"').gsub(/password_confirmation":"([^"])+"/, '"password_confirmation":"[FILTERED]"') }, #{ options }"
      options = Hashie::Mash.new options

      protocol = options[:protocol] || API.protocol
      domain = options[:domain] || API.domain
      base_path = options[:base_path] || API.base_path
      url = "#{ protocol }://#{ domain }"
      client = Skin.current_name || 'order'

      response = get_connection(url).post base_path + path, data do |request|
        request.headers['Authorization'] = "Basic #{auth_token(options[:user_auth_token], options[:email], options[:password], options[:use_admin])}"
        request.headers['Content-Type'] = 'application/json'
        request.headers['X_SPLICKIT_CLIENT_VERSION'] = '3'
        request.headers['X_SPLICKIT_CLIENT'] = client
        request.headers['X_SPLICKIT_CLIENT_DEVICE'] = RequestStore.store[:client_device] || 'web'
        request.headers['X_SPLICKIT_CLIENT_ID'] = "com.splickit.#{client}"
        request.headers['X_SPLICKIT_USER_AGENT'] = RequestStore.store[:user_agent] if RequestStore.store[:user_agent]
        request.headers['Content-Type'] = "application/json"
      end

      Rails.logger.info "--- API.post URL: #{ url + base_path + path.gsub(/password:(.)*$/, 'password=[FILTERED]') }"
      Rails.logger.info "--- API.post response: #{ response.body.gsub(/password":"([^"])+"/, '"password":"[FILTERED]"').gsub(/password_confirmation":"([^"])+"/, '"password_confirmation":"[FILTERED]"') }"
      response
    rescue Exception => e
      Rails.logger.error e.inspect
      Rails.logger.error e.backtrace
      raise e
    end
  end

  def self.delete path, options = {}
    begin
      Rails.logger.debug "--- API.delete #{ path }, #{ options }"
      options = Hashie::Mash.new options

      protocol = options[:protocol] || API.protocol
      domain = options[:domain] || API.domain
      base_path = options[:base_path] || API.base_path
      url = "#{ protocol }://#{ domain }"
      client = Skin.current_name || 'order'

      response = get_connection(url).delete base_path + path do |request|
        request.headers['Authorization'] = "Basic #{auth_token(options[:user_auth_token], options[:email], options[:password], options[:use_admin])}"
        request.headers['Content-Type'] = 'application/json'
        request.headers['X_SPLICKIT_CLIENT_VERSION'] = '3'
        request.headers['X_SPLICKIT_CLIENT'] = client
        request.headers['X_SPLICKIT_CLIENT_DEVICE'] = RequestStore.store[:client_device] || 'web'
        request.headers['X_SPLICKIT_CLIENT_ID'] = "com.splickit.#{client}"
        request.headers['X_SPLICKIT_USER_AGENT'] = RequestStore.store[:user_agent] if RequestStore.store[:user_agent]
        request.headers['Content-Type'] = "application/json"
      end

      Rails.logger.debug "--- API.delete URL: #{ url + base_path + path.gsub(/password=(.)*$/, 'password=[FILTERED]') }"
      Rails.logger.debug "--- API.delete response: #{ response.body }"
      response
    rescue Exception => e
      Rails.logger.error e.inspect
      Rails.logger.error e.backtrace
      raise e
    end
  end

  def self.protocol
    Rails.application.config.api_protocol
  end

  def self.domain
    Rails.application.config.api_domain
  end

  def self.base_path
    Rails.application.config.api_base_path
  end

  def self.skin_domain
    Rails.application.config.skin_api_domain
  end

  def self.skin_base_path
    Rails.application.config.skin_base_path
  end

  private

  def self.get_connection url
    Faraday.new url
  end

  def self.auth_token(auth_token, email, password, use_admin)
    if auth_token
      Base64.strict_encode64("splickit_authentication_token:#{ auth_token }").strip.gsub(/\n/, '')
    elsif email && password
      Base64.strict_encode64("#{ email }:#{ password }").strip
    elsif use_admin
      Rails.logger.info("Defaulting to admin authentication.")
      Base64.strict_encode64('admin:xxxxxx').strip
    end
  end

end
