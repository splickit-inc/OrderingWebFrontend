require "integrations_helper"

USER_ID = "5497-47th7-4kcub-p9oph"
USER_EMAIL = "get@test.com"
USER_PASSWORD = "password"

# TODO: dry this up; move request string to yaml and iterate over hash
describe "GET Requests" do
  let(:expected_responses) do
    YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__), "get_expectations.yml")))
  end

  before(:each) do
    WebMock.allow_net_connect!
  end

  describe "GET '/usersession'" do
    let(:valid) { mash(expected_responses["usersession"]) }

    it "contains a valid response" do
      skip("too many false negatives")

      response = JSON.parse(API.get("/usersession", {
        email: USER_EMAIL,
        password: USER_PASSWORD
      }).body)

      mash(response).each_pair do |k, v|
        if valid.has_key?(k)                  
          expect(v).to eq(valid[k]), "expected fetched response #{v} to equal expected response #{valid[k]} for key #{k}"
        end
      end
    end
  end

  describe "GET '/users/:id'" do
    let(:valid) { mash(expected_responses["users"]) }

    it "contains a valid response" do
      skip("too many false negatives")

      response = JSON.parse(API.get("/users/#{USER_ID}", {
        email: USER_EMAIL,
        password: USER_PASSWORD
      }).body)

      mash(response).each_pair do |k, v|
        if valid.has_key?(k)
          expect(v).to eq(valid[k]), "expected fetched response #{v} to equal expected response #{valid[k]} for key #{k}"
        end
      end
    end
  end

  describe "GET '/users/:id/loyalty_history'" do
    let(:valid) { mash(expected_responses["loyalty_history"]) }

    it "contains a valid response" do
      skip("too many false negatives")

      response = JSON.parse(API.get("/users/#{USER_ID}/loyalty_history", {
        email: USER_EMAIL,
        password: USER_PASSWORD
      }).body)

      mash(response).each_pair do |k, v|
        if valid.has_key?(k)
          expect(v).to eq(valid[k]), "expected fetched response #{v} to equal expected response #{valid[k]} for key #{k}"
        end
      end
    end
  end

  describe "GET '/isindeliveryarea'" do
    let(:valid) { mash(expected_responses["isindeliveryarea"]) }

    it "contains a valid response" do
      skip("too many false negatives")

      response = JSON.parse(API.get("/merchants/102289/isindeliveryarea/203378").body)

      mash(response).each_pair do |k, v|
        if valid.has_key?(k)
          expect(v).to eq(valid[k]), "expected fetched response #{v} to equal expected response #{valid[k]} for key #{k}"
        end
      end
    end
  end

  describe "GET '/skin/com.splickit.pitapit'" do
    let(:valid) { mash(expected_responses["skin"]) }

    it "contains a valid response" do
      skip("too many false negatives")

      response = JSON.parse(API.get("/skins/com.splickit.pitapit", {use_admin: true}).body)

      mash(response).each_pair do |k, v|
        if valid.has_key?(k)
          expect(v).to eq(valid[k]), "expected fetched response #{v} to equal expected response #{valid[k]} for key #{k}"
        end
      end
    end
  end
end
