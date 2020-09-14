# SELENIUM_SERVER is the IP address or hostname of the system running Selenium
# Server, this is used to determine where to connect to when using one of the
# selenium_remote_* drivers
SELENIUM_SERVER = "selenium-firefox"
# SELENIUM_APP_HOST is the IP address or hostname of this system (where the
# tests run against) as reachable for the SELENIUM_SERVER. This is used to set
# the Capybara.app_host when using one of the selenium_remote_* drivers
SELENIUM_APP_HOST = "web2_r5_tests_selenium"
# CAPYBARA_DRIVER is the Capybara driver to use, this defaults to Selenium with
# Firefox
CAPYBARA_DRIVER = "selenium_remote_firefox"
# At this point, Capybara.default_driver is :rack_test, and
# Capybara.javascript_driver is :selenium. We can't run :selenium in the Vagrant box,
# so we set the javascript driver to :selenium_remote_firefox which we're going to
# configure.
Capybara.javascript_driver = :selenium_remote_firefox
RSpec.configure do |config|
  config.before(:each) do
    WebMock.disable_net_connect!(:allow_localhost => true)
    Capybara.server_port = "6001"
    if selenium_remote?
      Capybara.app_host = "http://#{SELENIUM_APP_HOST}:6001"
    end
  end
  config.after(:each) do
    Capybara.reset_sessions!
    Capybara.use_default_driver
    Capybara.app_host = nil
  end
  # Determines if a selenium_remote_* driver is being used
  def selenium_remote?
    !(Capybara.current_driver.to_s =~ /\Aselenium_remote/).nil?
  end
end
# CapybaraDriverRegistrar is a helper class that enables you to easily register
# Capybara drivers
class CapybaraDriverRegistrar
  # register a Selenium driver for the given browser to run on the localhost
  def self.register_selenium_local_driver(browser)
    Capybara.register_driver "selenium_#{browser}".to_sym do |app|
      Capybara::Selenium::Driver.new(app, browser: browser)
    end
  end
  # register a Selenium driver for the given browser to run with a Selenium
  # Server on another host
  def self.register_selenium_remote_driver(browser)
    Capybara.register_driver "selenium_remote_#{browser}".to_sym do |app|
      Capybara::Selenium::Driver.new(app)
      # Capybara::Selenium::Driver.new(app, url: "http://#{SELENIUM_SERVER}:7055/hub")
    end
  end
end
# Register various Selenium drivers
CapybaraDriverRegistrar.register_selenium_remote_driver(:firefox)
