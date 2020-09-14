require File.expand_path("../../config/environment", __FILE__)
require File.join(File.dirname(__FILE__), '..', 'lib', 'api.rb')
require "yaml"
require "webmock/rspec"

RSpec.configure do |config|
  def mash(hash, flt = {})
    hash.each { |k, v| v.is_a?(Hash) ? mash(v, flt) : flt[k] = v }
    flt
  end
end
