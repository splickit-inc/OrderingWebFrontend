require "integrations_helper"

describe "GET Requests" do
  let(:expected_responses) do
    YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__), "post_expectations.yml")))
  end

  describe "POST '/orders'" do
    # JSON.parse(API.post("/orders", params.to_json, options).env.body)
  end

  describe "POST '/cart/checkout'" do
    # JSON.parse(API.post("/cart/checkout",  checkout_data.to_json, user_credentials).body)
  end

  describe "POST '/users'" do
    # JSON.parse(API.post('/users', attributes.to_json).body)
  end

  describe "POST '/setuserdelivery'" do
    # JSON.parse(API.post("/setuserdelivery",
    #   {
    #     :address1 => address_data[:address1],
    #     :address2 => address_data[:address2],
    #     :city => address_data[:city],
    #     :state => address_data[:state],
    #     :zip => address_data[:zip],
    #     :phone_no => address_data[:phone_no],
    #     :instructions => address_data[:instructions]
    #   }.to_json,
    #   {
    #     :base_path => "/app2/phone", # this is API V1
    #     :email => user_data[:email],
    #     :password => user_data[:password]
    #   }
    # ).body)
  end

  describe "POST '/users/:id'" do
    # JSON.parse(API.post("/users/#{id}", attributes.to_json, {
    #   email: current_email,
    #   password: current_pass
    # }).body)
  end
end
