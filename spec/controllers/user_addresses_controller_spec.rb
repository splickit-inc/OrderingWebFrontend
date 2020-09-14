require "rails_helper"
require 'api'

describe UserAddressesController do
  describe "#index" do
    before do
      sign_in(get_user_data)
    end

    it "assigns the correct addresses to @addresses" do
      get :index

      expect(assigns(:addresses)[0]["address1"]).to eq("6450 York St")
      expect(assigns(:addresses)[0]["city"]).to eq("Denver")
      expect(assigns(:addresses)[0]["state"]).to eq("CO")
      expect(assigns(:addresses)[0]["zip"]).to eq("80229")

      expect(assigns(:addresses)[1]["address1"]).to eq("555 5th st ")
      expect(assigns(:addresses)[1]["city"]).to eq("Boulder")
      expect(assigns(:addresses)[1]["state"]).to eq("CT")
      expect(assigns(:addresses)[1]["zip"]).to eq("06001")
    end

    it "renders 'users/address/delivery_address'" do
      get :index
      expect(response).to render_template("users/address/delivery_address")
    end
  end

  describe "#create" do
    before do
      sign_in(get_user_data)

      stub_request(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }/app2/phone/setuserdelivery")
        .with(body: user_address_params.to_json)
        .to_return(status: 200, body: set_user_address_response.to_json)
    end

    it "calls store_address with the correct params" do
      expect(User).to receive(:store_address)
                        .with(ActionController::Parameters.new(user_address_params).permit!, { user_auth_token: "ASNDKASNDAS" })
      post :create, params: { address: user_address_params }
    end

    it "redirects to 'users/delivery_address'" do
      post :create, params: { address: user_address_params }
      expect(response).to redirect_to(user_address_index_path)
    end

    it "calls store_address to validate the business name with value" do
      params = ActionController::Parameters.new(user_address_params_business_name_with_value).permit!
      expect(User).to receive(:store_address).with(params, { user_auth_token: "ASNDKASNDAS" })
      post :create, params: { address: user_address_params_business_name_with_value }
    end

    it "upload session and assigns @user" do
      user_find_stub({ return: { "delivery_locations" =>
                                   [{ "user_addr_id" => "5667",
                                      "user_id" => "2",
                                      "name" => "Metro Wastewater Reclamation Plant",
                                      "address1" => "6450 York St",
                                      "address2" => "Basement",
                                      "city" => "Denver",
                                      "state" => "CO",
                                      "zip" => "80229",
                                      "lat" => "39.8149386187446",
                                      "lng" => "-104.956209155655",
                                      "phone_no" => "(303) 286-3000",
                                      "instructions" => "wear cruddy shoes" },
                                    { "user_addr_id" => "202403",
                                      "user_id" => "2",
                                      "name" => "",
                                      "address1" => "555 5th st ",
                                      "address2" => "",
                                      "city" => "Boulder",
                                      "state" => "CT",
                                      "zip" => "06001",
                                      "lat" => "33.813101",
                                      "lng" => "-111.917054",
                                      "phone_no" => "5555555555",
                                      "instructions" => nil },
                                    { "user_addr_id" => "202404",
                                      "user_id" => "2",
                                      "name" => "",
                                      "business_name" => "",
                                      "address1" => "Fortune and Glory Ln.",
                                      "address2" => "101",
                                      "city" => "Shanghai",
                                      "state" => "UT",
                                      "zip" => "80123",
                                      "lat" => "33.813101",
                                      "lng" => "-111.917054",
                                      "phone_no" => "123-123-1234",
                                      "instructions" => "Don't mind the sock." }] } })

      expect(session[:current_user]["delivery_locations"].count).to eq(2)

      post :create, params: { address: user_address_params }

      expect(session[:current_user]["delivery_locations"].count).to eq(3)
      expect(session[:current_user]["delivery_locations"][2])
        .to eq({ "user_addr_id" => "202404",
                 "user_id" => "2",
                 "name" => "",
                 "business_name" => "",
                 "address1" => "Fortune and Glory Ln.",
                 "address2" => "101",
                 "city" => "Shanghai",
                 "state" => "UT",
                 "zip" => "80123",
                 "lat" => "33.813101",
                 "lng" => "-111.917054",
                 "phone_no" => "123-123-1234",
                 "instructions" => "Don't mind the sock." })
      expect(assigns[:user].delivery_locations.count).to eq(3)
      expect(assigns[:user].delivery_locations[2])
        .to eq({ "user_addr_id" => "202404",
                 "user_id" => "2",
                 "name" => "",
                 "business_name" => "",
                 "address1" => "Fortune and Glory Ln.",
                 "address2" => "101",
                 "city" => "Shanghai",
                 "state" => "UT",
                 "zip" => "80123",
                 "lat" => "33.813101",
                 "lng" => "-111.917054",
                 "phone_no" => "123-123-1234",
                 "instructions" => "Don't mind the sock." })

    end

    context "merchant param present" do
      let(:path) { "/user/address/new?path=/merchants/103893&order_type=delivery" }
      it "redirects to merchant path" do
        post :create, params: { address: user_address_params, path: path }
        expect(response).to redirect_to("#{path}&user_addr_id=202780")
      end

      it "assigns notice" do
        post :create, params: { address: user_address_params, path: path }
        expect(flash[:notice]).to eq "Address successfully added!"
      end

      it "redirect to delivery_address_user_path with merchant param" do
        stub_request(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }/app2/phone/setuserdelivery")
          .with(body: user_address_params.to_json)
          .to_return(status: 200, body: { "ERROR" => "error message" }.to_json)

        post :create, params: { address: user_address_params, path: path }
        address = user_address_params.delete_if { |k, v| v.empty? }
        expect(response).to redirect_to(user_address_index_path(address.merge(path: path)))
      end
    end
  end

  describe "#destroy" do
    before do
      sign_in(get_user_data)

      stub_request(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }/app2/phone/setuserdelivery").
        with(
          :body => user_address_params.to_json).
        to_return(
          :status => 200,
          :body => set_user_address_response.to_json)

      stub_request(:delete, "http://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2/userdeliverylocation/2").
        to_return(
          :status => 200,
          :body => {:data => {"result" => "success" }}.to_json)
    end

    it "calls delete_address with the correct params" do
      expect(User).to receive(:delete_address).with("2", "2", "ASNDKASNDAS")
      delete :destroy, params: { id: 2 }
    end

    it "should set user instance" do
      user_find_stub(return: { "delivery_locations" =>
                                 [{ "user_addr_id" => "5667",
                                    "user_id" => "2",
                                    "name" => "Metro Wastewater Reclamation Plant",
                                    "address1" => "6450 York St",
                                    "address2" => "Basement",
                                    "city" => "Denver",
                                    "state" => "CO",
                                    "zip" => "80229",
                                    "lat" => "39.8149386187446",
                                    "lng" => "-104.956209155655",
                                    "phone_no" => "(303) 286-3000",
                                    "instructions" => "wear cruddy shoes" }] })

      expect(session[:current_user]["delivery_locations"].count).to eq(2)

      delete :destroy, params: { id: 2 }

      expect(session[:current_user]["delivery_locations"].count).to eq(1)
      expect(session[:current_user]["delivery_locations"].first)
        .to eq("user_addr_id" => "5667",
               "user_id" => "2",
               "name" => "Metro Wastewater Reclamation Plant",
               "address1" => "6450 York St",
               "address2" => "Basement",
               "city" => "Denver",
               "state" => "CO",
               "zip" => "80229",
               "lat" => "39.8149386187446",
               "lng" => "-104.956209155655",
               "phone_no" => "(303) 286-3000",
               "instructions" => "wear cruddy shoes")
      expect(assigns[:user].delivery_locations.count).to eq(1)
      expect(assigns[:user].delivery_locations.first)
        .to eq("user_addr_id" => "5667",
               "user_id" => "2",
               "name" => "Metro Wastewater Reclamation Plant",
               "address1" => "6450 York St",
               "address2" => "Basement",
               "city" => "Denver",
               "state" => "CO",
               "zip" => "80229",
               "lat" => "39.8149386187446",
               "lng" => "-104.956209155655",
               "phone_no" => "(303) 286-3000",
               "instructions" => "wear cruddy shoes")
    end

    context "html request" do
      it "redirects to 'users/delivery_address'" do
        delete :destroy, params: { id: 2 }
        expect(response).to redirect_to(user_address_index_path)
      end
    end

    context "ajax request" do
      before(:each) do
        change_to_json_request
      end

      it "should return correct json" do
        stubs_delivery_address_success("ASNDKASNDAS", "2", "2")
        expect(User).to receive(:delete_address).with("2", "2", "ASNDKASNDAS")
        delete :destroy, xhr: true, params: { id: 2 }
        expect(JSON.parse(response.body)).to eq("user_addr_id" => "2")
      end

      it "should return failed json" do
        stubs_delivery_address_failure("ASNDKASNDAS", "2", "2")
        delete :destroy, xhr: true, params: { id: 2 }
        expect(response.body).to eq "Could not locate the user delivery record"
      end
    end
  end
end