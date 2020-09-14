require "rails_helper"
require 'api'

describe UsersController do
  before(:each) { enable_ssl }

  describe "#account" do
    before { sign_in(get_user_data) }

    it "assigns the current user to @user" do
      get :account, params: {}
      expect(assigns(:user).user_id).to eq("2")
      expect(assigns(:user).first_name).to eq("bob")
      expect(assigns(:user).last_name).to eq("roberts")
    end

    it "renders 'users/payment_method'" do
      get :account, params: {}
      expect(response).to render_template("users/account")
    end
  end

  describe "#update_account" do
    before(:each) do
      sign_in(get_user_data)
    end

    context "invalid password confirmation" do
      let (:invalid_password_params) do
        { user: { password: Base64.strict_encode64("bobross"),
                  password_confirmation: Base64.strict_encode64("rossbob") } }
      end

      it "redirects to 'users/payment_method'" do
        post :update_account, params: invalid_password_params
        expect(response).to redirect_to(account_user_path)
      end

      it "sets the correct flash message" do
        post :update_account, params: invalid_password_params
        expect(response.request.flash[:error]).to eq("Password confirmation does not match.")
      end
    end

    context "valid password confirmation" do
      let (:password_params) do
        { user: { password: Base64.strict_encode64("bobross"),
                  password_confirmation: Base64.strict_encode64("bobross") } }
      end

      before do
        allow(API).to receive_message_chain(:post, :status) { 200 }
        allow(API).to receive_message_chain(:post, :body) { { data: {} }.to_json }
      end

      it "redirects to 'users/payment_method'" do
        post :update_account, params: password_params
        expect(response).to redirect_to(account_user_path)
      end

      it "sets the correct flash message" do
        post :update_account, params: password_params
        expect(flash[:notice]).to eq("Your account was successfully updated.")
      end
    end

    context "invalid response" do
      let(:invalid_params) { { user: { first_name: "bad" } } }

      before(:each) do
        stub_request(:post,
                     "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2")
          .with(body: "{\"first_name\":\"bad\"}")
          .to_return(status: 200, body: { error: { error: "Bad things happened." } }.to_json)
      end

      it "redirects to 'user_payments/new'" do
        post :update_account, params: invalid_params
        expect(response).to redirect_to(account_user_path)
      end

      it "sets the correct flash message" do
        post :update_account, params: invalid_params
        expect(flash[:error]).to eq("Bad things happened.")
      end
    end

    context "valid response" do
      let(:valid_params) { { user: { first_name: "jim", last_name: "roberts" } } }

      before(:each) do
        updated_user_json = "{\"delivery_locations\":[{\"user_addr_id\":\"202402\" ,\"user_id\":\"2\",\"name\":\"Metro Wastewater Reclamation Plant\",\"address1\":\"6450 York St\",\"address2\":\"Basement\",\"city\":\"Denver\",\"state\":\"CO\",\"zip\":\"80229\",\"lat\":\"39.8149386187446\",\"lng\":\"-104.956209155655\",\"phone_no\":\"(303) 286-3000\",\"instructions\":\"wear cruddy shoes\"}, {\"user_addr_id\":\"202403\",\"user_id\":\"1449579\",\"name\":\"\",\"address1\":\"555 5th st \",\"address2\":\"\",\"city\":\"Boulder\",\"state\":\"CT\",\"zip\":\"06001\",\"lat\":\"33.813101\",\"lng\":\"-111.917054\",\"phone_no\":\"5555555555\",\"instructions\":\"I answer naked\"}], \"last_four\": \"9861\", \"flags\":\"1C21000001\", \"user_id\":\"2\", \"first_name\":\"jim\", \"last_name\":\"roberts\", \"email\":\"bob@roberts.com\", \"contact_no\":\"4442221111\"}"
        updated_response = "{\"http_code\":\"200\",\"stamp\":\"tweb03-i-027c8323-FY6FPUS\",\"data\":#{updated_user_json}}"

        stub_request(:post,
                     "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2")
          .with(body: "{\"first_name\":\"jim\",\"last_name\":\"roberts\"}")
          .to_return(status: 200, body: updated_response)

        stub_request(:get,
                     "http://admin:welcome@test.splickit.com/app2/apiv2/users/credit_card/getviowritecredentials")
          .to_return(status: 200,
                     body: '{"http_code":200,"stamp":"tweb03-i-027c8323-68M17S6","data":{"vio_write_credentials":"splikit:vio-token"},"message":null}')
      end

      it "redirects to 'users/account'" do
        post :update_account, params: valid_params
        expect(response).to redirect_to(account_user_path)
      end

      it "sets the correct flash message" do
        post :update_account, params: valid_params
        expect(flash[:notice]).to eq("Your account was successfully updated.")
      end

      it "updates the session info" do
        post :update_account, params: valid_params
        expect(session[:current_user])
          .to eq({ "user_id" => "2",
                   "first_name" => "jim",
                   "last_name" => "roberts",
                   "email" => "bob@roberts.com",
                   "contact_no" => "4442221111",
                   "last_four" => "9861",
                   "delivery_locations" => [{ "user_addr_id" => "5667",
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
                                              "user_id" => "1449579",
                                              "name" => "",
                                              "address1" => "555 5th st ",
                                              "address2" => "",
                                              "city" => "Boulder",
                                              "state" => "CT",
                                              "zip" => "06001",
                                              "lat" => "33.813101",
                                              "lng" => "-111.917054",
                                              "phone_no" => "5555555555",
                                              "instructions" => nil }],
                   "brand_loyalty" => nil,
                   "flags" => "1C21000001",
                   "balance" => nil,
                   "group_order_token" => nil,
                   "marketing_email_opt_in" => nil,
                   "zipcode" => nil,
                   "birthday" => nil,
                   "privileges" => { "caching_action" => "respect",
                                     "ordering_action" => "send",
                                     "send_emails" => true,
                                     "see_inactive_merchants" => false},
                   "splickit_authentication_token" => "ASNDKASNDAS" })
      end
    end
  end

  describe "#orders_history" do
    before(:each) do
      sign_in(get_user_data)
    end

    context "page 1" do
      before do
        stub_request(:get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2/orderhistory?page=1")
          .to_return(:status => 200, :body => { data: get_user_orders_json }.to_json, :headers => {})
        get :orders_history, params: {}
      end

      it "assigs the correct orders to @orders" do
        get_user_orders_json["orders"].each_with_index do |order, index|
          order.keys.each do |key|
            if key == "merchant"
              expect(assigns(:orders)[index][key]).to be_kind_of(Merchant)
            else
              expect(order[key]).to eq(assigns(:orders)[index][key])
            end
          end
        end
      end

      it "assigns 10 order" do
        expect(assigns[:orders].size).to eq(10)
        expect(assigns[:orders_count]).to eq("11")
      end

      it "renders 'users/orders_history'" do
        expect(response).to render_template("users/orders_history")
      end

      it "gets pagination" do
        expect(assigns[:orders_pag]).to be_kind_of(Kaminari::PaginatableArray)
      end
    end

    context "page 2" do
      before do
        stub_request(:get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2/orderhistory?page=2")
          .to_return(:status => 200, :body => { data: get_user_orders_json_2 }.to_json, :headers => {})
        get :orders_history, params: { page: "2" }
      end

      it "assigs the correct orders to @orders page 2" do
        get_user_orders_json_2["orders"].each_with_index do |order, index|
          order.keys.each do |key|
            if key == "merchant"
              expect(assigns(:orders)[index][key]).to be_kind_of(Merchant)
            else
              expect(order[key]).to eq(assigns(:orders)[index][key])
            end
          end
        end
      end

      it "assigns 1 order" do
        expect(assigns[:orders].size).to eq(1)
        expect(assigns[:orders_count]).to eq("11")
      end

      it "renders 'users/orders_history'" do
        expect(response).to render_template("users/orders_history")
      end

      it "gets pagination" do
        expect(assigns[:orders_pag]).to be_kind_of(Kaminari::PaginatableArray)
      end
    end

    context "without any order" do
      before do
        stub_request(:get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2/orderhistory?page=1")
          .to_return(:status => 200, :body => { data: { "orders" => [], "totalOrders" => "0" } }.to_json, :headers => {})
        get :orders_history, params: {}
      end

      it "renders 'users/orders_history'" do
        expect(response).to render_template("users/orders_history")
      end

      it "gets no orders and no count" do
        expect(assigns[:orders].size).to eq(0)
        expect(assigns[:orders_count]).to eq(0)
      end

      it "gets pagination" do
        expect(assigns[:orders_pag]).to be_kind_of(Kaminari::PaginatableArray)
      end
    end

    context "API failed" do
      before do
        stub_request(:get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2/orderhistory?page=1")
          .to_return(:status => 200, :body => { error: { error: "barf" } }.to_json, :headers => {})
        get :orders_history, params: {}
      end

      it "redirects to merchants#index " do
        expect(response).to redirect_to(merchants_path)
      end

      it "shows flash error" do
        expect(flash[:error]).to eq("barf")
      end
    end
  end

  describe "#create" do
    let(:valid_params) do
      { first_name: "bob", last_name: "roberts", password: Base64.strict_encode64("password"),
        contact_no: "5555555555", email: "bob@roberts.com" }
    end

    before do
      stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users")
        .with(body: "{\"first_name\":\"bob\",\"last_name\":\"roberts\",\"email\":\"bob@roberts.com\",\"contact_no\":\"5555555555\",\"password\":\"password\"}")
        .to_return(body: get_authenticated_user_json, status: 200)
    end

    it "should only allow :first_name, :last_name, :email, :contact_no, :password" do
      expect(User).to receive("create").with("first_name" => "bob", "last_name" => "roberts",
                                             "password" => "password", "email" => "bob@roberts.com",
                                             "contact_no" => "5555555555")
      post :create, params: { user: valid_params.merge(stuff: "stuff") }
    end

    context "success" do
      it 'should have success notice' do
        post :create, params: { user: valid_params }
        expect(flash[:notice]).to eq("Your account was successfully created.")
      end

      it 'by default, redirects to root path' do
        post :create, params: { user: valid_params }
        expect(response).to redirect_to(root_path)
      end

      it 'if session[:continue] preset, redirect there' do
        session[:continue] = "/checkouts/new?merchant_id=1082"
        post :create, params: { user: valid_params }
        expect(response).to redirect_to("/checkouts/new?merchant_id=1082")
        expect(session[:continue]).to be_nil
      end

      it 'if params[:continue] preset, redirect there' do
        post :create, params: { user: valid_params, continue: "/checkouts/new?merchant_id=1082" }
        expect(response).to redirect_to("/checkouts/new?merchant_id=1082")
      end

      it "should setup the current user in the session" do
        post :create, params: { user: valid_params }
        expect(session[:current_user])
          .to eq({ "user_id" => "2",
                   "first_name" => "bob",
                   "last_name" => "roberts",
                   "email" => "bob@roberts.com",
                   "contact_no" => "4442221111",
                   "last_four" => "9861",
                   "delivery_locations" => [{ "user_addr_id" => "5667",
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
                                              "user_id" => "1449579",
                                              "name" => "",
                                              "address1" => "555 5th st ",
                                              "address2" => "",
                                              "city" => "Boulder",
                                              "state" => "CT",
                                              "zip" => "06001",
                                              "lat" => "33.813101",
                                              "lng" => "-111.917054",
                                              "phone_no" => "5555555555",
                                              "instructions" => nil }],
                   "brand_loyalty" => nil,
                   "flags" => "1C21000001",
                   "balance" => nil,
                   "group_order_token" => nil,
                   "marketing_email_opt_in" => nil,
                   "zipcode" => nil,
                   "birthday" => nil,
                   "privileges" => { "caching_action" => "respect",
                                     "ordering_action"=>"send",
                                     "send_emails" => true,
                                     "see_inactive_merchants" => false },
                   "splickit_authentication_token" => "ASNDKASNDAS" })
      end

      it "should assign @user" do
        post :create, params: { user: valid_params }
        expect(assigns[:user].user_id).to eq("2")
        expect(assigns[:user].first_name).to eq("bob")
        expect(assigns[:user].last_name).to eq("roberts")
        expect(assigns[:user].email).to eq("bob@roberts.com")
        expect(assigns[:user].last_four).to eq("9861")
        expect(assigns[:user].delivery_locations.count).to eq(2)
        expect(assigns[:user].flags).to eq("1C21000001")
        expect(assigns[:user].contact_no).to eq("4442221111")
        expect(assigns[:user].privileges).to_not be_nil
        expect(assigns[:user].splickit_authentication_token).to eq("ASNDKASNDAS")
      end
    end

    context "failure" do
      before do
        stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users").to_return(
          :body => {"error" => {"error" => "BAD"}}.to_json,
          :status => 500
        )
      end

      it 'should render new' do
        post :create, params: { user: { first_name: "bob", last_name: "roberts", password: "password" } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#new" do
    context "signed in user" do
      before(:each) do
        sign_in(get_user_data.merge("first_name" => "Bill", "last_name" => "Brown"))
      end

      it "should redirect user to the root_path" do
        get :new, params: {}
        expect(response).to redirect_to(root_path)
      end
    end

    context "signed out user" do
      it "should redirect user to the root_path" do
        get :new, params: {}
        expect(response).to render_template :new
      end
    end
  end
end
