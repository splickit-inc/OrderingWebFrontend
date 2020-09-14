# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require './spec/fixtures/object_creation_methods.rb'
require './spec/session_helpers.rb'
require 'capybara/rspec'
require 'capybara/rails'
require 'webmock/rspec'
require 'simplecov'
require 'cgi'
require 'rails-controller-testing'
require "exceptions"
# require 'capybara_remote'

SimpleCov.start do
  add_group "Controllers", "app/controllers"
  add_group "Helpers",     "app/helpers"
  add_group "Mailers",     "app/mailers"
  add_group "Models",      "app/models"
end
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include SessionHelpers
  config.include ObjectCreationMethods

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  [:controller, :view, :request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, type: type
    config.include ::Rails::Controller::Testing::TemplateAssertions, type: type
    config.include ::Rails::Controller::Testing::Integration, type: type
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:each) do
    Rails.cache.clear
    WebMock.disable_net_connect!(allow_localhost: true, allow: "com.splickit.products.s3.amazonaws.com")

    test_menu_status = { "http_code" => "200",
                         "stamp" => "tweb03-i-027c8323-0BB5K7E",
                         "data" => { "menu_key" => "1421429319",
                                     "menu_id" => "102326" } }

    stub_request(:any, /.*apiv2\/menu\/.+\/menustatus/).to_return(status: 200, body: test_menu_status.to_json)

    skin_where_stub

    stub_request(:get, /.*geoip3.maxmind.com*/).to_return(status: 200, body: "US,CO,Boulder,40.049599,-105.276901")

    stub_request(:get, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/merchants?limit=10&minimum_merchant_count=5&range=100&lat=40.049599&lng=-105.276901").
      to_return(status: 200, body: '{"data":{"merchants":[{"merchant_id":"100030","merchant_external_id":null,"brand_id":"192","lat":"49.917047","lng":"-115.053184","name":"Law Abiding Pete\'s","display_name":"Interlocken","address1":"4408 Interlocken Parkway","description":"Burritos for the churchgoing, responsible crowd.","city":"Aurora","state":"CO","zip":"90020","phone_no":"7209740521","delivery":"N","distance":"1.1763717584181679","brand":"Law Abiding Pete\'s","promo_count":"NA"}]}}', :headers => {})

    stub_request(:get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/merchants?limit=10&minimum_merchant_count=5&range=100&lat=40.049599&lng=-105.276901").
      to_return(status: 200, body: '{"data":{"merchants":[{"merchant_id":"100030","merchant_external_id":null,"brand_id":"192","lat":"49.917047","lng":"-115.053184","name":"Law Abiding Pete\'s","display_name":"Interlocken","address1":"4408 Interlocken Parkway","description":"Burritos for the churchgoing, responsible crowd.","city":"Aurora","state":"CO","zip":"90020","phone_no":"7209740521","delivery":"N","distance":"1.1763717584181679","brand":"Law Abiding Pete\'s","promo_count":"NA"}]}}', :headers => {})

    stub_request(:get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2").
      to_return(status: 200, body: { data: get_user_data}.to_json, headers: {})

    vio_credentials_stubs
  end

  config.after(:each) do
    Timecop.return
    destroy_user_session
    RequestStore.store[:see_inactive_merchants] = nil
    RequestStore.store[:user_email] = nil
    RequestStore.store[:user_password] = nil
    RequestStore.store[:auth_token] = nil
  end
end

def enable_ssl
  request.env['HTTPS'] = 'on'
end

def get_cookie(key)
  CGI.unescape(Capybara.current_session.driver.browser.manage.cookie_named(key)[:value])
end

def cookie_to_hash(str)
  JSON.parse(str.gsub("=>", ":"))
end

def cart_session_items
  Rails.cache.fetch(:items)
end

def sign_in(user)
  session[:current_user] = { "user_id" => user["user_id"],
                             "first_name" => user["first_name"],
                             "last_name" => user["last_name"],
                             "email" => user["email"],
                             "contact_no" => user["contact_no"],
                             "last_four" => user["last_four"],
                             "delivery_locations" => user["delivery_locations"],
                             "brand_loyalty" => user["brand_loyalty"],
                             "flags" => user["flags"],
                             "balance" => user["balance"],
                             "group_order_token" => user["group_order_token"],
                             "marketing_email_opt_in" => user["marketing_email_opt_in"],
                             "zipcode" => user["zipcode"],
                             "birthday" => user["birthday"],
                             "privileges" => user["privileges"],
                             "splickit_authentication_token" => user["splickit_authentication_token"] }

  session[:remember_me] = {"remember_me" => user["remember_me"] != "0"}

  user_find_stub(auth_token: user["splickit_authentication_token"], return: user)
end

def user_find_stub(options = {})
  default_return = get_user_data.with_indifferent_access
  auth_token = get_auth_token(options[:auth_token] || "ASNDKASNDAS")
  var_return = default_return.merge(options[:return] || {})

  stub_request(:get, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/users/#{ var_return["user_id"] }")
    .to_return(status: 200, body: { data: var_return }.to_json)
end

def user_authenticate_stub(options = {})
  auth_token = get_auth_token(options[:auth_token] || { email: "bob@roberts.com", password: "password" })

  if options[:punch_header].present?
    auth_token = nil
    headers = { "Punch-Authentication-Token" => options[:punch_header] }
  end

  stub = stub_request(:get, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/usersession")
  stub.with(headers: headers) if headers.present?

  return stub.to_return(status: 200, body: { error: options[:error] }.to_json) if options[:error]

  default_return = get_user_data.with_indifferent_access
  var_return = default_return.merge(options[:return] || {})

  stub.to_return(status: 200, body: { data: var_return }.to_json)
end

def sign_out
  session.delete(:current_user)
end

def change_to_json_request
  @request.env["HTTP_ACCEPT"] = "application/json"
  @request.env["CONTENT_TYPE"] = "application/json"
end