require "rails_helper"
require 'api'

describe SessionsController do

  before(:each) { enable_ssl }

  describe "#create" do
    let (:password) { Base64.strict_encode64("password") }

    context "correct credentials" do
      before do
        user_authenticate_stub
      end

      it "should set session current_user" do
        post :create, params: { user: { email: "bob@roberts.com", password: password } }
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

      it "should redirect user to the root path" do
        post :create, params: { user: { email: "bob@roberts.com", password: password } }
        expect(response).to redirect_to root_path
      end
    end

    context "incorrect credentials" do
      before do
        user_authenticate_stub(auth_token: { email: "email@email.com", password: "password" },
                               error: { error: "Holy schnikes, it is bad" })
      end

      it "should redirect user to stand alone signin page" do
        post :create, params: { user: { email: "email@email.com", password: password } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#new" do
    context "before filter" do
      it "should assign continue_path" do
        get :new, params: { continue_path: "/", query_location: "sa", query_delivery_path: "123"}
        expect(session[:continue]).to eq("%2F%3Fdelivery_path%3D123%26location%3Dsa")
      end
    end

    context "valid referer" do
      it "assigns session[:continue] w/ params[:continue]" do
        get :new, params: { continue: "/bacon" }
        expect(session[:continue]).to eq("%2Fbacon")
      end

      it "HTTP REFERER overrides the continue default" do
        @request.env['HTTP_REFERER'] = "http://splickit.com/merchants/1080?magic=param"
        get :new, params: { continue: "/bacon" }
        expect(session[:continue]).to eq("%2Fbacon")
      end

      it "renders the sessions/new.html.erb" do
        get :new
        expect(response).to render_template "sessions/new"
      end

      context "params[:notice] NOT specified" do
        it "doesn't set the flash[:notice]" do
          get :new
          expect(response.request.flash[:notice]).to eq(nil)
        end
      end

      context "user already signed in" do
        before(:each) do
          session[:current_user] = {name: "Bill Brown"}
        end

        it "should redirect user to the root_path" do
          get :new
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe "#destroy" do
    before do
      cookies[:stuff] = "my stuff"
      session[:current_user] = { "id" => "01", "name" => "Luke Duke",
                                 "email" => "goodolboy@hazard.gov", "password" => "password"}
    end

    it 'should reset the session' do
      get :destroy
      expect(session[:current_user]).to be_nil
    end

    it 'should reset the RequestStore auth_token' do
      get :destroy
      expect(RequestStore.store[:auth_token]).to be_nil
    end

    it 'should delete cookies' do
      get :destroy
      expect(cookies[:stuff]).to be_nil
    end

    it 'should redirect to the root path' do
      get :destroy
      expect(response).to redirect_to(root_path)
    end
  end

  describe "#session_status" do
    context "user is NOT signed in" do
      it "should return a non-signed-in status" do
        get :session_status
        expect(response.body).to eq({ signed_in: false }.to_json)
      end
    end
    context "user is signed in" do
      before(:each) do
        session[:current_user] = {name: "Bill Brown"}
      end
      it "should return a signed-in status" do
        get :session_status
        expect(response.body).to eq({ signed_in: true }.to_json)
      end
    end
  end
end
