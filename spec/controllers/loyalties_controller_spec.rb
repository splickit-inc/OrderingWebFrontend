require "rails_helper"
require 'api'

describe LoyaltiesController do

  before(:each) { enable_ssl }

  describe "#show" do
    context "not signed in" do
      it "redirects the user to the sign in path w/ the correct continue params" do
        get :show
        expect(response).to redirect_to(sign_in_path(continue: "/user/loyalty"))
      end
    end

    context "signed in" do
      before do
        sign_in(get_loyal_user_data)
      end

      it "assigns valid user attributes to @user" do
        get :show
        expect(assigns(:user).user_id).to eq("2")
        expect(assigns(:user).first_name).to eq("bob")
        expect(assigns(:user).last_name).to eq("roberts")
        expect(assigns(:user).email).to eq("bob@roberts.com")
        expect(assigns(:user).contact_no).to eq("4442221111")
        expect(assigns(:user).brand_loyalty["loyalty_number"]).to eq("140105420000001793")
        expect(assigns(:user).brand_loyalty["pin"]).to eq("9189")
        expect(assigns(:user).brand_loyalty["points"]).to eq("500")
        expect(assigns(:user).brand_loyalty["usd"]).to eq("25")
      end

      context "loyal user" do
        it 'should redirect to history_user_loyalty_path' do
          get :show
          expect(response).to redirect_to history_user_loyalty_path
        end
      end

      context "non loyal user" do
        it "renders the 'users/loyalty/show' template" do
          sign_in(get_user_data)
          get :show
          expect(response).to render_template "users/loyalty/join"
        end
      end
    end
  end

  describe "#update_card" do
    context "invalid loyalty info" do
      before(:each) do
        sign_in(get_user_data)
        allow(User).to receive(:update).and_raise(APIError.new "Happy tree friends.")
      end
      it "sets the correct flash alert message" do
        post :update_card
        expect(flash[:error]).to eq("Happy tree friends.")
      end
    end

    context "valid loyalty info" do
      let(:valid_params) { { brand_loyalty: { loyal_number: "12345", pin: "1234" } } }
      before do
        sign_in(get_user_data)
        allow(User).to receive(:update) { "updated user" }
      end

      it "assigns the user instance" do
        post :update_card, params: valid_params
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

      it "renders the 'users/loyalty/show' template" do
        post :update_card, params: valid_params
        expect(response).to redirect_to user_loyalty_path
      end
    end
  end

  context "signed in loyal user" do
    before do
      sign_in(get_loyal_user_data.merge({ "user_id" => "1701",
                                          "first_name" => "Bob",
                                          "email" => "bob@roberts.com" }))
    end

    describe "#manage" do
      it 'should assign user' do
        get :manage
        expect(assigns(:user).user_id).to eq("1701")
        expect(assigns(:user).brand_loyalty["loyalty_number"]).to eq("140105420000001793")
        expect(assigns(:user).brand_loyalty["pin"]).to eq("9189")
        expect(assigns(:user).brand_loyalty["points"]).to eq("500")
        expect(assigns(:user).brand_loyalty["usd"]).to eq("25")
      end

      it 'should render users/loyalty/manage' do
        get :manage
        expect(response).to render_template("users/loyalty/manage")
      end
    end

    describe "#history" do
      before(:each) do
        stub_request(:get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/1701/loyalty_history?format=v2").
          to_return(
          :status => 200,
          :body => {data: [{cat: "round"}, {cat: "short"}]}.to_json)
      end

      it 'should assign @user' do
        get :history
        expect(assigns(:user).user_id).to eq("1701")
        expect(assigns(:user).brand_loyalty["loyalty_number"]).to eq("140105420000001793")
        expect(assigns(:user).brand_loyalty["pin"]).to eq("9189")
        expect(assigns(:user).brand_loyalty["points"]).to eq("500")
        expect(assigns(:user).brand_loyalty["usd"]).to eq("25")
      end

      it 'should assign @user_transactions' do
        get :history
        expect(assigns(:user_transactions)).to eq([{"cat" => "round"}, {"cat" => "short"}])
      end

      it 'should render users/loyalty/history' do
        get :history
        expect(response).to render_template("users/loyalty/history")
      end
    end

    describe "#rules" do
      before do
        rules_loyalty_stub
      end

      it 'should assign user' do
        get :rules
        expect(assigns(:user).user_id).to eq("1701")
        expect(assigns(:user).brand_loyalty["loyalty_number"]).to eq("140105420000001793")
        expect(assigns(:user).brand_loyalty["pin"]).to eq("9189")
        expect(assigns(:user).brand_loyalty["points"]).to eq("500")
        expect(assigns(:user).brand_loyalty["usd"]).to eq("25")
      end

      it 'should render users/loyalty/rules' do
        get :rules
        expect(response).to render_template("users/loyalty/rules")
      end
    end
  end
end
