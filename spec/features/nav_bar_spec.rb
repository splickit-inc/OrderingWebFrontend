require 'support/feature_spec_helper'

describe 'nav bar', js: true do
  let(:menu_data) { get_default_menu }
  let(:menu) { menu_data[:menu] }

  it 'should display correct information when a user signs in' do
    visit root_path
    expect(page).to have_content "MY ORDER"
    expect(page).to have_content 'SIGN UP'
    expect(page).to have_content 'SIGN IN'
    expect(page).to have_selector 'a.logo[href="/"]'
    expect(page).to have_no_selector("#sign-in")
    expect(page).to have_no_selector("#sign-up")
    expect(page).not_to have_content "SIGN OUT"

    feature_sign_in

    expect(page).to have_content "MY ORDER"
    expect(page).to have_content "HOME"
    expect(page).to have_content "LOYALTY"
    expect(page).to have_content 'BOB'
    expect(page).to have_selector 'a.logo[href="/"]'
    expect(page).not_to have_content 'SIGN UP'
    expect(page).not_to have_content 'SIGN IN'

    page.find(".user").click
    expect(page).to have_content "bob@roberts.com"
    expect(page).to have_content "Account"
    expect(page).to have_content "Delivery address"
    expect(page).to have_content "Sign out"
  end

  it 'should display points when a loyal user is signed in' do
    visit root_path

    feature_sign_in(user_return: get_loyal_user_data)

    expect(page).not_to have_content "LOYALTY"
    expect(page).to have_content "500 POINTS"
  end

  context "small devices" do
    before do
      page.driver.browser.manage.window.resize_to 400, 700
      visit root_path
    end

    after do
      reset_browser_window_size
    end

    it "displays the sign in and sign up links when the small screen menu icon is clicked" do
      page.execute_script "$('header div.user').trigger('click')"
      expect(page).to have_content "SIGN IN"
      expect(page).to have_content "SIGN UP"

      feature_sign_in

      page.execute_script "$('header div.user').trigger('click')"
      expect(page).to have_content "MY ORDER"
      expect(page).to have_content "LOYALTY"
      expect(page).to have_content "ACCOUNT"
      expect(page).to have_content "DELIVERY ADDRESS"
      expect(page).to have_content "HISTORY"
      expect(page).to have_content "SIGN OUT"
    end

    describe "Keep the header size when user scroll down" do
      it "the min height of header should be 90px" do
        header_min_height = page.evaluate_script("jQuery('header').css('min-height')")
        expect(header_min_height).to eq("90px")
      end

      it "should be keep header height in 90px when scroll down" do
        page.execute_script "window.scrollBy(0,700)"
        header_min_height_after_scroll =  page.evaluate_script("jQuery('header').css('min-height')")
        expect(header_min_height_after_scroll).to eq("90px")
      end
    end
  end

  describe "MY ORDER link" do
    describe "normal order" do
      before do
        visit merchants_path

        ## Merchant Search
        merchant_where_stub({ params: { location: "80305" } })
        merchant_find_stub({ return: { menu: menu } })
        fill_in("location", with: "80305")
        click_button("Search")
        first(".pickup.button").click

        first("article.item").click
        first("button.add").click
      end

      describe "merchant list page" do
        before do
          find("a.logo").click
        end

        it "should redirect to last merchant when MY ORDER link had been clicked" do
          find("a.my-order-link").click
          expect(URI.parse(current_url).request_uri).to eq("/merchants/4000?order_type=pickup&my_order=1")
        end

        it "should open MY ORDER modal automatically after the redirect" do
          find("a.my-order-link").click
          expect(URI.parse(current_url).request_uri).to eq("/merchants/4000?order_type=pickup&my_order=1")
          verify_my_order_modal
        end
      end

      describe "merchant menu page" do
        it "should open MY ORDER modal had been clicked" do
          find("a.my-order-link").click
          verify_my_order_modal
        end
      end
    end

    describe "group order" do
      before do
        visit merchants_path

        feature_sign_in

        ## Merchant Search
        merchant_where_stub({ params: { location: "80305" }, auth_token: "ASNDKASNDAS" })
        merchant_find_stub({ auth_token: "ASNDKASNDAS", return: { menu: menu } })
        fill_in("location", with: "80305")
        click_button("Search")

        find(:xpath, "//input[@class='checkbox-group-order'][@value='4000']/..").click
        first(".pickup.button").click

        ## Group Order new
        group_order_create_stub(auth_token: "ASNDKASNDAS",
                                body: { merchant_id: "4000",
                                        merchant_menu_type: "pickup" },
                                return: { merchant_id: "4000",
                                          merchant_menu_type: "pickup",
                                          admin_user_id: "2" })
        group_order_find_stub(auth_token: "ASNDKASNDAS",
                              return: { merchant_id: "4000",
                                        merchant_menu_type: "pickup",
                                        group_order_admin: { first_name: "bob",
                                                             last_name: "roberts",
                                                             email: "bob@roberts.com",
                                                             admin_uuid: "1195-vdi97-q2kug-38j07" } })



        click_button("Send")

        group_order_find_stub(auth_token: { email: "admin",
                                            password: "welcome" },
                              return: { merchant_id: "4000",
                                        merchant_menu_type: "pickup",
                                        group_order_admin: { first_name: "bob",
                                                             last_name: "roberts",
                                                             email: "bob@roberts.com",
                                                             admin_uuid: "1195-vdi97-q2kug-38j07" } })
        ## Group Order show
        find("a#add").click

        ## Merchant show
        first("article.item").click
        first("button.add").click
      end

      describe "merchant list page" do
        before do
          find("a.home").click
        end

        it "should redirect to last merchant when MY ORDER link had been clicked" do
          find("a.my-order-link").click
          expect(URI.parse(current_url).request_uri)
            .to eq("/merchants/4000?order_type=pickup&group_order_token=9109-nyw5d-g8225-irawz&my_order=1")
        end

        it "should open MY ORDER modal automatically after the redirect" do
          find("a.my-order-link").click
          expect(URI.parse(current_url).request_uri)
            .to eq("/merchants/4000?order_type=pickup&group_order_token=9109-nyw5d-g8225-irawz&my_order=1")
          verify_my_order_modal(true)
        end
      end

      describe "merchant menu page" do
        it "should open MY ORDER modal had been clicked" do
          find("a.my-order-link").click
          verify_my_order_modal(true)
        end
      end
    end
  end

  def verify_my_order_modal(group_order = false)
    within "#my-order" do
      title = find("h1")
      if group_order
        expect(page).to have_css("button.submit-order", text: "Submit to Group Order")
        expect(title.text).to eq("My group order")
      else
        add_button = find("a.add-more")
        expect(page).to have_css("button.checkout", text: "Checkout")
        expect(add_button.text).to eq("Add more items")
        expect(title.text).to eq("My order")
      end
    end
  end

  describe "merchant readable hours" do
    before do
      visit merchants_path
      feature_sign_in

      ## Merchant Search
      merchant_where_stub({params: {location: "80305"}, auth_token: "ASNDKASNDAS"})
      merchant_find_stub({ auth_token: "ASNDKASNDAS", return: { menu: menu } })
    end

    context "pickup store hours" do
      it "should contain the pickup store hours only" do
        fill_in("location", with: "80305")
        click_button("Search")
        first(".pickup.button").click
        expect(page).to have_selector("#store_hours_container", visible: false)
        page.execute_script "$('div#icon_to_show_store_hours').trigger('click')"
        expect(page).to have_selector("#store_hours_container", visible: true)
        expect(page).to have_content("Sunday 11:00am-8:00pm")
        expect(page).to have_content("Monday 11:00am-9:00pm")
        expect(page).to have_content("Tuesday closed")
        expect(page).to have_content("Wednesday closed")
        expect(page).to have_content("Thursday 11:00am-9:00pm")
        expect(page).to have_content("Friday 11:00am-9:00pm")
        expect(page).to have_content("Saturday 11:00am-9:00pm")
        page.execute_script "$('div#icon_to_show_store_hours').trigger('click')"
        expect(page).to have_selector("#store_hours_container", visible: false)
      end
    end

    context "Delivery store hours" do
      before do
        merchant_find_stub(auth_token: "ASNDKASNDAS", return: { delivery: "Y" })
      end

      it "Should contain the pickup and delivery store hours" do
        fill_in("location", with: "80305")
        click_button("Search")
        first(".pickup.button").click
        expect(page).to have_selector("#store_hours_container", visible: false)
        page.execute_script "$('div#icon_to_show_store_hours').trigger('click')"
        expect(page).to have_selector("#store_hours_container", visible: true)
        expect(page).to have_content("Pickup")
        expect(page).to have_content("Delivery")
        expect(page).to have_content("Sunday")
        expect(page).to have_content("Monday")
        expect(page).to have_content("Tuesday")
        expect(page).to have_content("Wednesday")
        expect(page).to have_content("Thursday")
        expect(page).to have_content("Friday")
        expect(page).to have_content("Saturday")
        page.execute_script "$('div#icon_to_show_store_hours').trigger('click')"
        expect(page).to have_selector("#store_hours_container", visible: false)
      end
    end
  end
end
