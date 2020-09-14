Splickit::Application.configure do

  config.cache_classes = true
  config.eager_load = false
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=3600" }
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :stderr
  config.api_domain = 'test.splickit.com'
  config.skin_api_domain = 'admin-test.splickit.com'
  config.memcached_address = 'localhost:11211'
  config.redis_address = 'redis://redis-container:6379'
  config.cache_store = :redis_store, Rails.application.config.redis_address
  config.hostname = 'http://order.splickit-dev.com'
  config.value_io_url = '/assets/test/fake_value.js'
  config.active_support.test_order = :sorted
end
