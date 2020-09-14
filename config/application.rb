require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

Bundler.require(:default, Rails.env)

module Splickit
  class Application < Rails::Application

    config.encoding = 'utf-8'
    config.action_controller.perform_caching = true
    config.api_protocol = 'http'
    config.api_domain = ENV["API_DOMAIN"]
    config.api_base_path = '/app2/apiv2'
    config.skin_api_domain = 'localhost:8084'
    config.skin_base_path = '/api'
    config.exceptions_app = self.routes
    config.action_mailer.smtp_settings = {
      address: "smtp.mandrillapp.com",
      port: 587,
      enable_starttls_auto: true,
      user_name: "",
      password: "",
      authentication: 'login'
    }
    config.google_analytics_tracking_id = ''
    config.cache_expires_in = 60.minutes
    config.action_dispatch.default_headers['X-Frame-Options'] = "ALLOW-FROM https://force.com"
    config.action_dispatch.default_headers['Content-Security-Policy'] = "frame-ancestorsforce.com"

    config.assets.precompile += %w( application-all.css application-ie.css )
    config.assets.precompile += %w( html5shiv.js )
    config.value_io_url = 'https://api-staging.value.io/assets/value.js'
    config.value_io_api_domain = 'https://api-staging.value.io'
    config.value_io_api_path = '/v1'

    config.s3_style_base_location = 'staging'

    ActiveSupport.halt_callback_chains_on_return_false = false
    config.action_controller.per_form_csrf_tokens = false
    config.action_controller.forgery_protection_origin_check = true

    config.mapbox_token = ""
  end
end
