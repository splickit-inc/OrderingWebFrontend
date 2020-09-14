require "rails_helper"

describe ApplicationController, type: :controller do

  before(:each) { enable_ssl }

  controller do
    before_action :set_continue

    def new
      raise ApplicationController::AccessDenied
    end
    
    def index
      render  plain: "Hello"
    end
  end

  let(:bob_skin) { '{"data":{"android_marketplace_link":"https://play.google.com/store/apps/details?id=com.splickit.bob", "facebook_thumbnail_url":"https://itunes.apple.com/us/app/bob-taco/id746123890"}}' }
  let(:test_skin) { '{"data":{"android_marketplace_link":"https://play.google.com/store/apps/details?id=com.splickit.test", "facebook_thumbnail_url":"https://itunes.apple.com/us/app/test-taco/id746123890"}}' }
  let(:skin) { '{"data":{"android_marketplace_link":"https://play.google.com/store/apps/details?id=com.splickit", "facebook_thumbnail_url":"https://itunes.apple.com/us/app/default-taco/id746123890"}}' }

  before do
    stub_request(:get, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/skins/com.splickit.bob").to_return(
      :body => bob_skin
    )

    stub_request(:get, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/skins/com.splickit.order").to_return(
      :body => skin
    )

    stub_request(:get, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/skins/com.splickit.test").to_return(
      :body => test_skin
    )

    stub_request(:get, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/skins/com.splickit.bad").to_return(
      :body => "bad!", :status => 500
    )

  end

  describe "#log_error_and_redirect" do
    it "should call Airbrake when there is an error" do
      expect(Airbrake).to receive(:notify_sync)
      get :new
    end

    it "should redirect to 500 error page" do
      get :new
      expect(response).to redirect_to error_500_path
    end
  end

  describe "#redirect_unsupported_mobile_browsers" do
    it 'should redirect if we are safari version 7 or below on iphone' do
      request.user_agent="Mozilla/5.0 (iPhone; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A"
      get :index
      expect(response).to redirect_to(app_path)
    end

    it 'should redirect if we are safari version 7 or below on ipad' do
      request.user_agent="Mozilla/5.0 (iPad; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A"
      get :index
      expect(response).to redirect_to(app_path)
    end

    it 'should not redirect if we are any other version' do
      request.user_agent="Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
      get :index
      expect(response).not_to be_redirect
    end

    it 'should not redirect if we do not have a user agent' do
      request.user_agent=""
      get :index
      expect(response).not_to be_redirect
    end
  end

  describe "#setup_skin_id" do
    context "skinname.splickit.com" do
      it "should setup the specified skin" do
        request.host = "bob.splickit.com"
        get :index, params: { :location => "80020" }
        expect(assigns(:skin).android_marketplace_link).to eq("https://play.google.com/store/apps/details?id=com.splickit.bob")
        expect(assigns(:skin).facebook_thumbnail_url).to eq("https://itunes.apple.com/us/app/bob-taco/id746123890")
      end
    end

    context "skinname-order.splickit.com" do
      it "should setup the specified skin" do
        request.host = "bob-order.splickit.com"
        get :index, params: { :location => "80020" }
        expect(assigns(:skin).android_marketplace_link).to eq("https://play.google.com/store/apps/details?id=com.splickit.bob")
        expect(assigns(:skin).facebook_thumbnail_url).to eq("https://itunes.apple.com/us/app/bob-taco/id746123890")
      end
    end

    it "should default if the host is localhost" do
      request.host = "localhost"
      get :index, params: { :location => "80020" }
      expect(assigns(:skin).android_marketplace_link).to eq("https://play.google.com/store/apps/details?id=com.splickit")
      expect(assigns(:skin).facebook_thumbnail_url).to eq("https://itunes.apple.com/us/app/default-taco/id746123890")
    end

    it "should default if the host is 127.0.0.1" do
      request.host = "127.0.0.1"
      get :index, params: { :location => "80020" }
      expect(assigns(:skin).android_marketplace_link).to eq("https://play.google.com/store/apps/details?id=com.splickit")
      expect(assigns(:skin).facebook_thumbnail_url).to eq("https://itunes.apple.com/us/app/default-taco/id746123890")
    end

    it "should default to order if no skin is found" do
      request.host = "bad.splickit.com"
      get :index, params: { :location => "80020" }
      expect(assigns(:skin).android_marketplace_link).to eq("https://play.google.com/store/apps/details?id=com.splickit")
      expect(assigns(:skin).facebook_thumbnail_url).to eq("https://itunes.apple.com/us/app/default-taco/id746123890")
    end

    it "should set RequestStore with the correct skin" do
      request.host = "bob.splickit.com"
      get :index, params: { location: "80020" }
      expect(Skin.current_name).to eq("bob")
    end

    it "should set RequestStore with the correct skin" do
      request.host = "test-order12.splickit.com"
      get :index, params: { location: "80020" }
      expect(Skin.current_name).to eq("test")
    end

    it "should use the specified override for skin" do
      request.host = "bob.splickit.com"
      get :index, params: { location: "80020", override_skin: "test" }
      expect(assigns(:skin).android_marketplace_link).to eq("https://play.google.com/store/apps/details?id=com.splickit.test")
      expect(assigns(:skin).facebook_thumbnail_url).to eq("https://itunes.apple.com/us/app/test-taco/id746123890")
    end
    
    it "sets 'moes' for Moe's URL" do
      request.host = "order.moes-punchh.com"
      get :index, params: { location: "80020" }
      expect(Skin.current_name).to eq("moes")
    end

    context "http://54.225.193.61" do
      it "uses the default skin" do
        request.host = "54.225.193.61"
        get :index, params: { :location => "80020" }
        expect(Skin.current_name).to eq("order")
      end
    end
  end

  describe "#set_user_instance" do
    context "signed in user" do
      before do
        sign_in({ "user_id" => "300",
                  "first_name" => "Leonidas",
                  "last_name" => "Smith",
                  "email" => "leonidas@sparta.com",
                  "splickit_authentication_token" => "12345" })
      end

      context "api request false" do
        let(:user){ User.new(user_id: "300",
                             first_name: "Leonidas",
                             last_name: "Smith",
                             email: "leonidas@sparta.com",
                             contact_no: nil,
                             last_four: nil,
                             delivery_locations: nil,
                             brand_loyalty: nil,
                             flags: nil,
                             balance: nil,
                             group_order_token: nil,
                             marketing_email_opt_in: nil,
                             zipcode: nil,
                             birthday: nil,
                             privileges: nil,
                             splickit_authentication_token: "12345") }

        it "should set @user for currently logged in user" do
          get :index
          expect(assigns(:user).user_id).to eq(user.user_id)
          expect(assigns(:user).first_name).to eq(user.first_name)
          expect(assigns(:user).last_name).to eq(user.last_name)
          expect(assigns(:user).email).to eq(user.email)
          expect(assigns(:user).splickit_authentication_token).to eq(user.splickit_authentication_token)
        end
      end

      context "api request true" do
        let(:user) { User.new(first_name: "Leonidas",
                              last_name: "Smith",
                              email: "leonidas@sparta.com",
                              splickit_authentication_token: "123456") }

        before do
          expect(User).to receive("find").with("300", "12345").and_return(user)
          controller.set_user_instance(true)
        end

        it "should set @user for currently logged in user" do
          expect(assigns(:user).user_id).to eq(user.user_id)
          expect(assigns(:user).first_name).to eq(user.first_name)
          expect(assigns(:user).last_name).to eq(user.last_name)
          expect(assigns(:user).email).to eq(user.email)
          expect(assigns(:user).splickit_authentication_token).to eq(user.splickit_authentication_token)
        end
      end
    end

    context "remember me option" do

      context "remember me true" do
        before do
          sign_in({ "user_id" => "300",
                    "first_name" => "Leonidas",
                    "last_name" => "Smith",
                    "email" => "leonidas@sparta.com",
                    "splickit_authentication_token" => "12345",
                    "remember_me" => "1"})
        end

        before do
          controller.set_user_instance(true)
        end

        it "user should set session variable 'remember_me' to be true" do
          expect(session[:remember_me]["remember_me"]).not_to be_nil
        end
      end

      context "remember me false" do
        before do
          sign_in({ "user_id" => "300",
                    "first_name" => "Leonidas",
                    "last_name" => "Smith",
                    "email" => "leonidas@sparta.com",
                    "splickit_authentication_token" => "12345",
                    "remember_me" => "0"})
        end

        before do
          controller.set_user_instance(true)
        end

        it "user should set session variable 'remember_me' to be true" do
          expect(session[:remember_me]["remember_me"]).to eq(false)
        end
      end
    end

    context "no user signed in" do
      it "should not set @user" do
        get :index
        expect(assigns(:user)).to eq(nil)
      end
    end
  end


  describe "helper methods" do
    describe "#decode_params" do
      it "should decode sensible data" do
        expect(controller.decode_params(email: "test", password: "cGFzc3dvcmQ=")).to eq(email: "test", password: "password")
      end
    end

    describe "#set_user_session" do
      it "sets the correct user session" do
        user = create_authenticated_user
        controller.set_user_session(user)
        expect(session[:current_user])
          .to eq({ "user_id" => "2",
                   "first_name" => "bob",
                   "last_name" => "roberts",
                   "email" => "bob@roberts.com",
                   "contact_no" => "4442221111",
                   "last_four" => "9861",
                   "delivery_locations"=>[{ "user_addr_id" => "5667",
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
                                            "instructions"=>"wear cruddy shoes" },
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
                                     "see_inactive_merchants" => false },
                   "splickit_authentication_token" => "ASNDKASNDAS" })
      end
    end

    describe "#update_current_user" do
      before do
        sign_in({ "user_id" => "300",
                  "first_name" => "Leonidas",
                  "last_name" => "Smith",
                  "email" => "leonidas@sparta.com",
                  "splickit_authentication_token" => "12345" })
      end

      it "should update session" do
        controller.update_current_user({ user_id: "2", flags: "45" })
        expect(session[:current_user]["user_id"]).to eq("2")
        expect(session[:current_user]["flags"]).to eq("45")
      end
    end

    context "current_user exists" do
      before do
        sign_in("user_id" => "4",
                "first_name" => "Gob",
                "last_name" => "Gob_last",
                "email" => "gob@thealliance.com",
                "splickit_authentication_token" => "HABBERDASH")
      end

      it "should provide a user" do
        user = controller.current_user
        expect(user).to be_a(User)
        expect(user.user_id).to eq("4")
        expect(user.first_name).to eq("Gob")
        expect(user.last_name).to eq("Gob_last")
        expect(user.email).to eq("gob@thealliance.com")
        expect(user.splickit_authentication_token).to eq("HABBERDASH")
      end

      context "@user blank" do
        before do
          @user = nil
        end

        it "should provide current_user_name" do
          expect(controller.current_user_name).to eq("Gob Gob_last")
        end

        it "should provide current_user_email" do
          expect(controller.current_user_email).to eq("gob@thealliance.com")
        end

        it "should provide current_user_id" do
          expect(controller.current_user_id).to eq("4")
        end

        it "should provide current_user_auth_token hash" do
          expect(controller.current_user_auth_token_hash).to eq({ user_auth_token: "HABBERDASH" })
        end
      end

      context "@user present" do
        it "should provide current_user_name" do
          expect(controller.current_user_name).to eq("Gob Gob_last")
        end

        it "should provide current_user_email" do
          expect(controller.current_user_email).to eq("gob@thealliance.com")
        end

        it "should provide current_user_id" do
          expect(controller.current_user_id).to eq("4")
        end

        it "should provide current_user_auth_token hash" do
          expect(controller.current_user_auth_token_hash).to eq({ user_auth_token: "HABBERDASH" })
        end
      end
    end

    context "current_user does not exist" do
      before do
        session[:current_user] = nil
      end

      it "should not provide a user" do
        expect(controller.current_user).to be_nil
      end

      it "should provide nil current_user_name if no user exists" do
        expect(controller.current_user_name).to be_nil
      end

      it "should provide nil current_user_email if no user exists" do
        expect(controller.current_user_email).to be_nil
      end

      it "should provide nil current_user_id if no user exists" do
        expect(controller.current_user_id).to be_nil
      end
    end
  end

  describe "#set_continue" do
    it "should set session[:continue] from param[:continue]" do
      get :index,params: { continue: "bob" }
      expect(session[:continue]).to eq("bob")
    end

    it "should set session[:continue] to nil if no param" do
      get :index
      expect(session[:continue]).to eq(nil)
    end

    it "doesn't escape already escaped params[:continue]" do
      get :index, params: { continue: CGI::escape(user_path) }
      expect(session[:continue]).to eq("%2Fuser")
    end
  end

  describe "#browser detect for mobile and descktop" do
    it "desktop - firefox" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:41.0) Gecko/20100101 Firefox/41.0";
      get :index
      expect(RequestStore.store[:client_device]).to eq("web")

      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0";
      get :index
      expect(RequestStore.store[:client_device]).to eq("web")

    end

    it "desktop - chrome" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36";
      get :index
      expect(RequestStore.store[:client_device]).to eq("web")

      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36";
      get :index
      expect(RequestStore.store[:client_device]).to eq("web")
    end

    it "desktop - safari" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/601.2.7 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.7";
      get :index
      expect(RequestStore.store[:client_device]).to eq("web")
    end

    it "desktop - iexplorer" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)";
      get :index
      expect(RequestStore.store[:client_device]).to eq("web")
    end

    it "desktop - opera" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36 OPR/33.0.1990.58";
      get :index
      expect(RequestStore.store[:client_device]).to eq("web")

      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36 OPR/33.0.1990.58";
      get :index
      expect(RequestStore.store[:client_device]).to eq("web")

    end

    it "mobile - firefox galaxy tab" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Linux; U; Android 2.3.4; en-us; SPH-P100 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end

    it "mobile - firefox sony z1" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Android 5.0.2; Mobile; rv:42.0) Gecko/42.0 Firefox/42.0";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end

    it "mobile - chrome sony z1" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Linux; Android 5.0.2; C6902 Build/14.5.A.0.270) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.76 Mobile Safari/537.36";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end


    it "mobile - default browser samsung sIII" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Linux; U; Android 4.3; es-us; GT-I9300 Build/JSS15J) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end

    it "mobile - chrome samsung sIII" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Linux; Android 4.3; GT-I9300 Build/JSS15J) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.76 Mobile Safari/537.36";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end


    it "mobile - opera galaxy tab" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Linux; U; Android 2.3.4; en-US; SPH-P100 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 OPR/12.0.1987.97260 Safari/533.1";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end

      it "mobile - opera sony z1" do
        request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Linux; Android 5.0.2; C6902 Build/14.5.A.0.270) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.64 Mobile Safari/537.36 OPR/33.0.2002.97617";
        get :index

        expect(RequestStore.store[:client_device]).to eq("web-mobile")
      end

    it "mobile - opera samsung sIII" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Linux; U; Android 4.3; es-US; GT-I9300 Build/JSS15J) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 OPR/12.0.1987.97260 Mobile Safari/534.30";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end



    it "mobile - firefox galaxi tab" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Android; Mobile; rv:33.0) Gecko/33.0 Firefox/33.0";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end


    it "mobile - safari iPad - iOS 8_2" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12D508 Safari/600.1.4";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end

    it "mobile - safari iphone  - iOS 9" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (iPad; CPU OS 8_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12F69 Safari/600.1.4";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end

    it "mobile - safari iphone  - iOS 8_4_1" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_4_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12H321 Safari/600.1.4";
      get :index

      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end

    it "mobile - dolphin" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Linux; U; Android 2.3.4; en-us; SPH-P100 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1";
      get :index
      expect(RequestStore.store[:client_device]).to eq("web-mobile")
    end
  end

  describe "sign_out" do
    before do
      request.cookies[:test] = "test"
      session[:session_test] = "test"
    end

    it "should reset all cookies" do
      controller.sign_out
      expect(response.cookies[:test]).to be_nil
    end

    it "should reset all sessions" do
      controller.sign_out
      expect(session[:session_test]).to be_nil
    end
  end

  describe "#sign_in_punchh" do
    it "should sign in if header is present and user is not signed" do
      user_authenticate_stub(punch_header: "test_token",
                             return: { email: "test_email@mail.com" })

      get :index, params: { security_token: "test_token" }
      expect(session[:current_user]).to eq("user_id" => "2",
                                           "first_name" => "bob",
                                           "last_name" => "roberts",
                                           "email"=>"test_email@mail.com",
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
                                                                      "instructions" => "wear cruddy shoes"},
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
                                           "zipcode" => nil, "birthday" => nil,
                                           "privileges" => { "caching_action" => "respect",
                                                             "ordering_action" => "send",
                                                             "send_emails" => true,
                                                             "see_inactive_merchants" => false },
                                           "splickit_authentication_token" => "ASNDKASNDAS")

      expect(WebMock).to have_requested(:get, "http://test.splickit.com/app2/apiv2/usersession")
                           .with("headers" => { "Punch-Authentication-Token" => "test_token" })
    end

    it "should save token on session" do
      user_authenticate_stub(punch_header: "test_token",
                             return: { email: "test_email@mail.com" })

      get :index, params: { security_token: "test_token" }
      expect(session[:punch_auth_token]).to eq("test_token")
    end

    it "should not sign in if it is already login" do
      sign_in(get_user_data)
      expect(ApplicationController).not_to receive("sign_in")
      get :index
    end

    it "should not sign in with punch token if header is not available" do
      expect(ApplicationController).not_to receive("sign_in")
      get :index
    end

    it "should not save token on session if header is not available" do
      get :index
      expect(session[:punchh_auth_token]).to be_nil
    end
  end

  describe "sign_in" do
    context "email params" do
      let(:params) { { email: "test_email@mail.com", password: "password" } }

      before do
        user_authenticate_stub(auth_token: params,
                               return: { email: params[:email] })
      end

      it "should set user session" do
        controller.sign_in(params)
        expect(session[:current_user]).to eq("user_id" => "2",
                                             "first_name" => "bob",
                                             "last_name" => "roberts",
                                             "email"=>"test_email@mail.com",
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
                                                                        "instructions" => "wear cruddy shoes"},
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
                                             "zipcode" => nil, "birthday" => nil,
                                             "privileges" => { "caching_action" => "respect",
                                                               "ordering_action" => "send",
                                                               "send_emails" => true,
                                                               "see_inactive_merchants" => false },
                                             "splickit_authentication_token" => "ASNDKASNDAS")
      end

      it "should call user's authenticate" do
        expect(User).to receive("authenticate").with(params)
        controller.sign_in(params)
      end
    end

    context "punchh params" do
      let(:params) { { user_auth_token: "test_token" } }

      before do
        user_authenticate_stub(auth_token: params[:user_auth_token],
                               return: { email: "test_email@mail.com" })
      end

      it "should set user session" do
        controller.sign_in(params)
        expect(session[:current_user]).to eq("user_id" => "2",
                                             "first_name" => "bob",
                                             "last_name" => "roberts",
                                             "email"=>"test_email@mail.com",
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
                                                                        "instructions" => "wear cruddy shoes"},
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
                                             "zipcode" => nil, "birthday" => nil,
                                             "privileges" => { "caching_action" => "respect",
                                                               "ordering_action" => "send",
                                                               "send_emails" => true,
                                                               "see_inactive_merchants" => false },
                                             "splickit_authentication_token" => "ASNDKASNDAS")
      end

      it "should call user's authenticate" do
        expect(User).to receive("authenticate").with(params)
        controller.sign_in(params)
      end
    end
  end
end
