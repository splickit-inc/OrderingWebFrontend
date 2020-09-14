require 'support/feature_spec_helper'

describe "the merchant search page", js: true do
  let(:merchant) { create_merchant("merchant_id"=> "100030") }

  before(:each) do
    page.driver.browser.manage.window.resize_to 1400, 768
    visit merchants_path
  end

  context "geo located" do
    it "displays the search form" do
      expect(page).not_to have_text "Please enter a valid zip code."
    end

    it "does not display any results" do
      expect(page).to have_text "found near"
    end
  end

  context "not geo located" do
    before do
      reset_browser_cookies
      allow(GeoIPService).to receive("find").and_return(nil)
    end

    it "displays the search form" do
      visit merchants_path
      expect(page).to have_text "Please enter a valid zip code."
    end

    it "does not display any results" do
      visit merchants_path
      expect(page).not_to have_text "found near"
    end

    it "should show alert when merchantlist param is empty" do
      visit merchants_path(merchantlist: "")
      expect(page).to have_selector("p#error.message", count: 1)
      expect(find("p#error.message span.message-body").text).to eq("Please enter a merchantlist param")
    end
  end

  it "displays the search form" do
    expect(page).to have_text "Find a nearby location"
  end

  it "displays the brand's name in the page title" do
    expect(page.title).to eq "Test"
  end

  it "should redirect to correct moved merchant" do
    merchant.moved_to_merchant_id = "1000"
    merchant_find_stub(merchant_id: "100030", return: merchant.as_json(root: false))

    first("a.pickup").click

    expect(URI.parse(current_url).request_uri).to eq(merchant_path(id: "1000", order_type: "pickup"))
  end

  def review_search_results
    expect(page).to have_text "1. Illegal Pete's, The Hill--Boulder"
    expect(page).to have_text "1320 College Ave, Boulder, CO 80305"

    expect(page).to have_text "2. Geisty's Dogg House, Boulder"
    expect(page).to have_text "1116 13th Street, Boulder, CO 80305"

    expect(page).to have_text "3. Flatiron Coffee, Boulder"
    expect(page).to have_text "2721 Arapahoe Avenue, Boulder, CO 80305"

    expect(page).to have_link "Delivery", count: 1
    expect(page).to have_link "Pickup", count: 3

    expect(page).to have_css "[href='/merchants/1106?order_type=pickup']", text: "Pickup"

    find(:xpath, "//input[@class='checkbox-group-order'][@value='1106']/..").click

    find("a[href='/merchants/1106?order_type=pickup']").click

    feature_sign_in(sign_in_selector: ".sign-in")

    expect(URI.parse(current_url).request_uri).to eq(new_group_orders_path(merchant_id: "1106", order_type: "pickup"))
  end

  context "search zip 80305" do
    before do
      stub_merchants_for_zip("80305")
      stub_merchants_for_zip("80305")
      fill_in "location", with: "80305"
      click_button "Search"
    end

    it "displays results when someone searches for a zip code" do
      review_search_results
    end
  end

  it "should not have search by location if location is present and merchantlist is blank" do
    stub_merchants_for_zip("80305")
    visit merchants_path(merchantlist: "", location: "80305")
    expect(page).not_to have_selector('#search')
    expect(page).to have_text "1. Illegal Pete's, The Hill--Boulder"
  end

  context "merchantlist 1000 param present" do
    let(:merchants) { { merchants: [{ active: "Y",
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
                                      group_ordering_on: "1" }] } }

    before do
      merchant_where_stub(params: { merchantlist: "1000" },
                          return: merchants)

      visit merchants_path(merchantlist: "1000")
    end

    it "should display only the merchants provided with group order checkbox" do
      expect(page).to have_text "1. Illegal Pete's, Test MerchantList"
      expect(page).to have_text "1320 College Ave, Boulder, CO 80302"

      expect(page).to have_css "[href='/merchants/1000?order_type=pickup']", text: "Pickup"
      page.should have_css('div.checkbox-group')
    end
  end

  it "displays results when someone uses a link with a zip code" do
    stub_merchants_for_zip("80305")
    visit merchants_path(zip: "80305")

    review_search_results
  end

  context "not logged in" do
    before do
      stub_merchants_for_zip("80305")
    end

    it "should require the user to sign in when selecting 'Delivery'" do
      fill_in("location", with: "80305")
      click_button "Search"

      click_link "Delivery"

      feature_sign_in(sign_in_selector: ".sign-in")
    end

    it "should display merchants_path and modal after sign in" do
      stub_signed_in_merchants_for_zip("80305")

      fill_in("location", with: "80305")
      click_button "Search"

      click_link "Delivery"

      feature_sign_in(sign_in_selector: ".sign-in")

      expect(URI.parse(current_url).request_uri).to eq("/?location=80305&delivery_path=%2Fmerchants%2F103893%3Forder_type%3Ddelivery")

      expect(page).to have_selector("input#location", count: 1)
      location_input = page.find("input#location")
      expect(location_input.value).to eq("80305")

      expect(page).to have_selector("div#select-address div.addresses", count: 1)

      within("div#select-address") do
        view_hidden_elements do
          expect(page).to have_selector("div.addresses", count: 1)
          expect(page).to have_selector("div.bordered", count: 2)
          expect(page).to have_selector("div.address-check", count: 2)
          expect(page).to have_selector("input[type=radio]:checked", count: 1)
          expect(page).to have_selector("button.set-btn", count: 1)
        end
      end
    end

    it "should display merchants_path and modal after sign up" do
      stub_signed_in_merchants_for_zip("80305")

      fill_in "location", with: "80305"
      click_button "Search"

      click_link "Delivery"

      stub_signed_in_merchants_for_zip("80305", "TONYTONY")

      feature_sign_up(first_name: "Tony",
                      last_name: "Stark",
                      email: "tony@starkindustries.com",
                      contact_no: "5555555555",
                      password: "iamironman",
                      user_return: get_signup_user)

      expect(URI.parse(current_url).request_uri).to eq("/?location=80305&delivery_path=%2Fmerchants%2F103893%3Forder_type%3Ddelivery")
    end

    it "should display merchants_path and modal after sign in and visit forgot password" do
      stub_signed_in_merchants_for_zip("80305")

      fill_in "location", with: "80305"
      click_button "Search"
      click_link "Delivery"

      click_link "Forgot Password?"

      click_link "Return to sign in"

      feature_sign_in(sign_in_selector: ".sign-in")

      expect(URI.parse(current_url).request_uri).to eq("/?location=80305&delivery_path=%2Fmerchants%2F103893%3Forder_type%3Ddelivery")
    end

    it "should redirect to merchant's path" do
      stub_signed_in_merchants_for_zip("80305")

      fill_in("location", with: "80305")
      click_button "Search"

      click_link "Delivery"

      feature_sign_in(sign_in_selector: ".sign-in")

      expect(URI.parse(current_url).request_uri).to eq("/?location=80305&delivery_path=%2Fmerchants%2F103893%3Forder_type%3Ddelivery")

      page.find("button.set-btn").click

      expect(URI.parse(current_url).request_uri).to eq("/merchants/103893?order_type=delivery&user_addr_id=5667")
    end

    it "should redirect to merchant's path with special characters search" do
      stub_merchants_for_zip("1509+Arapahoe+Ave%2C+Boulder%2C+CO+80302")
      visit merchants_path
      fill_in "location", with: "1509 Arapahoe Ave, Boulder, CO 80302"
      click_button "Search"

      click_link "Delivery"

      feature_sign_in(sign_in_selector: ".sign-in")

      expect(URI.parse(current_url).request_uri).to eq("/?location=1509+Arapahoe+Ave%2C+Boulder%2C+CO+80302&delivery_path=%2Fmerchants%2F103893%3Forder_type%3Ddelivery")
    end
  end

  it "delivery modal flow" do
    stub_signed_in_merchants_for_zip("80305")
    merchant = get_merchant_data.merge("zip" => "80305", "name" => "Geisty's Dogg House", "merchant_id" => "103893")
    merchant_find_stub(merchant_id: merchant["merchant_id"], auth_token:"ASNDKASNDAS", delivery: true, return: merchant)
    merchant_indeliveryarea_stub(merchant_id: merchant["merchant_id"], auth_token:"ASNDKASNDAS", delivery_address_id: "5667")

    feature_sign_in

    fill_in 'location', with: "80305"
    click_button "Search"

    page.find('.delivery.button').click

    expect(page).to have_selector("#select-address")

    stubs_delivery_address_failure("ASNDKASNDAS", "2", "202403")

    verify_address_dialog

    # Invalid delete address flow
    within("#select-address") do
      view_hidden_elements do
        page.all("div.delete button").last.click
      end
    end

    verify_delete_conf_dialog

    within("#delivery-address") do
      page.find("div[data-dialog-footer] button.btn-delete-usr-addr.primary").click
    end

    verify_address_dialog

    # Valid delete address flow
    within("#select-address") do
      view_hidden_elements do
        page.all("div.delete button").last.click
      end
    end

    verify_delete_conf_dialog

    #Delivery dialog No Button
    within("#delivery-address") do
      page.find("div[data-dialog-footer] a.btn-delete-usr-addr.secondary").click
    end

    expect(page).not_to have_selector("#delivery-address")

    verify_address_dialog

    within("#select-address") do
      view_hidden_elements do
        stubs_delivery_address_success("ASNDKASNDAS", "2", "202403")
        page.all("div.delete button").last.click
      end
    end

    verify_delete_conf_dialog

    within("#delivery-address") do
      page.find("div[data-dialog-footer] button.btn-delete-usr-addr.primary").click
    end

    within("#select-address") do
      view_hidden_elements do
        expect(page).to have_content "6450 York St Basement Denver, CO 80229"
        expect(page.first(".address-check .actions input")[:checked]).to be_truthy
        expect(page).not_to have_link "Enter a new address"
        expect(page).to have_selector("div.delete button", count: 1)
        expect(page).to have_selector("input[type='radio']", count: 1)
        expect(page.find("input[type='radio']").value).to eq "5667"
        page.find(".set-btn.secondary").click
      end
    end

    expect(URI.parse(current_url).request_uri).to eq("/merchants/103893?order_type=delivery&user_addr_id=5667")

    # Selenium specific code.
    browser = Capybara.current_session.driver.browser.manage
    expect(browser.cookie_named('userPrefs')[:value]).to eq("%7B%22preferredAddressId%22%3A%225667%22%7D")
  end

  def verify_address_dialog
    within("#select-address") do
      view_hidden_elements do
        expect(page).to have_content "555 5th st Boulder, CT 06001"
        expect(page.first(".address-check .actions input")[:checked]).to be_truthy
        expect(page).to have_content "6450 York St Basement Denver, CO 80229"
        expect(page.all(".address-check .actions input")[1][:checked]).to be_falsey
        expect(page).not_to have_link "Enter a new address"
        expect(page).to have_selector(".new-address-btn", count:1)
        expect(page.find(".new-address-btn.primary").text).to eq("Enter a new address")
        expect(page.find(".set-btn.secondary").text).to eq("Set")
        expect(page).to have_selector("div.delete button", count: 2)
      end
    end
  end
end
