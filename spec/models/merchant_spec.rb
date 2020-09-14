require "rails_helper"

describe Merchant do
  describe "valid attributes" do
    subject {Merchant.new}

    it {is_expected.to respond_to(:merchant_id)}
    it {is_expected.to respond_to(:brand_id)}
    it {is_expected.to respond_to(:brand)}
    it {is_expected.to respond_to(:lat)}
    it {is_expected.to respond_to(:lng)}
    it {is_expected.to respond_to(:name)}
    it {is_expected.to respond_to(:display_name)}
    it {is_expected.to respond_to(:address1)}
    it {is_expected.to respond_to(:address2)}
    it {is_expected.to respond_to(:city)}
    it {is_expected.to respond_to(:state)}
    it {is_expected.to respond_to(:zip)}
    it {is_expected.to respond_to(:phone_no)}
    it {is_expected.to respond_to(:delivery)}
    it {is_expected.to respond_to(:distance)}
    it {is_expected.to respond_to(:description)}
    it {is_expected.to respond_to(:menu)}
    it {is_expected.to respond_to(:modifier_groups)}
    it {is_expected.to respond_to(:trans_fee_rate)}
    it {is_expected.to respond_to(:delivery_cost)}
    it {is_expected.to respond_to(:accepts_credit)}
    it {is_expected.to respond_to(:accepts_cash)}
    it {is_expected.to respond_to(:group_ordering_on)}
    it {is_expected.to respond_to(:has_catering)}
    it {is_expected.to respond_to(:force_catering)}
    it {is_expected.to respond_to(:show_tip)}
    it {is_expected.to respond_to(:menu_key)}
    it {is_expected.to respond_to(:user_message)}
    it {is_expected.to respond_to(:user_favorites)}
    it {is_expected.to respond_to(:user_last_orders)}
  end

  let(:menu_item1) {{"item_id" => "3456", "item_name" => "Toast", "price" => "1.00"}}
  let(:menu_item2) {{"item_id" => "7890", "item_name" => "Egg", "price" => "2.00"}}
  let(:menu_item3) {{"item_id" => "4789", "item_name" => "Meat", "price" => "10.00"}}
  let(:menu_item4) {{"item_id" => "7654", "item_name" => "Fish", "price" => "11.00"}}

  let(:menu_type1) {{"menu_type_id" => "0987", "menu_type_name" => "Breakfast", "start_time" => "00:00:00", "end_time" => "23:59:59", "menu_items" => [menu_item1, menu_item2]}}
  let(:menu_type2) {{"menu_type_id" => "0987", "menu_type_name" => "Lunch", "start_time" => "00:00:00", "end_time" => "23:59:59", "menu_items" => [menu_item3, menu_item4]}}
  let(:menu) {{"menu_id" => "4567", "menu_key" => "1421429319", "name" => "2014 Menu", "menu_types" => [menu_type1, menu_type2]}}

  let(:merchant_params) {{"active" => "Y", "merchant_id" => "1234", "menu_key" => "1421429319", "menu_id" => "4567", "brand_id" => "2345", "name" => "Test Restaurant", "menu" => menu, "delivery" => "Y", "address1" => "1234 1st st", "address2" => "Apt 23", "city" => "Whoville", "state" => "NJ", "zip" => "55555", "payment_types" => ["creditcard", "cash"]}}
  let(:cached_merchant) {{"merchant_id" => "9876", "menu_key" => "1421429319", "brand_id" => "2345", "name" => "Test Restaurant Cached", "menu" => menu, "delivery" => "Y", "address1" => "1234 1st st", "address2" => "Apt 23", "city" => "Whoville", "state" => "NJ", "zip" => "55555", "payment_types" => ["creditcard", "cash"]}}
  let(:merchant_no_deliver) {{"active" => "Y", "merchant_id" => "1234", "menu_key" => "1421429319", "brand_id" => "2345", "name" => "Test Restaurant No Deliver", "menu" => menu, "delivery" => "N", "payment_types" => []}}
  let(:merchant_inactive) {{"active" => "N", "merchant_id" => "1235", "menu_key" => "1421429319", "brand_id" => "2345", "name" => "Test Restaurant Boarded Up", "menu" => menu, "delivery" => "N", "payment_types" => []}}
  let(:merchant_array) {[merchant_params, merchant_no_deliver, merchant_inactive]}
  let(:merchant_array_2) {[merchant_params, merchant_no_deliver]}

  # Attributes #
  describe '.phone_no' do
    describe '7 character phone numbers' do
      it {expect(Merchant.new({"phone_no" => nil}).phone_no).to eq("")}
      it {expect(Merchant.new({"phone_no" => "4442211"}).phone_no).to eq("444-2211")}
      it {expect(Merchant.new({"phone_no" => "444-2211"}).phone_no).to eq("444-2211")}
      it {expect(Merchant.new({"phone_no" => "444 2211"}).phone_no).to eq("444-2211")}
      it {expect(Merchant.new({"phone_no" => "44422 11"}).phone_no).to eq("444-2211")}
    end

    describe '10 character phone numbers' do
      it {expect(Merchant.new({"phone_no" => "(000)4442211"}).phone_no).to eq("(000) 444-2211")}
      it {expect(Merchant.new({"phone_no" => "000444-2211"}).phone_no).to eq("(000) 444-2211")}
      it {expect(Merchant.new({"phone_no" => "000 444 2211"}).phone_no).to eq("(000) 444-2211")}
      it {expect(Merchant.new({"phone_no" => "(000) - 44422 11"}).phone_no).to eq("(000) 444-2211")}
    end

    describe '11 character phone numbers' do
      it {expect(Merchant.new({"phone_no" => "1-000-4442211"}).phone_no).to eq("1 (000) 444-2211")}
      it {expect(Merchant.new({"phone_no" => "1 (000)-444-2211"}).phone_no).to eq("1 (000) 444-2211")}
      it {expect(Merchant.new({"phone_no" => "1(000)  - 444 2211"}).phone_no).to eq("1 (000) 444-2211")}
      it {expect(Merchant.new({"phone_no" => "1 00 0 44422 11"}).phone_no).to eq("1 (000) 444-2211")}
    end

    describe 'all other character lengths' do
      it {expect(Merchant.new({"phone_no" => "44422"}).phone_no).to eq("44422")}
      it {expect(Merchant.new({"phone_no" => "44-2222-11-0343"}).phone_no).to eq("442222110343")}
    end
  end

  describe ".show_tip" do
    context "tip supported" do
      it "initializes correctly" do
        merchant = Merchant.new({"show_tip" => "Y"})
        expect(merchant.show_tip).to eq(true)
      end
    end

    context "tip not supported" do
      it "initializes correctly" do
        merchant = Merchant.new({"show_tip" => "N"})
        expect(merchant.show_tip).to eq(false)
      end
    end

    context "default (API doesn't specify)" do
      it "initializes correctly" do
        merchant = Merchant.new
        expect(merchant.show_tip).to eq(false)
      end
    end
  end

  describe ".accepts_cash?" do
    it 'should return true if the merchant lists cash as a payment method' do
      merchant = Merchant.new(merchant_params)
      expect(merchant.accepts_cash).to eq(true)
    end

    it 'should return false if the merchant does not list cash as a payment method' do
      merchant = Merchant.new(merchant_no_deliver)
      expect(merchant.accepts_cash).to eq(false)
    end
  end

  describe ".accepts_credit?" do
    it 'should return true if the merchant lists credit cards as a payment method' do
      merchant = Merchant.new(merchant_params)
      expect(merchant.accepts_credit).to eq(true)
    end

    it 'should return false if the merchant does not list credit cards as a payment method' do
      merchant = Merchant.new(merchant_no_deliver)
      expect(merchant.accepts_credit).to eq(false)
    end
  end

  describe ".menu" do
    it "should be a kind of Menu" do
      merchant = Merchant.new(merchant_params)
      expect(merchant.menu).to be_a_kind_of(Menu)
    end

    it "should contain the correct menu data" do
      merchant = Merchant.new(merchant_params)
      expect(merchant.menu.name).to eq(menu["name"])
    end
  end

  describe ".user_favorites" do
    let(:user_favorites) {
      [
          {
              "merchant_id" => "104903",
              "items" => [
                  {
                      "quantity" => 1,
                      "note" => "",
                      "item_id" => "282391",
                      "size_id" => "91427",
                      "sizeprice_id" => "900207",
                      "mods" => [
                          {
                              "mod_sizeprice_id" => "4332495",
                              "mod_quantity" => 1
                          },
                          {
                              "mod_sizeprice_id" => "4332496",
                              "mod_quantity" => 1
                          },
                          {
                              "mod_sizeprice_id" => "4332498",
                              "mod_quantity" => 1
                          }
                      ]
                  }
              ],
              "total_points_used" => 0,
              "note" => "",
              "lead_time" => "15",
              "tip" => "0.00",
              "user_id" => "1484951",
              "favorite_name" => "bananabread"
          }
      ]
    }

    it "returns an array of UserFavorite objects" do
      merchant = Merchant.new(merchant_params.merge({"user_favorites" => user_favorites}))
      expect(merchant.user_favorites).to be_a_kind_of(Array)
      expect(merchant.user_favorites.first).to be_a_kind_of(UserFavorite)
    end
  end

  describe ".user_last_orders" do
    let(:user_last_orders) {
      [
          {
              "user_id" => "1484951",
              "label" => "Last Order placed on 02-05-2016",
              "items" => [
                  {
                      "quantity" => 1,
                      "note" => "",
                      "item_id" => "282391",
                      "size_id" => "91427",
                      "sizeprice_id" => "900207",
                      "mods" => [
                          {
                              "mod_sizeprice_id" => "4332495",
                              "mod_quantity" => 1
                          },
                          {
                              "mod_sizeprice_id" => "4332496",
                              "mod_quantity" => 1
                          },
                          {
                              "mod_sizeprice_id" => "4332498",
                              "mod_quantity" => 1
                          }
                      ]
                  }
              ]
          }
      ]
    }

    it "returns an array of UserLastOrder objects" do
      merchant = Merchant.new(merchant_params.merge({"user_last_orders" => user_last_orders}))
      expect(merchant.user_last_orders).to be_a_kind_of(Array)
      expect(merchant.user_last_orders.first).to be_a_kind_of(UserLastOrder)
    end
  end

  # Class Methods #
  describe "Merchant fetch methods" do
    let(:get_response) {OpenStruct.new}
    let(:bad_response) {OpenStruct.new}

    before do
      get_response.body = {data: merchant_params}.to_json
      get_response.status = 200
      Skin.current_name = "bob"
    end

    describe "Merchant.find" do
      let!(:saved_data) do
        (JSON.parse(get_response.body)["data"]).except("menu", "message", "user_favorites", "user_last_orders", "user_message")
      end

      it "should return merchant returned from api" do
        expect(API).to receive("get").with("/merchants/1234", {}).and_return(get_response)
        merchant = Merchant.find(1234)
        expect(merchant.merchant_id).to eq("1234")
        expect(merchant.name).to eq("Test Restaurant")
      end

      it "should raise on error responses" do
        bad_response.body = {"error" => "Get to the choppa!"}.to_json
        bad_response.status = 500
        expect(API).to receive("get").with("/merchants/1234", {}).and_return(bad_response)
        expect {Merchant.find(1234)}.to raise_error(APIError)
      end

      context "pickup" do
        it "calls the '/merchants/:id' endpoint" do
          expect(API).to receive("get").with("/merchants/1000", {}).and_return(get_response)
          Merchant.find(1000)
        end

        it "calls the '/merchants/:id' endpoint" do
          expect(API).to receive("get").with("/merchants/1234", {}).and_return(get_response)
          Merchant.find(1234, false)
        end

        context "Merchant.fetch_with_api_call" do
          it "should save merchant data in cache" do
            expect(API).to receive("get").with("/merchants/5678", {}).and_return(get_response)
            Merchant.fetch_with_api_call(5678, false, {})
            expect(Rails.cache.fetch("/merchants/5678")).to eq(saved_data)
          end

          it "should return cache" do
            expect(API).to receive("get").with("/merchants/5678", {}).and_return(get_response)
            Merchant.fetch_with_api_call(5678, false, {})
            expect(API).to_not receive("get")
            Merchant.fetch_with_api_call(5678, false, {})
            expect(Rails.cache.fetch("/merchants/5678")).to eq(saved_data)
          end
        end
      end

      context "delivery" do
        it "calls the '/merchants/:id/delivery' endpoint" do
          expect(API).to receive("get").with("/merchants/5678/delivery", {}).and_return(get_response)
          Merchant.find(5678, true)
        end

        context "Merchant.fetch_with_api_call" do
          it "should save merchant data in cache" do
            expect(API).to receive("get").with("/merchants/5678/delivery", {}).and_return(get_response)
            Merchant.fetch_with_api_call(5678, true, {})
            expect(Rails.cache.fetch("/merchants/5678/delivery")).to eq(saved_data)
          end

          it "should return cache" do
            expect(API).to receive("get").with("/merchants/5678/delivery", {}).and_return(get_response)
            Merchant.fetch_with_api_call(5678, true, {})
            expect(API).to_not receive("get")
            Merchant.fetch_with_api_call(5678, true, {})
            expect(Rails.cache.fetch("/merchants/5678/delivery")).to eq(saved_data)
          end
        end
      end
      context "catering" do
        it "calls the '/merchants/:id/catering' endpoint" do
          expect(API).to receive("get").with("/merchants/5678/catering", {}).and_return(get_response)
          Merchant.find(5678, "catering")
        end
      end
    end

    describe "Merchant.info" do
      let!(:saved_data) do
        (JSON.parse(get_response.body)["data"]).except("menu", "message", "user_favorites", "user_last_orders", "user_message")
      end

      it "should save and return cache" do
        expect(API).to receive("get").with("/merchants/5678/delivery", {}).and_return(get_response)
        Merchant.info(5678, true)
        expect(API).to_not receive("get")
        Merchant.info(5678, true)
        expect(Rails.cache.fetch("/merchants/5678/delivery")).to eq(saved_data)
      end
    end

    describe "Merchant.fetch_and_cache" do
      let!(:saved_data) do
        (JSON.parse(get_response.body)["data"]).except("menu", "message", "user_favorites", "user_last_orders", "user_message")
      end

      it "should call API and save data without menu, message, favorites, last orders and user messages" do
        expect(API).to receive("get").with("/merchants/5678/delivery", {}).and_return(get_response)
        Merchant.fetch_and_cache(5678, true, {})
        cached_data = Rails.cache.fetch("/merchants/5678/delivery")
        expect(cached_data).to eq(saved_data)
      end
    end
  end

  describe "Merchant.where" do
    let(:response_data) {{"merchants" => merchant_array}}

    let(:api_response) {OpenStruct.new}

    before do
      api_response.body = {"data" => response_data, "error" => nil}.to_json
      api_response.status = 200

      allow(API).to receive("get").and_return(api_response)
      Skin.current_name = "bob"
    end

    it 'should return an array of merchants in order received from api' do
      expect(API).to receive("get").and_return(api_response)
      merchants = Merchant.where({zip: "80000"})
      expect(merchants.size).to eq(3)
      expect(merchants[0].merchant_id).to eq("1234")
    end

    it 'should call get api response if available' do
      expect(API).to receive("get").and_return(api_response)
      merchants = Merchant.where({zip: "80000"})
      expect(merchants.size).to eq(3)
    end
  end

  # Instance Methods #
  describe "#catering_data" do
    it "should call get api response if available" do
      expect(API).to receive("get")
                         .with("/merchants/1/cateringorderavailabletimes/delivery", {user_auth_token: "test"})
                         .and_return(nil)
      Merchant.new("merchant_id" => "1").catering_data("delivery", {user_auth_token: "test"})
    end

    it "should parse api response" do
      merchant_catering_data_stub(auth_token: "test", order_type: "delivery", merchant_id: "1")
      catering_data = Merchant.new("merchant_id" => "1").catering_data("delivery", {user_auth_token: "test"})
      expect(catering_data).to eq("available_catering_times" => {
          "max_days_out" => 4,
          "time_zone" => "America/Los_Angeles",
          "daily_time" => [[{"ts" => 1483992000, "time" => "1:00 pm"},
                            {"ts" => 1483995600, "time" =>
                                "2:00 pm"}],
                           [{"ts" => 1483999200, "time" =>
                               "3:00 pm"}]]},
                                  "catering_message_to_user_on_create_order" => "test",
                                  "minimum_pickup_amount" => "50.00", "minimum_delivery_amount" => "50.00")
    end
  end

  describe "#to_param" do
    it "returns the merchant ID" do
      merchant = Merchant.new({"merchant_id" => "1"})
      expect(merchant.to_param).to eq("1")
    end
  end

  describe "#delivery_fee" do
    let(:generated_merchant) {Merchant.new(merchant_params)}

    context "delivery_fee > 0.00" do
      before {generated_merchant.delivery_cost = "1.00"}
      subject {generated_merchant.delivery_fee}

      it {is_expected.to eq(1.00)}
      it {is_expected.to be_a_kind_of(BigDecimal)}
    end

    context "delivery_fee is <= 0.00" do
      before {generated_merchant.delivery_cost = "0.00"}
      subject {generated_merchant.delivery_fee}

      it {is_expected.to eq(nil)}
    end
  end

  describe "#transaction_fee" do
    let(:generated_merchant) {Merchant.new(merchant_params)}

    context "trans_fee_rate > 0.00" do
      before {generated_merchant.trans_fee_rate = "5.00"}
      subject {generated_merchant.transaction_fee}

      it {is_expected.to eq(5.00)}
      it {is_expected.to be_a_kind_of(BigDecimal)}
    end

    context "trans_fee_rate <= 0.00" do
      before {generated_merchant.trans_fee_rate = "0.00"}
      subject {generated_merchant.transaction_fee}

      it {is_expected.to eq(nil)}
    end
  end

  describe "#in_delivery_area" do
    context "in range" do
      before(:each) do
        stub_request(:get, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/merchants/1234/isindeliveryarea/5000").
            to_return(
                :status => 200,
                :body => "{\"http_code\":200,\"stamp\":\"tweb03-i-027c8323-3447Z93\",\"data\":{\"is_in_delivery_range\":true},\"message\":null}")
      end

      it {expect(expect(Merchant.in_delivery_area?(1234, 5000)).to eq(true))}
    end

    context "not in range" do
      before(:each) do
        stub_request(:get, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/merchants/3030/isindeliveryarea/2020").
            to_return(
                :status => 200,
                :body => "{\"http_code\":200,\"stamp\":\"tweb03-i-027c8323-3447Z93\",\"data\":{\"is_in_delivery_range\":false},\"message\":null}")
      end

      it {expect(expect(Merchant.in_delivery_area?(3030, 2020)).to eq(false))}
    end
  end

  describe "#full_name" do
    context "name is the same as display name" do
      it "returns name" do
        merchant = Merchant.new({"name" => "Chris", "display_name" => "Chris"})
        expect(merchant.full_name).to eq("Chris")
      end
    end

    context "name is not the same as display name" do
      it "returns a formatted name" do
        merchant = Merchant.new({"name" => "Justin", "display_name" => "Chris"})
        expect(merchant.full_name).to eq("Justin, Chris")
      end
    end
  end

  describe "#full_address" do
    it 'should return the comma separated address' do
      merchant = Merchant.new(merchant_params)
      expect(merchant.full_address).to eq("1234 1st st, Apt 23, Whoville, NJ 55555")
    end
  end

  describe "#street_address" do
    let(:first_address) {Faker::Address.street_address}
    let(:secondary_address) {Faker::Address.secondary_address}

    context "contains multiple addresses" do
      it "returns the correctly formatted street address" do
        merchant = Merchant.new({
                                    "address1" => first_address,
                                    "address2" => secondary_address
                                })

        expect(merchant.street_address).to eq("#{first_address}, #{secondary_address}")
      end
    end

    context "contains only a first address" do
      it "returns the correctly formatted street address" do
        merchant = Merchant.new({"address1" => first_address})
        expect(merchant.street_address).to eq(first_address)
      end
    end

    context "contains only a second address" do
      it "returns the correctly formatted street address" do
        merchant = Merchant.new({"address2" => secondary_address})
        expect(merchant.street_address).to eq(secondary_address)
      end
    end
  end

  describe "#city_state_zip" do
    let(:city) {Faker::Address.city}
    let(:state) {Faker::Address.state}
    let(:zip) {Faker::Address.zip}

    context "contains city, state and zip" do
      it "returns the correctly formatted string" do
        merchant = Merchant.new({
                                    "city" => city,
                                    "state" => state,
                                    "zip" => zip
                                })

        expect(merchant.city_state_zip).to eq("#{city}, #{state} #{zip}")
      end
    end

    context "contains city and state" do
      it "returns the correctly formatted string" do
        merchant = Merchant.new({
                                    "city" => city,
                                    "state" => state
                                })

        expect(merchant.city_state_zip).to eq("#{city}, #{state}")
      end
    end

    context "contains city" do
      it "returns the correctly formatted string" do
        merchant = Merchant.new({"city" => city})
        expect(merchant.city_state_zip).to eq("#{city}")
      end
    end
  end

  describe "#delivers?" do
    it 'should return true if the merchant delivers' do
      merchant = Merchant.new(merchant_params)
      expect(merchant.delivers?).to eq(true)
    end

    it 'should return false if the merchant does not deliver' do
      merchant = Merchant.new(merchant_no_deliver)
      expect(merchant.delivers?).to eq(false)
    end
  end
end
