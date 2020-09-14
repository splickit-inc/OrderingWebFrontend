require "rails_helper"

describe User do
  let(:good_response) {double()}
  let(:bad_response) {double()}

  describe ".initialize" do
    subject { User.initialize }

    it { is_expected.to respond_to(:user_id) }
    it { is_expected.to respond_to(:first_name) }
    it { is_expected.to respond_to(:last_name) }
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:contact_no) }
    it { is_expected.to respond_to(:last_four) }
    it { is_expected.to respond_to(:delivery_locations) }
    it { is_expected.to respond_to(:brand_loyalty) }
    it { is_expected.to respond_to(:flags) }
    it { is_expected.to respond_to(:balance) }
    it { is_expected.to respond_to(:group_order_token) }
    it { is_expected.to respond_to(:marketing_email_opt_in) }
    it { is_expected.to respond_to(:zipcode) }
    it { is_expected.to respond_to(:birthday) }
    it { expect respond_to(:orders) }
  end

  describe ".create" do
    before do
      allow(good_response).to receive(:body) {get_authenticated_user_json}
      allow(good_response).to receive(:status) {200}
      allow(bad_response).to receive(:body) {"{\"error\": {\"error\":\"You are not authorized to create a user.\"}}"}
      allow(bad_response).to receive(:status) {500}
    end

    it 'should call to the api to create a new user' do
      expect(API).to receive("post").with('/users', {:email => "bob@roberts.com", :contact_no => "3033334444", :password => "password"}.to_json, {:use_admin => true}).and_return(good_response)
      User.create({:email => "bob@roberts.com", :contact_no => "3033334444", :password => "password"})
    end

    it 'should raise APIError if no contact_no' do
      expect{ User.create(email: "bob@roberts.com", password: "password") }.to raise_error(APIError, "Phone number can't be blank.")
    end

    context "success from api" do
      before(:each) do
        allow(API).to receive("post").and_return(good_response)
        @user = User.create({:email => "bob@roberts.com", :contact_no => "3033334444", :password => "password"})
      end

      subject { @user }

      it { is_expected.to respond_to(:user_id) }
      it { is_expected.to respond_to(:first_name) }
      it { is_expected.to respond_to(:last_name) }
      it { is_expected.to respond_to(:email) }
      it { is_expected.to respond_to(:contact_no) }
      it { is_expected.to respond_to(:last_four) }
      it { is_expected.to respond_to(:delivery_locations) }
      it { is_expected.to respond_to(:brand_loyalty) }
      it { is_expected.to respond_to(:flags) }
      it { is_expected.to respond_to(:balance) }
      it { is_expected.to respond_to(:group_order_token) }
      it { is_expected.to respond_to(:privileges) }

      it { expect(@user.user_id).to eq("2") }
      it { expect(@user).not_to be_nil }

      it 'should indicate they have a cc if flags has 1C' do
        expect(@user.has_cc?).to be_truthy
      end

      it 'should indicate if they do not have a cc if flags does not have 1C' do
        @user.flags = "2C10001"
        expect(@user.has_cc?).to be_falsey
      end
    end

    context "failure from api" do
      it 'should raise an API error' do
        allow(API).to receive("post").and_return(bad_response)
        expect { User.create(email: "bob@roberts.com", contact_no: "3033334444",
                             password: "password") }.to raise_error(APIError)
      end
    end
  end

  describe ".authenticate" do
    let(:good_autheticate_response) {double()}

    let(:bad_response) {double()}

    before do
      allow(good_response).to receive(:body) {get_authenticated_user_json}
      allow(good_response).to receive(:status) {200}
      allow(bad_response).to receive(:body) {"{\"error\": {\"error\":\"Your username does not exist in our system, please check your entry.\"}}"}
      allow(bad_response).to receive(:status) {200}
    end

    it 'should call the api to verify the email/password combo is valid' do
      expect(API).to receive("get")
        .with("/usersession", { email: "bob@roberts.com", password: "password" })
        .and_return(good_response)
      User.authenticate({ email: "bob@roberts.com", password: "password" })
    end

    context "success" do
      it 'should return the authenticated user object' do
        allow(API).to receive("get").and_return(good_response)
        user = User.authenticate({:email => "bob@roberts.com", :password => "password"})
        expect(user).not_to be_nil
        expect(user.user_id).to eq("2")
      end
    end

    context "failure" do
      it 'should raise an api error if user fails to authenticate' do
        allow(API).to receive("get").and_return(bad_response)
        expect { User.authenticate(email: "bob@roberts.com",
                                   password: "password") }.to raise_error(APIError)
      end
    end

    context "missing authentication token" do
      before do
        allow(API).to receive_message_chain(:get, :status) { 200 }
        allow(API).to receive_message_chain(:get, :body) { {
            "http_code" => 200,
            "stamp" => "tweb03-i-027c8323-9U1PAX0",
            "data" => {
                "user_id" => "8367-qaj3b-fi5sm-hk3rk",
                "uuid" => "8367-qaj3b-fi5sm-hk3rk",
                "last_four" => "0000",
                "first_name" => "Tank",
                "last_name" => "Tomblog",
                "email" => "bom@tom.com",
                "contact_no" => "424-413-5456",
                "device_id" => nil,
                "balance" => "0.00",
                "flags" => "1000000001",
                "referrer" => nil,
                "orders" => "15",
                "points_lifetime" => "1185",
                "points_current" => "1185",
                "rewardr_participation" => "Y",
                "custom_message" => nil,
                "delivery_locations" => [],
                "user_groups" => [],
                "rewardr_active" => "N",
                "charity_active" => "Y",
                "skin_charity_info" => {
                    "charity_active" => "Y",
                    "charity_nav_text" => "Donations",
                    "charity_alert_title" => "JDRF",
                    "charity_alert_body" => "Want to make a difference? You can donate a small amount with each order to JDRF by rounding up your orders to the nearest dollar.\nTap below to be redirected to a Safari page where you can manage your donation preferences.",
                    "charity_alert_cancel" => "Cancel",
                    "charity_alert_okay" => "Okay",
                    "charity_web_host_base" => "order"
                },
                "splickit_authentication_token" => "",
                "splickit_authentication_token_expires_at" => "",
                "privileges" => {
                    "caching_action" => "respect",
                    "ordering_action" => "send",
                    "send_emails" => true,
                    "see_inactive_merchants" => false,
                    "see_demo_merchants" => false
                }
            },
            "message" => nil
        }.to_json }
      end

      it "raises an exception if there is no auth token returned" do
        expect { User.authenticate({}) }.to raise_error(APIError)
      end
    end
  end

  describe ".update" do
    before do
      allow(good_response).to receive(:body) {get_authenticated_user_json}
      allow(good_response).to receive(:status) {200}
      allow(bad_response).to receive(:body) {"{\"error\": {\"error\":\"Your username does not exist in our system, please check your entry.\"}}"}
      allow(bad_response).to receive(:status) {500}
    end

    it 'should return the user object including the updates if the update was successful' do
      expect(API).to receive("post").with("/users/2", {:first_name => "bob", :last_name => "roberts", :email => "bob@roberts.com"}.to_json, {:user_auth_token => "ASNDKASNDAS"}).and_return(good_response)
      user = User.update({ first_name: "bob", last_name: "roberts", email: "bob@roberts.com" }, "2", "ASNDKASNDAS")
      expect(user.user_id).to eq("2")
      expect(user.first_name).to eq("bob")
      expect(user.last_name).to eq("roberts")
      expect(user.email).to eq("bob@roberts.com")
    end

    it 'should raise api error if it was unsuccessful' do
      allow(API).to receive("post").and_return(bad_response)
      expect { User.update({ first_name: "bob", last_name: "roberts", email: "bob@roberts.com" }, "2", "ASNDKASNDAS") }.to raise_error(APIError)
    end

    it 'should not submit an empty password' do
      expect(API).to receive("post").with("/users/2", {:first_name => "bob", :last_name => "roberts", :email => "bob@roberts.com"}.to_json, {:user_auth_token => "ASNDKASNDAS"}).and_return(good_response)
      User.update({:first_name => "bob", :last_name => "roberts", :email => "bob@roberts.com", :password => ""}, "2", "ASNDKASNDAS")
    end

    it 'should not submit an empty password_confirmation' do
      expect(API).to receive("post").with("/users/2", {:first_name => "bob", :last_name => "roberts", :email => "bob@roberts.com"}.to_json, {:user_auth_token => "ASNDKASNDAS"}).and_return(good_response)
      User.update({:first_name => "bob", :last_name => "roberts", :email => "bob@roberts.com", :password_confirmation => ""}, "2", "ASNDKASNDAS")
    end
  end

  describe ".store_address" do
    before do
      allow(good_response).to receive(:body) {{"user_addr_id"=>"4",
                                  "user_id"=>"2",
                                  "business_name" => "",
                                  "address1"=>"430 Camino Bandera",
                                  "address2"=>"Suite 10",
                                  "city"=>"San Clemente",
                                  "state"=>"CA",
                                  "zip"=>"92673",
                                  "lat"=>"39.8149386187446",
                                  "lng"=>"-104.956209155655",
                                  "phone_no"=>"7738935",
                                  "instructions"=>"wear a funny hat",
                                  "mimetype"=>"application\/tonic-resource"}.to_json}
      allow(good_response).to receive(:status) {200}
      allow(bad_response).to receive(:body) {"{\"ERROR\":\"address cannot be null\",\"ERROR_CODE\":\"11\",\"TEXT_TITLE\":null,\"TEXT_FOR_BUTTON\":null,\"FATAL\":null,\"URL\":null,\"stamp\":\"tweb03-i-027c8323-YK4ZH1D\"}"}
      allow(bad_response).to receive(:status) {500}
    end

    context "business name with data" do
      before(:each) do
        allow(good_response).to receive(:body) {{"user_addr_id"=>"4",
                                    "user_id"=>"2",
                                    "business_name" => "Test San Clemente Company",
                                    "address1"=>"480 Redmond",
                                    "address2"=>"Suite 11",
                                    "city"=>"Redmond",
                                    "state"=>"WA",
                                    "zip"=>"80302",
                                    "lat"=>"40.8149386187446",
                                    "lng"=>"-102.956209155655",
                                    "phone_no"=>"1234567890",
                                    "instructions"=>"wear a funny hat",
                                    "mimetype"=>"application\/tonic-resource"}.to_json}
        allow(good_response).to receive(:status) {200}
        allow(bad_response).to receive(:body) {"{\"ERROR\":\"address cannot be null\",\"ERROR_CODE\":\"11\",\"TEXT_TITLE\":null,\"TEXT_FOR_BUTTON\":null,\"FATAL\":null,\"URL\":null,\"stamp\":\"tweb03-i-027c8323-YK4ZH1D\"}"}
        allow(bad_response).to receive(:status) {500}
      end

      it "business name parsed, saved and recovered if successful" do
        expect(API).to receive("post")
            .with("/setuserdelivery", "{\"business_name\":\"Test San Clemente Company\",\"address1\":\"480 Redmond\",\"address2\":\"Suite 11\",\"city\":\"Redmond\",\"state\":\"WA\",\"zip\":\"80302\",\"phone_no\":\"1234567890\",\"instructions\":\"wear a funny hat\"}", {:base_path=>"/app2/phone", :user_auth_token => "ASNDKASNDAS"})
            .and_return(good_response)
        expect(User.store_address({ business_name: "Test San Clemente Company",
                                    address1: "480 Redmond",
                                    address2: "Suite 11",
                                    city: "Redmond",
                                    state: "WA",
                                    zip: "80302",
                                    phone_no: "1234567890",
                                    instructions: "wear a funny hat" },
                                  { user_auth_token: "ASNDKASNDAS"}))
          .to eq({ "user_addr_id" => "4",
                   "user_id" => "2",
                   "business_name" => "Test San Clemente Company",
                   "address1" => "480 Redmond",
                   "address2" => "Suite 11",
                   "city" => "Redmond",
                   "state" => "WA",
                   "zip" => "80302",
                   "lat" => "40.8149386187446",
                   "lng" => "-102.956209155655",
                   "phone_no" => "1234567890",
                   "instructions" => "wear a funny hat",
                   "mimetype" => "application\/tonic-resource" })
      end
    end

    it "should return parsed, saved user address if successful" do
      expect(API).to receive("post")
      .with("/setuserdelivery", "{\"business_name\":\"\",\"address1\":\"430 Camino Bandera\",\"address2\":\"Suite 10\",\"city\":\"San Clemente\",\"state\":\"CA\",\"zip\":\"92673\",\"phone_no\":\"7738935\",\"instructions\":\"wear a funny hat\"}", {:base_path=>"/app2/phone", :user_auth_token => "ASNDKASNDAS"})
      .and_return(good_response)
      expect(User.store_address({ business_name: "",
                                  address1:"430 Camino Bandera",
                                  address2: "Suite 10",
                                  city: "San Clemente",
                                  state: "CA",
                                  zip: "92673",
                                  phone_no: "7738935",
                                  instructions: "wear a funny hat" },
                                { user_auth_token: "ASNDKASNDAS"}))
        .to eq({ "business_name" => "",
                 "user_addr_id" => "4",
                 "user_id" => "2",
                 "address1" => "430 Camino Bandera",
                 "address2" => "Suite 10",
                 "city" => "San Clemente",
                 "state" => "CA",
                 "zip" => "92673",
                 "lat" => "39.8149386187446",
                 "lng" => "-104.956209155655",
                 "phone_no" => "7738935",
                 "instructions" => "wear a funny hat",
                 "mimetype" => "application\/tonic-resource" })
    end

    it "should raise api error if it was not successful" do
      expect(API).to receive("post")
      .with("/setuserdelivery", "{\"business_name\":\"\",\"address1\":\"430 Camino Bandera\",\"address2\":\"Suite 10\",\"city\":\"San Clemente\",\"state\":\"CA\",\"zip\":\"92673\",\"phone_no\":\"7738935\",\"instructions\":\"wear a funny hat\"}", {:base_path=>"/app2/phone", :user_auth_token => "ASNDKASNDAS"})
      .and_return(bad_response)

      expect{ User.store_address({ business_name: "",
                                   address1: "430 Camino Bandera",
                                   address2: "Suite 10",
                                   city: "San Clemente",
                                   state: "CA",
                                   zip: "92673",
                                   phone_no: "7738935",
                                   instructions: "wear a funny hat" },
                                 { user_auth_token: "ASNDKASNDAS" }) }.to raise_error(APIError)
    end
  end

  describe ".delete_address" do
    before do
      allow(good_response).to receive(:body) {{"data" => {"result" => "success"}}.to_json}
      allow(good_response).to receive(:status) {200}
      allow(bad_response).to receive(:body) {"{\"error\": {\"error\": \"could not locate the user delivery record\",\"error_code\": 190 }}"}
      allow(bad_response).to receive(:status) {200}
    end

    it 'should return parsed, delete user address if successful' do
      expect(API).to receive("delete")
          .with("/users/8367-qaj3b-fi5sm-hk3rk/userdeliverylocation/4", {:user_auth_token => "ASNDKASNDAS"})
          .and_return(good_response)
      expect(User.delete_address("8367-qaj3b-fi5sm-hk3rk", 4, "ASNDKASNDAS")).to eq({"result" => "success"})
    end

    it 'should raise api error if it was not successful' do
      expect(API).to receive("delete")
          .with("/users/8367-qaj3b-fi5sm-hk3rk/userdeliverylocation/4", {:user_auth_token => "ASNDKASNDAS"})
          .and_return(bad_response)
      expect{ User.delete_address("8367-qaj3b-fi5sm-hk3rk", 4, "ASNDKASNDAS") }.to raise_error(APIError)
    end
  end

  describe ".find" do
    before() do
      allow(good_response).to receive(:body) {get_authenticated_user_json}
      allow(good_response).to receive(:status) {200}
      allow(bad_response).to receive(:body) {"{\"error\": {\"error\":\"Your username does not exist in our system, please check your entry.\"}}"}
      allow(bad_response).to receive(:status) {500}
    end

    it 'should return the specified user' do
      expect(API).to receive("get").with("/users/2", {user_auth_token: "ASNDKASNDAS"}).and_return(good_response)
      user = User.find("2", "ASNDKASNDAS")
      expect(user.user_id).to eq("2")
      expect(user.first_name).to eq("bob")
      expect(user.last_name).to eq("roberts")
      expect(user.email).to eq("bob@roberts.com")
    end

    it 'should raise APIError if it api raises error' do
      allow(API).to receive("get").and_return(bad_response)
      expect { User.find("2", "ASNDKASNDAS")}.to raise_error(APIError)
    end

    describe ".orders" do
      let(:endpoint) { "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/id/orderhistory" }
      let(:user) { User.find("2", "ASNDKASNDAS") }
      context "valid response" do
        before(:each) do
          stub_request(:get,
                       "http://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2/orderhistory?page=1").
            to_return(status: 200, body: { data: get_user_orders_json }.to_json)
        end

        it "returns orders" do
          orders = user.orders("ASNDKASNDAS", 1)
          expect(orders[:orders].count).to eq(10)
          expect(orders[:count]).to eq(11.to_s)
        end
      end

      context "invalid_response" do
        before(:each) do
          stub_request(:get,
                       "http://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2/orderhistory?page=1").
            to_return(status: 200, body: { error: { error: "barf" } }.to_json)
        end

        it "raises an API Error" do
          expect { user.orders("ASNDKASNDAS", 1) }.to raise_error APIError
        end
      end
    end
  end

  describe ".transaction_history" do
    let(:endpoint) { "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/id/loyalty_history?format=v2" }
    context "valid response" do
      before(:each) do
        stub_request(:get, endpoint).to_return(
          :status => 200,
          :body => {data: [{greeting: "hello"}, {greeting: "bye"}]}.to_json)
      end

      it "returns the transaction history" do
        expect(User.transaction_history("id", "ASNDKASNDAS")).to eq([{"greeting" => "hello"}, {"greeting" => "bye"}])
      end
    end

    context "invalid response" do
      before(:each) do
        stub_request(:get, endpoint).to_return(
          :status => 200,
          :body => {error: {error: "barf"}}.to_json)
      end

      it "raises an API Error" do
        expect { User.transaction_history("id", "ASNDKASNDAS") }.to raise_error APIError
      end
    end
  end

  describe "#loyal?" do
    it 'should be true for a loyal user' do
      user = User.new(get_loyal_user_data)
      expect(user.loyal?).to be_truthy
    end

    it 'should be false for a non loyal user' do
      user = User.new(get_user_data)
      expect(user.loyal?).to be_falsey
    end
  end

  describe "#has_points?" do
    it 'should be true for a user with points' do
      user = User.new(get_loyal_user_data)
      expect(user.has_points?).to be_truthy
    end

    it 'should be false for a user without points' do
      user = User.new(get_user_data)
      expect(user.has_points?).to be_falsey
    end
  end

  describe "#is_guest?" do
    it "should be true for a guest with '2' flag" do
      user = User.new(get_user_data.merge("flags" => "1C21000020"))
      expect(user.is_guest?).to be_truthy
    end

    it "should be true for a guest without '2' flag" do
      user = User.new(get_user_data)
      expect(user.is_guest?).to be_falsey
    end
  end

  describe ".see_inactive_merchants?" do
    it 'should return true if see_inactive_merchants is 1' do
      user_data = get_user_data.merge("privileges"=>{"caching_action"=>"respect", "ordering_action"=>"send", "send_emails"=>true, "see_inactive_merchants"=>true})
      user = User.new(user_data)
      expect(user.see_inactive_merchants?).to eq(true)
    end

    it 'should be false if see_inactive_merchants is 0' do
      user = User.new(get_user_data)
      expect(user.see_inactive_merchants?).to eq(false)
    end

    it 'should be false if user has no privileges' do
      user_data = get_user_data.merge("privileges"=>nil)
      user = User.new(user_data)
      expect(user.see_inactive_merchants?).to eq(false)
    end
  end

  describe ".full_name" do
    context "first or last name exist" do
      it "returns the full name" do
        user = User.new(first_name: "Bill", last_name: "Brown")
        expect(user.full_name).to eq("Bill Brown")
      end

      it "returns the full name" do
        user = User.new(first_name: "Bill", last_name: "Brown", email: "bb@splickit.com")
        expect(user.full_name).to eq("Bill Brown")
      end
    end

    context "first or last name don't exist" do
      it "returns the email" do
        user = User.new(email: "bb@splickit.com")
        expect(user.full_name).to eq("bb@splickit.com")
      end
    end
  end
end
