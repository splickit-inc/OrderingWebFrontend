require "rails_helper"

describe CateringsController do
	let(:merchant) do
		Merchant.new("merchant_id" => "12345",
                 "name" => "Hammersmith Folly",
                 "address1" => "Something St.",
                 "address2" => "#105",
                 "city" => "Denver",
                 "state" => "CO",
                 "zip" => "50505")
	end

  before do
    sign_in(get_user_data)
    merchant_find_stub(auth_token: "ASNDKASNDAS", catering: true, merchant_id: "1", return: { merchant_id: "1" })
  end

  describe "before filter" do
    describe "redirect if no delivery data" do
      context "pickup" do
        before do
          merchant_catering_data_stub(auth_token: "ASNDKASNDAS", order_type: "pickup", merchant_id: "1")
        end

        it "should continue the flow" do
          get :new, params: { merchant_id: "1", order_type: "pickup" }
          expect(assigns[:merchant].merchant_id).to eq("1")
        end
      end

      context "with delivery data" do
        before do
          merchant_catering_data_stub(auth_token: "ASNDKASNDAS", order_type: "delivery", merchant_id: "1")
          merchant_indeliveryarea_stub(auth_token: "ASNDKASNDAS", merchant_id: "1",
                                       delivery_address_id: "5667")
          cookies[:userPrefs] = {preferredAddressId: "5667"}.to_json
        end

        it "should continue the flow" do
          get :new, params: { merchant_id: "1", order_type: "delivery" }
          expect(assigns[:merchant].merchant_id).to eq("1")
        end
      end

      context "without delivery data" do
        before do
          cookies.delete(:userPrefs)
        end

        it "should redirect to root path if there is not delivery data on delivery order type" do
          get :new, params: { order_type: "delivery" }
          expect(response).to redirect_to root_path
        end

        it "should set no delivery data message if there is not delivery data on delivery order type" do
          get :new, params: { order_type: "delivery" }
          expect(flash[:error]).to eq("Please select a valid delivery address.")
        end
      end
    end
  end

  describe "#new" do
    before do
			merchant_catering_data_stub(auth_token: "ASNDKASNDAS", order_type: "pickup", merchant_id: "1")
    end

    it "should assign @merchant" do
      get :new, params: { merchant_id: "1", order_type: "pickup" }
      expect(assigns[:merchant].merchant_id).to eq("1")
    end

    it "should assign @catering data" do
			get :new, params: { merchant_id: "1", order_type: "pickup" }
      expect(assigns[:catering_data]).to eq("available_catering_times"=>
                                                {"max_days_out"=>4,
                                                 "time_zone"=>"America/Los_Angeles",
                                                 "daily_time"=> [[{ "ts" => 1483992000, "time" => "1:00 pm" },
                                                                 { "ts" => 1483995600, "time" => "2:00 pm" }],
                                                                [{ "ts" => 1483999200, "time" =>
                                                                    "3:00 pm" }]]},
                                            "catering_message_to_user_on_create_order" => "test",
                                            "minimum_pickup_amount" => "50.00", "minimum_delivery_amount" => "50.00")
    end
  end

	describe "#create" do
    it "should send user_addr_id if available" do
			expect(API).to receive("post")
											 .with("/catering", { number_of_people: "1",
                                            timestamp_of_event: "1484169890", contact_name: "Jose",
                                            contact_phone: "555-555-5555", notes: "1",
                                            merchant_id: "106004", user_addr_id: "1"}.to_json,
                             { user_auth_token: "ASNDKASNDAS" }).and_return(nil)
      post :create, params: { merchant_id: "106004",
                              order_type: "delivery",
                              user_addr_id: "1",
                              catering: { number_of_people: "1", timestamp_of_event: "1484169890",
                                          contact_name: "Jose",
                                          contact_phone: "555-555-5555", notes: "1" } }
    end

		it "should assign @catering" do
			catering_create_stub(auth_token: "ASNDKASNDAS")
      post :create, params: { merchant_id: "106004",
                              order_type: "pickup",
                              catering: { number_of_people: "1", timestamp_of_event: "1484169890", contact_name: "Jose",
                                          contact_phone: "555-555-5555", notes: "1" } }
      expect(assigns(:catering)).to eq("id" => "1001", "number_of_people" => "1", "event" => "",
                                       "order_type" => "delivery", "order_id" => "12208606",
                                       "user_delivery_location_id" => nil,
                                       "date_tm_of_event" => "2017-01-11 14:24:50",
                                       "timestamp_of_event" => "1484169890", "contact_info" => "Jose 555-555-5555",
                                       "notes" => nil, "status" => "In Progress", "insert_id" => 1001,
                                       "ucid" => "4076-1de8d-57dbc-lar86")
    end

    it "should initialize an order, set cart id and meta params" do
      catering_create_stub(auth_token: "ASNDKASNDAS")
      post :create, params: { merchant_id: "106004",
                              order_type: "pickup",
                              catering: { number_of_people: "1", timestamp_of_event: "1484169890", contact_name: "Jose",
                                          contact_phone: "555-555-5555", notes: "1" } }
      expect(session[:order][:cart_id]).to eq("4076-1de8d-57dbc-lar86")
      expect(session[:order][:items]).to eq([])
      expect(session[:order][:meta]).to eq(merchant_id: "106004", order_type: "pickup", catering: true, skin_name: "Test")
    end
	end
end
