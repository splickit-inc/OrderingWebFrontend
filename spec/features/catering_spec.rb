require "support/feature_spec_helper"

describe "Catering", js: true do
  let!(:user_data) {get_user_data}

  let(:menu_data) {get_default_menu}
  let(:menu) {menu_data[:menu]}
  let(:modifier_item_1) {menu_data[:modifier_item_1]}

  let(:merchant) do
    merchant = Merchant.new
    merchant.merchant_id = "102237"
    merchant.name = "Coeur d'Restaurant"
    merchant.display_name = "Coeur d'Alene"
    merchant.address1 = "320 Sherman Ave"
    merchant.city = "Coeur d'Alene"
    merchant.state = "83814"
    merchant.delivery = "Y"
    merchant.has_catering = "1"
    merchant.show_tip = true
    merchant.menu = menu

    merchant
  end

  before do
    merchants = get_default_merchant_list
    merchants.first.merge!(has_catering: "1", delivery: "Y")
    merchants[1].merge!(has_catering: "1", group_ordering_on: "1", force_catering: "1")

    merchant_where_stub(params: {location: "83814"},
                        auth_token: user_data["splickit_authentication_token"],
                        return: {merchants: [merchant.as_json(root: false)].concat(merchants),
                                 promos: []})

    merchant_find_stub(merchant_id: merchant.merchant_id,
                       catering: true,
                       auth_token: user_data["splickit_authentication_token"],
                       return: merchant.as_json(root: false))

    merchant_find_stub(merchant_id: merchant.merchant_id,
                       auth_token: user_data["splickit_authentication_token"],
                       return: merchant.as_json(root: false))

    visit merchants_path

    feature_sign_in(email: "mr@bean.com", password: "password", user_return: user_data)
  end

  shared_examples "catering new page" do
    it "should render page elements" do
      # should render form elements
      within "form" do
        expect(page).to have_content("Number of People")

        ## Waiting for long term catering orders
        # expect(page).to have_content("Date of Event")

        expect(page).to have_content("Date of Event")
        expect(page).to have_content("Time of Event")
        expect(page).to have_content("Contact Info")
        expect(page).to have_content("Notes")

        # Default values
        expect(page).to have_field('catering[number_of_people]', with: "1")
      end

      expect(page).to have_css("#new_catering_submit")
      expect(find("#new_catering_submit").value).to eq("Continue to Menu")


      # should render delivery data elements
      within "section.delivery-data" do
        within "div.minimum-amount" do
          expect(page).to have_content("Delivery Minimum")
          expect(page).to have_content("Pickup Minimum")
        end

        within ".location" do
          expect(page).to have_content("Selected Location:")
          expect(page).to have_content("320 Sherman Ave")
          expect(page).to have_content("Coeur d'Alene, 83814")
        end

        within ".map" do
          expect(page).to have_css("img")
          expect(page).to have_css("a", text: "Change Location")
        end
      end

      # should verify number of people
      # with blank form
      within "form" do
        fill_in "Number of People", with: ""
      end

      find("input#new_catering_submit").click

      expect(page).to have_content("Number of People should be between 1 and 9999")

      click_button("OK")

      #with no valid number of people
      within "form" do
        fill_in "Number of People", with: "-100"
      end

      find("input#new_catering_submit").click

      expect(page).to have_content("Number of People should be between 1 and 9999")

      click_button("OK")

      # should verify date of event
      within "form" do
        fill_in "Number of People", with: "1"
        fill_in "catering[contact_phone]", with: ""
        mockup_valid_select_time
      end

      ## Waiting for long term catering orders

      # with blank form
      # find("input#new_catering_submit").click
      #
      # expect(page).to have_content("Date should be after today's date")
      #
      # click_button("OK")

      #with no valid number of people

      # within "form" do
      #   fill_in "Date of Event", with: "11/08/2016"
      # end

      # find("input#new_catering_submit").click
      #
      # expect(page).to have_content("Date should be after today's date")
      #
      # click_button("OK")
      #
      # tomorrow = (DateTime.now + 1.day).strftime("%m/%d/%Y")

      # should verify contact phone
      # within "form" do
      #   fill_in "Date of Event", with: tomorrow
      # end

      # with blank form
      find("input#new_catering_submit").click

      expect(page).to have_content("Phone should have 10 digits")

      click_button("OK")

      # without a valid phone number
      within "form" do
        fill_in "catering[contact_phone]", with: "555-555-55551"
      end

      find("input#new_catering_submit").click

      expect(page).to have_content("Phone should have 10 digits")

      click_button("OK")

      # should change location redirect to root path
      find(".map a").click
      expect(URI.parse(current_url).request_uri).to include(root_path)
    end
  end

  shared_examples "catering menu redirects" do
    it "should redirect to catering menu page from my order" do
      first("a.home").click

      first("a.my-order-link").click

      expect(URI.parse(current_url).request_uri).to eq("/merchants/102237?order_type=#{ order_type }&catering=1&my_order=1")
    end

    it "should redirect to new page if there is an active order with different merchant" do
      first("a.home").click

      find("#results > div:nth-child(4) > aside:nth-child(2) > figure:nth-child(1) > div:nth-child(1) > a:nth-child(1)").click

      click_link("Go")

      expect(URI.parse(current_url).request_uri).to include(caterings_begin_path(merchant_id: "4000"))
    end
  end

  context "force catering with group order" do
    before do
      merchant_catering_data_stub(auth_token: user_data["splickit_authentication_token"],
                                  merchant_id: merchant.merchant_id)

      fill_in("location", with: "83814")
      click_button("Search")
    end

    it "should disable catering button on check group order" do
      expect(find("input.checkbox-group-order[data-merchant-id='103893']", visible: false)).to be_disabled
      find(:xpath, "//input[@class='checkbox-group-order'][@value='4000']/..").click
      find("a.catering.button[data-merchant-id='4000']")[:disabled].should eq "true"
    end
  end

  context "Pickup" do
    let(:order_type) {"pickup"}

    before do
      merchant_catering_data_stub(auth_token: user_data["splickit_authentication_token"],
                                  merchant_id: merchant.merchant_id)

      fill_in("location", with: "83814")
      click_button("Search")
    end

    it "should redirect to catering begin page with pickup parameters" do
      expect(page).to have_selector(".catering.button")
      first(".catering.button").click
      expect(URI.parse(current_url).request_uri).to include(caterings_begin_path(merchant_id: "102237"))
    end

    describe "new" do
      before do
        expect(page).to have_selector(".catering.button")
        first(".catering.button").click
        first(".pickup.button").click
      end

      it_behaves_like "catering new page"

      it "should create an order and redirect to menu" do
        catering_create_stub(body: {number_of_people: "1",
                                    timestamp_of_event: "1483992000",
                                    contact_name: "bob roberts",
                                    contact_phone: "555-555-5555",
                                    notes: "",
                                    merchant_id: "102237"},
                             auth_token: "ASNDKASNDAS")

        tomorrow = (DateTime.now + 1.day).strftime("%m/%d/%Y")

        within "form" do
          fill_in "Number of People", with: "1"
          page.execute_script("$('#catering_date').datepicker('setDate', '" + tomorrow + "')")
          ## Waiting for long term catering orders
          # fill_in "Date of Event", with: tomorrow
          mockup_valid_select_time

          fill_in "catering[contact_phone]", with: "555-555-5555"
        end

        find("input#new_catering_submit").click

        expect(URI.parse(current_url).request_uri).to include(merchant_path("102237", order_type: "pickup", catering: "1"))
      end

      describe "menu 1 item" do
        before do
          catering_create_stub(body: {number_of_people: "1",
                                      timestamp_of_event: "1483992000",
                                      contact_name: "bob roberts",
                                      contact_phone: "555-555-5555",
                                      notes: "",
                                      merchant_id: "102237"},
                               auth_token: "ASNDKASNDAS")
          tomorrow = (DateTime.now + 1.day).strftime("%m/%d/%Y")

          within "form" do
            fill_in "Number of People", with: "1"
            page.execute_script("$('#catering_date').datepicker('setDate', '" + tomorrow + "')")
            ## Waiting for long term catering orders
            # fill_in "Date of Event", with: tomorrow
            mockup_valid_select_time
            fill_in "catering[contact_phone]", with: "555-555-5555"
          end

          find("input#new_catering_submit").click

          # Catering menu page
          first("article").click
          first("button.add.cash").click
        end

        it_behaves_like "catering menu redirects"

        it "should not appear reload modal" do
          cart_checkout_stub(cart_id: "4076-1de8d-57dbc-lar86",
                             body: {merchant_id: "102237",
                                    items: [{item_id: 931,
                                             quantity: 1,
                                             mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                     mod_quantity: 1,
                                                     name: "Spicy Club Sauce"}],
                                             size_id: "3",
                                             order_detail_id: nil,
                                             external_detail_id: anything,
                                             status: "new",
                                             points_used: nil,
                                             brand_points_id: nil,
                                             note: ""}]})

          first(".my-order-link").click
          click_button("Checkout")

          sleep 120

          expect(page).not_to have_content("Lead Times Expired")
          expect(page).not_to have_content("Your pick up / delivery times are no longer valid due to inactivity. Please press here to refresh the options")
        end
      end
    end
  end

  context "Delivery" do
    let(:order_type) {"delivery"}

    before do
      merchant_indeliveryarea_stub(merchant_id: merchant.merchant_id,
                                   auth_token: user_data["splickit_authentication_token"],
                                   delivery_address_id: "5667",
                                   return: {is_in_delivery_range: true}, message: nil,
                                   catering: true)

      feature_sign_out
      feature_sign_in(user_return: get_user_data_with_business_name)

      merchant_catering_data_stub(auth_token: user_data["splickit_authentication_token"],
                                  merchant_id: merchant.merchant_id,
                                  order_type: "delivery")
      merchant_catering_data_stub(auth_token: user_data["splickit_authentication_token"],
                                  merchant_id: merchant.merchant_id)

      fill_in "location", with: "83814"
      click_button "Search"

      expect(page).to have_selector(".catering.button")
      first(".catering.button").click
      first(".delivery.button").click
      find(".set-btn").click
    end

    describe "should show the delivery address dialog" do
      it "should change the delivery address" do
        expect(page).to have_content "Change delivery address"
        expect(page).to have_content "Delivery Address"
        expect(page).to have_content "Delivery to"

        click_link("Change delivery address")
        expect(page).to have_content "Choose a delivery address"
        expect(page).to have_selector("#select-address")

        #when address is inside the delivery range
        within("#select-address") do
          find(".set-btn").click
          expect(URI.parse(current_url).request_uri).to include(caterings_begin_path(merchant_id: "102237",
                                                                                     order_type: "delivery",
                                                                                     user_addr_id: "5667"))
        end

        # Selenium specific code.
        browser = Capybara.current_session.driver.browser.manage
        expect(browser.cookie_named('userPrefs')[:value]).to eq("%7B%22preferredAddressId%22%3A%225667%22%7D")
      end

      it "should redirect to menu with order type delivery" do
        catering_create_stub(body: {number_of_people: "1",
                                    timestamp_of_event: "1483992000",
                                    contact_name: "bob roberts",
                                    contact_phone: "555-555-5555",
                                    notes: "",
                                    merchant_id: "102237",
                                    user_addr_id: "5667"},
                             auth_token: "ASNDKASNDAS")

        tomorrow = (DateTime.now + 1.day).strftime("%m/%d/%Y")

        within "form" do
          fill_in "Number of People", with: "1"
          page.execute_script("$('#catering_date').datepicker('setDate', '" + tomorrow + "')")
          ## Waiting for long term catering orders
          # fill_in "Date of Event", with: tomorrow
          mockup_valid_select_time
          fill_in "catering[contact_phone]", with: "555-555-5555"
        end

        find("input#new_catering_submit").click

        expect(URI.parse(current_url).request_uri).to include(merchant_path("102237", order_type: "delivery", catering: "1"))
      end

      describe "menu 1 item" do
        before do
          catering_create_stub(body: {number_of_people: "1",
                                      timestamp_of_event: "1483992000",
                                      contact_name: "bob roberts",
                                      contact_phone: "555-555-5555",
                                      notes: "",
                                      merchant_id: "102237",
                                      user_addr_id: "5667"},
                               auth_token: "ASNDKASNDAS")
          tomorrow = (DateTime.now + 1.day).strftime("%m/%d/%Y")

          within "form" do
            fill_in "Number of People", with: "1"
            page.execute_script("$('#catering_date').datepicker('setDate', '" + tomorrow + "')")
            ## Waiting for long term catering orders
            # fill_in "Date of Event", with: tomorrow
            mockup_valid_select_time
            fill_in "catering[contact_phone]", with: "555-555-5555"
          end

          find("input#new_catering_submit").click

          # Catering menu page
          first("article").click
          first("button.add.cash").click
        end

        it_behaves_like "catering menu redirects"
      end
    end
  end
end
