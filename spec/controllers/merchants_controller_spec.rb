require "rails_helper"
require 'api'

describe MerchantsController do

  before { enable_ssl }

  describe "#index" do
    let(:merch1) { {"active" => "Y", "merchant_id" => "100028", "merchant_external_id" => nil, "brand_id" => "190", "lat" => "39.917047", "lng" => "-105.053184", "name" => "Deli Zone", "display_name" => "Broomfield - 120th & Sheridan", "address1" => "12161 Sheridan", "description" => "Sandwiches made the way they were meant to be!", "city" => "Broomfield", "state" => "CO", "zip" => "80020", "phone_no" => "7209740521", "delivery" => "N", "distance" => "1.1763717584181679", "brand" => "Deli Zone", "promo_count" => "NA"} }
    let(:merch2) { {"active" => "Y", "merchant_id" => "100029", "merchant_external_id" => nil, "brand_id" => "191", "lat" => "39.918", "lng" => "-105.0532", "name" => "Deli Area", "display_name" => "Broomfield - 120th & Sheridan", "address1" => "12222 Sheridan", "description" => "Sandwiches made the way the other guy does!", "city" => "Broomfield", "state" => "CO", "zip" => "80020", "phone_no" => "3033332222", "delivery" => "Y", "distance" => "1.24456", "brand" => "Deli Area", "promo_count" => "NA"} }

    let(:merch3) { {"active" => "Y", "merchant_id" => "100030", "merchant_external_id" => nil, "brand_id" => "192", "lat" => "49.917047", "lng" => "-115.053184", "name" => "Law Abiding Pete's", "display_name" => "Interlocken", "address1" => "4408 Interlocken Parkway", "description" => "Burritos for the churchgoing, responsible crowd.", "city" => "Aurora", "state" => "CO", "zip" => "90020", "phone_no" => "7209740521", "delivery" => "N", "distance" => "1.1763717584181679", "brand" => "Law Abiding Pete's", "promo_count" => "NA"} }
    let(:merch4) { {"active" => "Y", "merchant_id" => "100031", "merchant_external_id" => nil, "brand_id" => "193", "lat" => "49.918", "lng" => "-115.0532", "name" => "Noodles Standing Alone", "display_name" => "Interlocken", "address1" => "4412 Interlocken Parkway", "description" => "Noodles without condiments or sauces.", "city" => "Aurora", "state" => "CO", "zip" => "90020", "phone_no" => "3033332222", "delivery" => "Y", "distance" => "1.24456", "brand" => "Noodles Standing Alone", "promo_count" => "NA"} }
    let(:test_skin) { {"android_url" => "https://play.google.com/store/apps/details?id=com.splickit.test", "iphon_url" => "https://itunes.apple.com/us/app/t-aco/id746123890", "allows_tipping" => "Y", "allows_in_store_payments" => "N"} }

    before do
      merchant_where_stub(params: { location: 80020 }, return: { merchants: [merch1, merch2] })

      merchant_where_stub(params: { location: 90020 }, return: { merchants: [merch3, merch4] })

      stub_request(:get, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/merchants?limit=10&minimum_merchant_count=5&range=100&location=00000").to_return(
        :body => "{\"http_code\":\"422\",\"error\":{\"error\" : \"Much disaster!\"}}"
      )

      stub_request(:any, /.*#{ API.skin_domain }\/api\/skins\/order.json/).to_return(
        :body => test_skin.to_json
      )
    end

    context "delivery_path signed in" do
      before do
        merchant_where_stub(params: { location: 80020 }, auth_token: "FATCAT", return: { merchants: [merch3, merch4] } )

        user = get_user_data.merge("email" => "bob@roberts.com", "splickit_authentication_token" => "FATCAT",
                                   "privileges" => { "see_inactive_merchants" => true })
        sign_in(user)
      end

      it "should assign delivery path if provided" do
        get :index, params: { location: "80020", delivery_path: "123" }
        expect(assigns(:delivery_path)).to eq("123")
      end

      it "should not assign delivery path if it is not provided or invalid" do
        get :index, params: { location: "80020" }
        expect(assigns(:delivery_path)).to be_nil
      end
    end

    context "delivery_path signed in" do
      it "should not assign delivery path if not sign in" do
        get :index, params: { location: "80020" }
        expect(assigns(:delivery_path)).to be_nil
      end
    end

    context "user zip provided" do
      context "valid ZIP" do
        context "params ZIP" do
          before { get :index, params: { location: "80020" } }

          it { expect(session[:location]).to eq("80020") }
          it { expect(assigns(:location)).to eq("80020") }

          it { expect(assigns(:merchants).length).to eq(2) }
          it { expect(assigns(:merchants)[0].merchant_id).to eq("100028") }
          it { expect(assigns(:merchants)[0].brand_id).to eq("190") }
          it { expect(assigns(:merchants)[1].merchant_id).to eq("100029") }
          it { expect(assigns(:merchants)[1].brand_id).to eq("191") }

          it { expect(response).to render_template(:index) }
        end
      end

      context "api error" do
        it 'should render index to avoid redirect loop' do
          get :index, params: { location: "00000" }
          expect(response).to render_template(:index)
        end

        it 'should set the flash message' do
          get :index, params: { location: "00000" }
          expect(flash[:error]).to eq("Much disaster!")
        end

        it 'should not set session[:zip]' do
          get :index, params: { location: "00000" }
          expect(session[:location]).to be_nil
        end
      end
    end

    it "should assign flash text when you provide a empty merchantlist param" do
      allow(GeoIPService).to receive(:find) { nil }
      get :index, params: { merchantlist: "" }
      expect(assigns[:merchants]).to be_nil
      expect(flash[:error]).to eq("Please enter a merchantlist param")
    end

    it "should search merchant by other params if merchantlist is blank" do
      get :index, params: { merchantlist: "", location: "80020" }
      expect(assigns[:merchants]).to be_present
    end

    context "merchantlist provided" do
      before do
        merchant_where_stub(params: { merchantlist: "1000" },
                            return: { merchants: [{ active: "Y",
                                                    merchant_id: "1000",
                                                    merchant_external_id: "001",
                                                    brand_id: "162",
                                                    lat: "40",
                                                    lng: "1000",
                                                    name: "Illegal Pete's",
                                                    display_name: "Test MerchantList",
                                                    address1: "1320 College Ave",
                                                    description: "Fast, Fresh, Healthy",
                                                    city: "Boulder",
                                                    state: "CO",
                                                    zip: "80302",
                                                    phone_no: "3034443055",
                                                    delivery: "N",
                                                    distance: "2.2647914903494777",
                                                    brand: "Illegal Pete's",
                                                    promo_count: "NA",
                                                    group_ordering_on: "1" }] })
        get :index, params: { merchantlist: "1000" }
      end

      it "should return the correct merchant" do
        expect(assigns[:merchants].count).to eq(1)
        expect(assigns[:merchants].first).to be_kind_of(Merchant)
        expect(assigns[:merchants].first.merchant_id).to eq("1000")
        expect(assigns[:merchants].first.display_name).to eq("Test MerchantList")
      end
    end

    context "no user zip provided" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip) { "192.168.0.1" }
      end

      context "ip located" do
        before(:each) do
          merchant_where_stub(params:{ lat: 40.049599, lng: -105.276901 }, return: { merchants:[merch3, merch4] })

          stub_request(:any, /.*apiv2\/skins\/com.splickit.order/).to_return(
            :body => {
              "http_code" => 200,
              "stamp" => "tweb03-i-027c8323-P8X8X57",
              "data" => {
                "skin_id" => "14",
                "skin_name" => "Test",
                "skin_description" => "Test",
                "brand_id" => "282",
                "mobile_app_type" => "B",
                "external_identifier" => "com.splickit.test",
                "custom_skin_message" => "",
                "welcome_letter_file" => nil,
                "in_production" => "Y",
                "web_ordering_active" => "N",
                "donation_active" => "N",
                "donation_organization" => "Share Our Strength",
                "facebook_thumbnail_url" => "http://itunes.apple.com/us/app/pita-pit/id461735388?mt=8",
                "android_marketplace_link" => "https://play.google.com/store/apps/details?id=com.splickit.pitapit&hl=en",
                "twitter_handle" => "PitaPitUSA",
                "iphone_certificate_file_name" => "com.splickit.pitapit.pem",
                "current_iphone_version" => "3.0.0",
                "current_android_version" => "3.1",
                "facebook_app_id" => "",
                "facebook_app_secret" => "",
                "rules_info" => "<h3>Reward points redemption</h3>n      <p>See our local redemption schedule below. But beware...your local Pitan        Pit may offer even more great deals!</p>nn      <dl>n        <dt>Standard Pita / Fork Style</dt>n        <dd>90 Points</dd>n        <dt>6\"Pita/KidsPita</dt>n<dd>70Points</dd>n<dt>32ozFountainDrink</dt>n<dd>30Points</dd>n<dt>BagofChips</dt>n<dd>15Points</dd>n<dt>FreshBakedCookie</dt>n<dd>10Points</dd>n</dl>nn<p>LearnmoreonthePitCardand<ahref=\"https://www.mypitapitcard.com/faq\">FAQ's</a>page.</p>",
                "supports_history" => "1",
                "supports_join" => "1",
                "supports_link_card" => "1",
                "lat" => "47.6737",
                "lng" => "-116.781",
                "zip" => "30502",
                "loyalty_features" => {
                  "supports_history" => true,
                  "supports_join" => true,
                  "supports_link_card" => true
                },
                "http_code" => 200,
                "loyalty_tnc_url" => "http://www.google.com"
              },
              "message" => nil
            }.to_json
          )

          stub_request(:get, "http://geoip3.maxmind.com/b?l=9dTTeej5EwG7&i=192.168.0.1").
            to_return(
              :status => 200,
              :body => "US,CO,Boulder,40.049599,-105.276901")
        end

        it 'should set merchants correctly' do
          get :index, params: {}

          expect(assigns(:merchants).length).to eq(2)
          expect(assigns(:merchants)[0].merchant_id).to eq("100030")
          expect(assigns(:merchants)[0].brand_id).to eq("192")
          expect(assigns(:merchants)[1].merchant_id).to eq("100031")
          expect(assigns(:merchants)[1].brand_id).to eq("193")
          expect(response).to render_template(:index)
        end
      end

      context "ip not located" do
        before do
          stub_request(:get, "http://geoip3.maxmind.com/b?l=9dTTeej5EwG7&i=192.168.0.1").
            to_return(
              :status => 200,
              :body => ",,,,IP_NOT_FOUND")
        end

        context "skin has a zip" do
          before(:each) do
            merchant_where_stub(params: { location: 30502 }, return: { merchants: [ merch3, merch4 ] } )
            stub_request(:any, /.*apiv2\/skins\/com.splickit.order/).to_return(
              :body => {
                "http_code" => 200,
                "stamp" => "tweb03-i-027c8323-P8X8X57",
                "data" => {
                  "skin_id" => "14",
                  "skin_name" => "Test",
                  "skin_description" => "Test",
                  "brand_id" => "282",
                  "mobile_app_type" => "B",
                  "external_identifier" => "com.splickit.test",
                  "custom_skin_message" => "",
                  "welcome_letter_file" => nil,
                  "in_production" => "Y",
                  "web_ordering_active" => "N",
                  "donation_active" => "N",
                  "donation_organization" => "Share Our Strength",
                  "facebook_thumbnail_url" => "http://itunes.apple.com/us/app/pita-pit/id461735388?mt=8",
                  "android_marketplace_link" => "https://play.google.com/store/apps/details?id=com.splickit.pitapit&hl=en",
                  "twitter_handle" => "PitaPitUSA",
                  "iphone_certificate_file_name" => "com.splickit.pitapit.pem",
                  "current_iphone_version" => "3.0.0",
                  "current_android_version" => "3.1",
                  "facebook_app_id" => "",
                  "facebook_app_secret" => "",
                  "rules_info" => "<h3>Reward points redemption</h3>n      <p>See our local redemption schedule below. But beware...your local Pitan        Pit may offer even more great deals!</p>nn      <dl>n        <dt>Standard Pita / Fork Style</dt>n        <dd>90 Points</dd>n        <dt>6\"Pita/KidsPita</dt>n<dd>70Points</dd>n<dt>32ozFountainDrink</dt>n<dd>30Points</dd>n<dt>BagofChips</dt>n<dd>15Points</dd>n<dt>FreshBakedCookie</dt>n<dd>10Points</dd>n</dl>nn<p>LearnmoreonthePitCardand<ahref=\"https://www.mypitapitcard.com/faq\">FAQ's</a>page.</p>",
                  "supports_history" => "1",
                  "supports_join" => "1",
                  "supports_link_card" => "1",
                  "lat" => "47.6737",
                  "lng" => "-116.781",
                  "zip" => "30502",
                  "loyalty_features" => {
                    "supports_history" => true,
                    "supports_join" => true,
                    "supports_link_card" => true
                  },
                  "http_code" => 200,
                  "loyalty_tnc_url" => "http://www.google.com"
                },
                "message" => nil
              }.to_json
            )

            allow(GeoIPService).to receive(:find) { nil }
          end

          it 'should set merchants correctly' do
            get :index, params: {}

            expect(assigns(:merchants).length).to eq(2)
            expect(assigns(:merchants)[0].merchant_id).to eq("100030")
            expect(assigns(:merchants)[0].brand_id).to eq("192")
            expect(assigns(:merchants)[1].merchant_id).to eq("100031")
            expect(assigns(:merchants)[1].brand_id).to eq("193")
            expect(response).to render_template(:index)
          end
        end

        context "skin does not have zip" do
          before(:each) do
            stub_request(:any, /.*apiv2\/skins\/com.splickit.order/).to_return(
              :body => {
                "http_code" => 200,
                "stamp" => "tweb03-i-027c8323-P8X8X57",
                "data" => {
                  "skin_id" => "14",
                  "skin_name" => "Test",
                  "skin_description" => "Test",
                  "brand_id" => "282",
                  "mobile_app_type" => "B",
                  "external_identifier" => "com.splickit.test",
                  "custom_skin_message" => "",
                  "welcome_letter_file" => nil,
                  "in_production" => "Y",
                  "web_ordering_active" => "N",
                  "donation_active" => "N",
                  "donation_organization" => "Share Our Strength",
                  "facebook_thumbnail_url" => "http://itunes.apple.com/us/app/pita-pit/id461735388?mt=8",
                  "android_marketplace_link" => "https://play.google.com/store/apps/details?id=com.splickit.pitapit&hl=en",
                  "twitter_handle" => "PitaPitUSA",
                  "iphone_certificate_file_name" => "com.splickit.pitapit.pem",
                  "current_iphone_version" => "3.0.0",
                  "current_android_version" => "3.1",
                  "facebook_app_id" => "",
                  "facebook_app_secret" => "",
                  "rules_info" => "<h3>Reward points redemption</h3>n      <p>See our local redemption schedule below. But beware...your local Pitan        Pit may offer even more great deals!</p>nn      <dl>n        <dt>Standard Pita / Fork Style</dt>n        <dd>90 Points</dd>n        <dt>6\"Pita/KidsPita</dt>n<dd>70Points</dd>n<dt>32ozFountainDrink</dt>n<dd>30Points</dd>n<dt>BagofChips</dt>n<dd>15Points</dd>n<dt>FreshBakedCookie</dt>n<dd>10Points</dd>n</dl>nn<p>LearnmoreonthePitCardand<ahref=\"https://www.mypitapitcard.com/faq\">FAQ's</a>page.</p>",
                  "supports_history" => "1",
                  "supports_join" => "1",
                  "supports_link_card" => "1",
                  "lat" => "47.6737",
                  "lng" => "-116.781",
                  "zip" => "",
                  "loyalty_features" => {
                    "supports_history" => true,
                    "supports_join" => true,
                    "supports_link_card" => true
                  },
                  "http_code" => 200,
                  "loyalty_tnc_url" => "http://www.google.com"
                },
                "message" => nil
              }.to_json
            )
          end

          it 'should set error flash' do
            get :index, params: {}
            expect(response).to render_template(:index)
            expect(flash[:error]).to eq("Please enter a valid zip code.")
          end
        end

        context "Find user via GeoIP" do
          before do
            stub_request(:get, "http://test.splickit.com/app2/apiv2/merchants?lat=23.555&limit=10&lng=55.123&minimum_merchant_count=5&range=100")
            allow(GeoIPService).to receive(:find) { [23.555, 55.123] }
          end

          it "stores the user's lat / lng" do
            get :index, params: {}
            expect(session[:lat]).to eq(23.555)
            expect(session[:lng]).to eq(55.123)
          end
        end
      end
    end

    it "assigns @merchants correctly" do
      get :index, params: { location: "80020" }
      expect(assigns(:merchants).first.merchant_id).to eq("100028")
      expect(assigns(:merchants).first.name).to eq("Deli Zone")
      expect(assigns(:merchants).first.display_name).to eq("Broomfield - 120th & Sheridan")
      expect(assigns(:merchants).first.phone_no).to eq("(720) 974-0521")
      expect(assigns(:merchants).first.lat).to eq("39.917047")
      expect(assigns(:merchants).first.lng).to eq("-105.053184")
      expect(assigns(:merchants).first.address1).to eq("12161 Sheridan")
      expect(assigns(:merchants).first.city).to eq("Broomfield")
      expect(assigns(:merchants).first.state).to eq("CO")
      expect(assigns(:merchants).first.zip).to eq("80020")
      expect(assigns(:merchants).first.delivery).to eq("N")
    end

    it "assigns @merchants as type Merchant" do
      get :index, params: { location: "80020" }
      expect(assigns(:merchants).first).to be_kind_of(Merchant)
      expect(assigns(:merchants).last).to be_kind_of(Merchant)
    end

    context "see inactive merchants" do
      it 'should set RequestStore with see_inactive_merchants session variable, user email, and user password if see_inactive_merchant is true' do
        merchant_where_stub(params:{ location: 80020 }, return: { merchants:[merch3, merch4]}, auth_token: "FATCAT" )
        user = get_user_data.merge("email" => "bob@roberts.com", "splickit_authentication_token" => "FATCAT", "privileges" => {"see_inactive_merchants" => true})
        sign_in(user)
        get :index, params: { location: "80020" }
        expect(RequestStore.store[:see_inactive_merchants]).to eq(true)
        expect(RequestStore.store[:auth_token]).to be_nil
      end
    end

    it "should set RequestStore see_inactive_merchants to false if there is no current user" do
      RequestStore.store[:see_inactive_merchants] = nil
      RequestStore.store[:auth_token] = nil
      get :index, params: { location: "80020" }
      expect(RequestStore.store[:see_inactive_merchants]).to eq(false)
      expect(RequestStore.store[:auth_token]).to eq(nil)
    end
  end

  describe "#show" do
    let(:merchant) { create_merchant("merchant_id"=> 4000) }

    before do
      merchant_find_stub(params: { merchant_id: merchant.merchant_id }, return: merchant.as_json(root: false))
      merchant_find_stub(params: { merchant_id: merchant.merchant_id }, return: merchant.as_json(root: false), delivery: true)
      allow(GroupOrder).to receive(:find) { {} }
    end

    describe "#redirect correct merchant" do
      it "should redirect to correct merchant" do
        merchant.moved_to_merchant_id = "1000"
        merchant_find_stub(merchant_id: "103", return: merchant.as_json(root: false))

        get :show, params: { id: "103", order_type: "pickup" }
        expect(response).to redirect_to(merchant_path(id: "1000", order_type: "pickup"))
      end

      it "should not redirect to correct merchant" do
        merchant_find_stub(merchant_id: "103", return: merchant.as_json(root: false))

        get :show, params: { id: "103", order_type: "pickup" }
        expect(response).not_to redirect_to(merchant_path(id: "1000", order_type: "pickup"))
      end
    end

    it "should be return merchant with hours" do
      get :show, params: { id: "4000", order_type: "pickup" }
      expect(response).to render_template('show')
    end

    it "should assign @modal false from my_order param" do
      get :show, params: { id: "4000", order_type: "pickup" }
      expect(assigns[:modal]).to be_falsey

      get :show, params: { id: "4000", order_type: "pickup", my_order: "2" }
      expect(assigns[:modal]).to be_falsey

      get :show, params: { id: "4000", order_type: "pickup", my_order: "false" }
      expect(assigns[:modal]).to be_falsey
    end

    it "should assign @modal true from my_order param" do
      get :show, params: { id: "4000", order_type: "pickup", my_order: "1" }
      expect(assigns[:modal]).to be_truthy
    end

    it "assigns @group_order_token from the group_order_token" do
      get :show, params: { id: "4000", group_order_token: "C5VJ0-N5R5F" }
      expect(assigns(:group_order_token)).to eq("C5VJ0-N5R5F")
    end

    it "assigns @group_order_token and reset current order" do
      get :show, params: { id: "4000", group_order_token: "C5VJ0-N5R5F" }
      expect(assigns(:group_order_token)).to eq("C5VJ0-N5R5F")
      get :show, params: { id: "4000", group_order_token: "C5VJ0-N5R53" }
      expect(assigns(:group_order_token)).to eq("C5VJ0-N5R53")
      expect(session[:order]).to be_nil
    end


    it "stores the merchant_id in session if none is present" do
      get :show, params: { id: "4000" }
      expect(session[:last_merchant_seen]).to eq("4000")
    end

    it "overwrites an existing merchant_id in session" do
      session[:last_merchant_seen] = "3850"
      get :show, params: { id: "4000" }
      expect(session[:last_merchant_seen]).to eq("4000")
    end

    context "with system message" do
      before do
        merchant.message = "This is a message for YOU, the user!"
        merchant_find_stub({ params: { merchant_id: merchant.merchant_id }, return: merchant.as_json(root: false)} )
      end

      it 'should set flash alert with user message' do
        get :show, params: { id: "4000", order_type: "pickup", group_order_token: "brownies" }
        expect(response.request.flash[:alert]).to eq("This is a message for YOU, the user!")
      end
    end

    context "order merchant mismatch" do
      before(:each) do
        session[:order] = {}
        session[:order][:items] = []
        session[:order][:meta] = {merchant_id: "4000", order_type: "pickup"}
      end

      it "clears the order with a different merchant is detected" do
        expect(session[:order]).to_not be_nil
        get :show, params: { id: "2", order_type: "pickup" }
        expect(session[:order]).to be_nil
      end

      it "clears the order with a different menu type is detected" do
        expect(session[:order]).to_not be_nil
        get :show, params: { id: "2", order_type: "delivery" }
        expect(session[:order]).to be_nil
      end

      it "doesn't clear the order with the same merchant + menu" do
        expect(session[:order]).to_not be_nil
        get :show, params: { id: "4000", order_type: "pickup" }
        expect(session[:order]).to_not be_nil
      end
    end

    context "pickup" do
      before { get :show, params: { id: "4000", order_type: "pickup" } }

      it 'renders the show template' do
        expect(response).to render_template('show')
      end

      it 'assigns @merchant' do
        test_merchant = Merchant.new(merchant.as_json(root: false ))
        expect(assigns(:merchant).as_json(root: false )).to eq(test_merchant.as_json(root: false ))
      end

      it 'assigns @order_type' do
        expect(assigns(:order_type)).to eq("pickup")
      end
    end

    context "delivery" do
      context "signed in with address selected" do
        before(:each) do
          merchant_find_stub(params: { merchant_id: merchant.merchant_id }, return: merchant.as_json(root: false), auth_token:"1234", delivery: true)
          user = get_user_data.merge("email" => "mr@fat.com", "splickit_authentication_token" => "1234")
          sign_in(user)
        end

        context "part of a group order" do
          context "signed in" do
            it "renders show" do
              get :show, params: { id: merchant.merchant_id, order_type: "delivery", group_order_token: "brownies" }
              expect(response).to render_template("show")
            end
          end

          context "not signed in" do
            it "renders show" do
              sign_out
              get :show, params: { id: merchant.merchant_id, order_type: "delivery", group_order_token: "brownies" }
              expect(response).to render_template("show")
            end
          end
        end

        context "inside delivery range" do
          before do
            merchant_indeliveryarea_stub({ merchant_id: merchant.merchant_id, delivery_address_id: 102, auth_token: "1234",  return: { is_in_delivery_range: true }, message: nil })
            cookies[:userPrefs] = "{\"preferredAddressId\":102}"
          end

          it "renders the show template" do
            get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
            expect(response).to render_template('show')
          end

          it "assigns @merchant" do
            get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
            test_merchant = Merchant.new(merchant.as_json(root: false ))
            expect(assigns(:merchant).as_json(root: false )).to eq(test_merchant.as_json(root: false ))
          end

          it "assigns @order_type" do
            get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
            expect(assigns(:order_type)).to eq("delivery")
          end
        end

        context "outside delivery range" do
          let(:loyal_user) { get_loyal_user_data.merge("first_name" => "Jim", "last_name" => "Kirk", "email" => "james.t.kirk@sf.gov", "user_id" => "1701") }

          before(:each) do
            merchant_find_stub({ params: { merchant_id: merchant.merchant_id }, return: merchant.as_json(root: false), auth_token:"ASNDKASNDAS", delivery: true } )
            merchant_indeliveryarea_stub({ merchant_id: merchant.merchant_id, delivery_address_id: 102, auth_token: "ASNDKASNDAS",  return: { is_in_delivery_range: true }, message: nil })
            sign_in(loyal_user)
            stub_request(:get, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/users/1701").to_return(
              :body => "{\"http_code\":\"200\",\"stamp\":\"tweb03-i-027c8323-FY6FPUS\",\"data\":#{loyal_user.to_json}}",
              :status => 200
            )

            merchant_indeliveryarea_stub({ merchant_id: merchant.merchant_id, delivery_address_id: 102, auth_token: "ASNDKASNDAS", return: { is_in_delivery_range: false }, message: nil })
            cookies[:userPrefs] = "{\"preferredAddressId\":102}"
          end

          it "redirects to the root_path" do
            get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
            expect(response).to redirect_to(action: :index)
          end

          it "redirects with the user specified zip" do
            session[:location] = "12345"
            get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
            expect(response).to redirect_to(action: :index, location: "12345")
          end

          it "sets the correct flash message" do
            get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
            expect(response.request.flash[:error]).to eq("Sorry, that address isn't in range.")
          end
        end
      end

      context "no userPrefs" do
        before do
          merchant_find_stub(params: { merchant_id: merchant.merchant_id }, return: merchant.as_json(root: false), auth_token:"1234")
          merchant_find_stub(params: { merchant_id: merchant.merchant_id }, return: merchant.as_json(root: false), auth_token:"1234", delivery: true)
          user = get_user_data.merge("email" => "mr@fat.com", "splickit_authentication_token" => "1234")
          sign_in(user)
        end

        it "redirects to the merchants_path" do
          get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
          expect(response).to redirect_to(merchants_path)
        end

        it "sets the error flash" do
          get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
          expect(response.request.flash[:error]).to eq("Please select a valid delivery address.")
        end
      end

      context "not signed in" do
        it "redirects to the merchants_path" do
          get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
          expect(response).to redirect_to(merchants_path)
        end

        it "sets the error flash" do
          get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
          expect(response.request.flash[:error]).to eq("Please sign in and select a delivery address.")
        end
      end
    end

    context "with cart order" do
      before do
        session[:order] = { meta: { merchant_id: merchant.merchant_id, order_type: "delivery" }, items: [], cart_id: "123" }
      end

      it "should set the order type to the one that is on params" do
        get :show, params: { id: merchant.merchant_id, order_type: "pickup" }
        expect(session[:order][:meta][:order_type]).to eq("pickup")
      end
    end

    it "should not change order type if there is not any order" do
      get :show, params: { id: merchant.merchant_id, order_type: "delivery" }
      expect(session[:order]).to be_nil
    end

    context "error from api" do
      before do
        merchant_find_stub(merchant_id: "103", return: merchant.as_json(root: false))
        allow(Merchant).to receive(:find).and_raise(APIError.new("Stop trying to cheer me up!"))
      end

      it "redirects to the merchants_path" do
        get :show, params: { id: "103", order_type: "pickup" }
        expect(response).to redirect_to(merchants_path)
      end

      it "sets the error flash" do
        get :show, params: { id: "103", order_type: "pickup" }
        expect(response.request.flash[:error]).to eq("Stop trying to cheer me up!")
      end
    end

    context "GroupOrderError" do
      before do
        allow(GroupOrder).to receive(:find).and_call_original

        merchant_find_stub(merchant_id: "103", return: merchant.as_json(root: false))
        group_order_find_stub(auth_token: { email: "admin", password: "welcome" }, group_order_token: "123",
                              error: { error: "GO error", error_type: "group_order" })

        session[:order] = { meta: { merchant_id: "103", group_order_token: "123" }, cart_id: "test", items: [] }
      end

      it "should redirect to checkout page with correct params" do
        get :show, params: { id: "103", order_type: "pickup", group_order_token: "123" }

        expect(response).to redirect_to(merchant_path(id: "103", order_type: "pickup"))
      end

      it "should reset cart_id" do
        get :show, params: { id: "103", order_type: "pickup", group_order_token: "123" }

        expect(session[:order][:cart_id]).to be_nil
      end

      it "should clear GO data" do
        get :show, params: { id: "103", order_type: "pickup", group_order_token: "123" }

        expect(session[:group_order]).to be_nil
      end
    end

    context "API system messages" do
      before do
        merchant_find_stub({ params: { merchant_id: merchant.merchant_id }, return: merchant.as_json(root: false), message: "Message from API on list merchants, System Message!!!" } )
      end
      it "should be show 'message' content" do
        get :show, params: { id: merchant.merchant_id, order_type: "pickup" }
        expect(assigns(:merchant).message).not_to be_nil
        expect(assigns(:merchant).message).to eq("Message from API on list merchants, System Message!!!")
      end
    end
  end
end
