Splickit::Application.configure do

  config.cache_classes = false
  config.action_controller.perform_caching = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_mailer.raise_delivery_errors = true
  config.active_support.deprecation = :log
  config.assets.debug = false
  config.skin_api_domain = 'admin-test.splickit.com'
  # config.api_domain = '<smaw_name_or_ip[:port]>'
  # config.api_domain = ENV["API_DOMAIN"]
  config.memcached_address = 'localhost:11211'
  config.redis_address = 'redis://redis:6379'
  config.cache_store = :redis_store, Rails.application.config.redis_address
  config.cache_expires_in = 15.minutes
  config.hostname = 'http://localhost:3000'
end
