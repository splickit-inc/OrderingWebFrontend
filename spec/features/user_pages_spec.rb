require 'support/feature_spec_helper'

describe "The user pages", js: true do
  context "skin does not have delivery" do
    it 'should not display delivery tab' do
      no_delivery_skin = {
        "http_code" => 200,
        "stamp" => "tweb03-i-027c8323-P8X8X57",
        "data" => {
          "skin_id" => "13",
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
          "facebook_thumbnail_url" => "https://s3.amazonaws.com/splickit-mobile-assets/com.splickit.pitapit/icon_store.png",
          "android_marketplace_link" => "https://play.google.com/store/apps/details?id=com.splickit.pitapit&hl=en",
          "twitter_handle" => "PitaPitUSA",
          "iphone_certificate_file_name" => "com.splickit.pitapit.pem",
          "current_iphone_version" => "3.0.0",
          "current_android_version" => "3.1",
          "facebook_app_id" => "",
          "facebook_app_secret" => "",
          "rules_info" => "<p>Some rules.</p>",
          "supports_history" => "1",
          "supports_join" => "1",
          "supports_link_card" => "1",
          "loyalty_features" => {
            "supports_history" => true,
            "supports_join" => true, "supports_link_card" => true
          },
          "merchants_with_delivery" => false,
          "loyalty_tnc_url" => "http://www.google.com",
        "http_code" => 200},
        "message" => nil
      }.to_json
      stub_request(:any, /.*apiv2\/skins\/com.splickit.[^p]*$/).to_return(
        :body => no_delivery_skin
      )
      visit root_path

      feature_sign_in

      page.find('header a.user').click
      menu = page.find 'body > div.user'
      expect(menu).to have_content "Account"
      expect(menu).to have_content "Payment method"
      expect(menu).to have_content "History"
      expect(menu).not_to have_content "Delivery address"

      visit new_user_payment_path

      expect(page).not_to have_link "Delivery"

      visit account_user_path

      expect(page).not_to have_link "Delivery"
    end
  end

  it "display the user menu", js: true do
    visit root_path

    feature_sign_in

    page.find('header a.user').click
    menu = page.find 'body > div.user'
    expect(menu).to have_content "Account"
    expect(menu).to have_content "Payment method"
    expect(menu).to have_content "Delivery address"
    expect(menu).to have_content "History"
    expect(menu).to have_content "Sign out"
  end

  describe "delivery address page", js: true do
    before(:each) do
      visit root_path

      feature_sign_in

      click_link("bob")
      click_link("Delivery address")
    end

    context "add valid address" do
      before(:each) do
        stub_request(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }/app2/phone/setuserdelivery").
          with(
            :body => user_address_params.to_json).
          to_return(
            :status => 200,
            :body => set_user_address_response.to_json)
      end

      it "results in success" do
        ## add valid address info ##
        fill_in("Business Name", with: "")
        fill_in("Street address", with: "Fortune and Glory Ln.")
        fill_in("Suite / Apt", with: "101")
        fill_in("City", with: "Shanghai")
        fill_in("State", with: "UT")
        fill_in("Zip", with: "80123")
        fill_in("Phone number", with: "123-123-1234")
        fill_in("The doorbell is broken; please knock.", with: "Don't mind the sock.")

        click_button("Add delivery address")

        ## verify page content ##

        expect(page).to have_content "Address successfully added!"
      end
    end

    context "business name with data" do
      before do
        stub_request(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }/app2/phone/setuserdelivery").
          with(:body => user_address_params_business_name_with_value.to_json).to_return(:status => 200, :body => set_user_address_response_with_business_name.to_json)
      end

      it "results in success for business name with data" do
        ## add valid address info ##
        fill_in("Business Name", with: "Tests Corporation")
        fill_in("Street address", with: "Fortune and Glory Ln.")
        fill_in("Suite / Apt", with: "101")
        fill_in("City", with: "Boulder")
        fill_in("State", with: "St")
        fill_in("Zip", with: "80302")
        fill_in("Phone number", with: "123-123-1234")
        fill_in("The doorbell is broken; please knock.", with: "Don't mind the sock.")
        click_button("Add delivery address")
        ## verify page content ##
        expect(page).to have_content "Address successfully added!"
      end
    end

    context "add invalid address" do
      before(:each) do
        stub_request(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }/app2/phone/setuserdelivery").
          with(
            :body => "{\"business_name\":\"\",\"address1\":\"Fortune and Glory Ln.\",\"address2\":\"101\",\"city\":\"Shanghai\",\"state\":\"UT\",\"zip\":\"80123\",\"phone_no\":\"123-123-1234\",\"instructions\":\"Mind the sock.\"}").
          to_return(
            :status => 200,
            :body => set_user_address_response_invalid.to_json)
      end

      it "results in failure" do
        ## add address info ##
        fill_in("Business Name", with: "")
        fill_in("Street address", with: "Fortune and Glory Ln.")
        fill_in("Suite / Apt", with: "101")
        fill_in("City", with: "Shanghai")
        fill_in("State", with: "UT")
        fill_in("Zip", with: "80123")
        fill_in("Phone number", with: "123-123-1234")
        fill_in("The doorbell is broken; please knock.", with: "Mind the sock.")

        click_button("Add delivery address")

        ## verify error message ##

        expect(page).to have_content "address cannot be null"

        ## verify form data preserved ##

        expect(page).to have_selector("input[value='Fortune and Glory Ln.']")
        expect(page).to have_selector("input[value='101']")
        expect(page).to have_selector("input[value='Shanghai']")
        expect(page).to have_selector("input[value='UT']")
        expect(page).to have_selector("input[value='80123']")
        expect(page).to have_selector("input[value='123-123-1234']")
        expect(page).to have_selector("input[value='Mind the sock.']")
      end
    end

    context "delete delivery address" do
      it "delete buttons" do
        expect(page).to have_selector "#addresses article .delete-address", count:2
      end

      it "when user click in delete button and success delete" do
        stubs_delivery_address_success("ASNDKASNDAS", "2", "5667")
        page.all("#addresses article .delete-address").first.click

        verify_delete_conf_dialog

        page.find("div[data-dialog-footer] button.btn-delete-usr-addr.primary").click

        expect(page).to have_content "Address successfully deleted!"
      end

      it "when user click in delete button and failed delete" do
        stubs_delivery_address_failure("ASNDKASNDAS", "2", "5667")
        page.all("#addresses article .delete-address").first.click

        verify_delete_conf_dialog

        page.find("div[data-dialog-footer] button.btn-delete-usr-addr.primary").click

        expect(page).to have_content "could not locate the user delivery record"
      end

      it "should close delivery delete confirmation modal" do
        page.all("#addresses article .delete-address").first.click

        verify_delete_conf_dialog

        #Delivery dialog No Button
        within("#delivery-address") do
          page.find("div[data-dialog-footer] a.btn-delete-usr-addr.secondary").click
        end

        expect(page).not_to have_selector("#delivery-address")
      end
    end
  end

  describe "user/payment" do
    before do
      stub_request(:get, "http://admin:welcome@test.splickit.com/app2/apiv2/users/credit_card/getviowritecredentials").
        to_return(:status => 200, :body => '{"http_code":200,"stamp":"tweb03-i-027c8323-68M17S6","data":{"vio_write_credentials":"splikit:vio-token"},"message":null}')
    end

    it 'should allow a user to submit their cc information' do
      stub_request(:post, "http://splickit_authentication_token:ASNDKASNDAS@test.splickit.com/app2/apiv2/users/2").
        with(:body => "{\"credit_card_saved_in_vault\":false,\"credit_card_token_single_use\":\"vio-token\"}").
        to_return(:status => 200, :body => "{\"data\":{\"first_name\":\"robert\",\"last_name\":\"roberts\",\"email\":\"bob@roberts.com\",\"contact_no\":\"4442221111\",\"password\":\"\"}}", :headers => {})

      visit root_path

      feature_sign_in

      visit new_user_payment_path
      expect(page).to have_content "Payment information"
      expect(page).to have_content "New payment method"
      expect(page).to have_button "Replace card"

      ## USER ENTERS INFO INTO VIO FORM ##
      ## NOT TESTED AS IT IS THIRD PARTY INTEGRATION ##
      ## VIO FORM WILL SUBMIT TOKEN TO OUR CONTROLLER ##

      click_button("Replace card")

      expect(page).to have_content "Your card was successfully updated."
    end

    context "delete credit card" do
      before(:each) do
        visit root_path
        feature_sign_in
        delete_credit_card_stub
        visit new_user_payment_path
      end

      it "should delete card and show a success delete message" do
        expect(page).to have_button "Delete Card"
        click_button("Delete Card")
        first('button.modal-btn-delete-credit-card-yes').click
        expect(page).to have_content "Your credit card has been deleted."
      end
    end
  end

  describe "account page", js: true do
    before(:each) do
      visit root_path

      feature_sign_in

      click_link("bob")
      click_link("Account")
    end

    it 'should display user info and allow updates' do
      updated_user_json = "{\"delivery_locations\":[{\"user_addr_id\":\"202402\" ,\"user_id\":\"2\",\"name\":\"Metro Wastewater Reclamation Plant\",\"address1\":\"6450 York St\",\"address2\":\"Basement\",\"city\":\"Denver\",\"state\":\"CO\",\"zip\":\"80229\",\"lat\":\"39.8149386187446\",\"lng\":\"-104.956209155655\",\"phone_no\":\"(303) 286-3000\",\"instructions\":\"wear cruddy shoes\"}, {\"user_addr_id\":\"202403\",\"user_id\":\"1449579\",\"name\":\"\",\"address1\":\"555 5th st \",\"address2\":\"\",\"city\":\"Boulder\",\"state\":\"CT\",\"zip\":\"06001\",\"lat\":\"33.813101\",\"lng\":\"-111.917054\",\"phone_no\":\"5555555555\",\"instructions\":\"I answer naked\"}], \"last_four\": \"9861\", \"flags\":\"1C21000001\", \"user_id\":\"2\", \"first_name\":\"robert\", \"last_name\":\"roberts\", \"email\":\"bob@roberts.com\", \"contact_no\":\"4442221111\", \"splickit_authentication_token\":\"ASNDKASNDAS\"}"
      updated_response = "{\"http_code\":\"200\",\"stamp\":\"tweb03-i-027c8323-FY6FPUS\",\"data\":#{updated_user_json}}"
      stub_request(:post, "http://splickit_authentication_token:ASNDKASNDAS@test.splickit.com/app2/apiv2/users/2").
        with(:body => "{\"first_name\":\"robert\",\"last_name\":\"roberts\",\"email\":\"bob@roberts.com\",\"contact_no\":\"4442221111\"}").
        to_return(:status => 200, :body => updated_response, :headers => {})

      within 'form' do
        expect(page).to have_content('Contact information')
        expect(page).to have_content('Password')
      end

      expect(page.find('#user_first_name').value).to eq('bob')
      expect(page.find('#user_last_name').value).to eq('roberts')
      expect(page.find('#user_email').value).to eq('bob@roberts.com')
      expect(page.find('#user_contact_no').value).to eq('4442221111')
      expect(page.find('#user_password').value).to eq("")
      expect(page.find('#user_password_confirmation').value).to eq("")

      fill_in('user_first_name', with: "robert")

      click_button 'Save information'

      expect(page).to have_content("Your account was successfully updated.")
    end
  end

  it "redirect to the sign in page when attempting to access signed in specific content" do
    visit account_user_path
    expect(current_path).to eq sign_in_path
    visit new_user_payment_path
    expect(current_path).to eq sign_in_path
    visit user_address_index_path
    expect(current_path).to eq sign_in_path
  end

  describe "order's history page success with orders", js: true do
    let(:api_response) { {
      favorite_id: 85472,
      favorite_name: "Sofa King",
      user_message: "Your favorite was successfully stored."
    } }

    context "standard functionality" do
      before(:each) do
        stub_request(:get, "http://splickit_authentication_token:ASNDKASNDAS@test.splickit.com/app2/apiv2/users/2/orderhistory?page=1")
          .to_return(:status => 200, :body => { data: get_user_orders_json }.to_json, :headers => {})

        stub_request(:get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2/orderhistory?page=2")
          .to_return(:status => 200, :body => { data: get_user_orders_json_2 }.to_json, :headers => {})

        allow(API).to receive_message_chain(:post, :status) { 200 }
        allow(API).to receive_message_chain(:post, :body) { {data: api_response}.to_json }

        visit root_path

        feature_sign_in

        click_link("bob")
        click_link("History")
      end

      it "should display tab menu" do
        tab_menu = page.find("main ul[data-tabs]")
        expect(tab_menu).to have_selector "li", count: 4
        tab_menu.all("li").each do |li|
          expect(li).to have_selector "a", count: 1
        end
        expect(tab_menu.find("li:nth-of-type(1)")).to have_content "Account"
        expect(tab_menu.find("li:nth-of-type(2)")).to have_content "Payment method"
        expect(tab_menu.find("li:nth-of-type(3)")).to have_content "Delivery address"
        expect(tab_menu.find("li:nth-of-type(4)")).to have_content "History"
      end

      it "should display order's history table" do
        table = page.find("div#order-data table")
        expect(table).to have_selector "tr", count: get_user_orders_json["orders"].count + 1
        expect(table).to have_selector "button", count: get_user_orders_json["orders"].count
        table.all("button").each do |button|
          expect(button).to have_content "Add to favorites"
        end
      end

      it "should display dialog using row's button" do
        order = get_user_orders_json["orders"].first
        table_row = page.all("div#order-data table tbody tr").first
        table_row.find("button").click
        dialog = page.find("form#new_user_favorite")
        expect(dialog).to have_selector("input#user_favorite_order_id", visible: false)
        expect(dialog.find("input#user_favorite_order_id", visible: false).value).to eq(order["order_id"])
        expect(dialog).to have_selector("input#user_favorite_favorite_name")
        expect(dialog).to have_selector("button.set-btn.primary-btn")
        expect(dialog).to have_content("Add to favorites")
      end

      it "should display order's summary using row's hover click" do
        order = get_user_orders_json["orders"].first
        table_row = page.all("div#order-data table tbody tr td:not(.add-favorite-button)").first
        table_row.click
        dialog = page.find("div#order-summary")
        expect(dialog).to have_selector(" div.order-summary section#summary")
        expect(dialog).to have_selector("form.new_user_favorite")
        expect(dialog).to have_selector("div.order-summary table#items tr", count: 1)
        expect(dialog).to have_selector("table#amounts tr#subtotal")
        expect(dialog).to have_selector("table#amounts tr#tax")
        expect(dialog).to have_selector("table#amounts tr#tip")
        expect(dialog).to have_selector("div.add-favorite-summary")
        expect(dialog.find("input#user_favorite_order_id", visible: false).value).to eq(order["order_id"])
      end

      it "should create favorite using order's summary dialog" do
        table_row = page.all("div#order-data table tbody tr td:not(.add-favorite-button)").first
        table_row.click
        dialog = page.find("div#order-summary")
        fill_in "Add order to favorites", with: "test2"
        dialog.find("button").click
        expect(page).to have_content "Your favorite was successfully stored."
      end

      it "should create favorite using add-favorite dialog" do
        table_row = page.all("div#order-data table tbody tr").first
        table_row.find("button").click
        dialog = page.find("form#new_user_favorite")
        fill_in "user_favorite_favorite_name", with: "test2"
        dialog.find("button").click
        expect(page).to have_content "Your favorite was successfully stored."
      end

      it "should display Please name your favorite" do
        table_row = page.all("div#order-data table tbody tr").first
        table_row.find("button").click
        dialog = page.find("form#new_user_favorite")
        fill_in "user_favorite_favorite_name", with: ""
        dialog.find("button").click
        expect(page).to have_content "Please name your favorite"
      end
    end

    context "orders history No Orders" do
      before do
        stub_request(:get, "http://splickit_authentication_token:ASNDKASNDAS@test.splickit.com/app2/apiv2/users/2/orderhistory?page=1")
          .to_return(:status => 200, :body => { data: { orders: [], totalOrders: 0 } }.to_json, :headers => {})
        visit root_path

        feature_sign_in

        click_link("bob")
        click_link("History")
      end

      it "should display message when no orders are available" do
        expect(page).to have_content("No orders available")
      end
    end

    context "orders history API Error" do
      before do
        stub_request(:get, "http://splickit_authentication_token:ASNDKASNDAS@test.splickit.com/app2/apiv2/users/2/orderhistory?page=1")
          .to_return(:status => 200, :body => { error: { error: "barf" } }.to_json, :headers => {})
        visit root_path

        feature_sign_in

        click_link("bob")
        click_link("History")
      end

      it "should redirect and display a flash message when there is an API error" do
        expect(page).to have_content("barf")
      end
    end
  end
end
