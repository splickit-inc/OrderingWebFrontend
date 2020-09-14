require 'support/feature_spec_helper'

describe 'Loyalty', js: true do
  before do
    # lets pretend that we're actually updating the user via the API
    stub_request(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2")
      .to_return(body: get_loyal_user_data_json, status: 200)

    user_loyalty_history_stub

    rules_loyalty_stub(brand: "snarfs", body: "<h3>Reward points redemption</h3>\n      <p>See our local redemption schedule below. But beware...your local Pita\n        Pit may offer even more great deals!</p>\n\n      <dl>\n        <dt>Standard Pita / Fork Style</dt>\n        <dd>90 Points</dd>\n        <dt>\"6\" Pita / Kids Pita</dt>\n<dd>70 Points</ dd>\n<dt>32 oz Fountain Drink</dt>\n<dd>30 Points</ dd>\n<dt>Bag of Chips</dt>\n<dd>15 Points</ dd>\n<dt>Fresh Baked Cookie</dt>\n<dd>10 Points</ dd>\n</dl>\n\n<p>Learn more on the Pit Card and <a href=\"https://www.mypitapitcard.com/faq\">FAQ's</a> page.</p>")

    skin_where_stub(return: { skin_name: "Snarfs",
                              facebook_thumbnail_url: "http =>//itunes.apple.com/us/app/moes-pit/id461735388?mt=8",
                              twitter_handle: "MoesUSA",
                              supports_join: "0",
                              brand_fields: [{ field_name: "date_of_birth",
                                               field_type: "date" },
                                             { field_name: "zip",
                                               field_type: "text" },
                                             { field_name: "marketing_email_opt_in",
                                               field_type: "boolean" }],
                              loyalty_features: { supports_history: true,
                                                  supports_join: true,
                                                  supports_link_card: true,
                                                  loyalty_type: "remote",
                                                  loyalty_labels: [{ label: "Cash balance", type: "usd" },
                                                                   { label: "Points balance", type: "points" }] },
                              merchants_with_delivery: true,
                              iphone_app_link: "http://itunes.mapple.com/us/app/moes-pit/id461735388?mt=8",
                              http_code: "200",
                              loyalty_tnc_url: "http://www.google.com",
                              loyalty_card_management_link: "www.mysnafscard.com" })

    visit root_path(override_skin: "snarfs")
  end

  context "supports cash balance" do
    before do
      sign_in_loyal_user
      click_link "500 Points"
    end

    context "remote" do
      before do
        clear_skin_cache

        skin_where_stub(return: { skin_name: "Snarfs",
                                  facebook_thumbnail_url: "http =>//itunes.apple.com/us/app/moes-pit/id461735388?mt=8",
                                  twitter_handle: "MoesUSA",
                                  supports_join: "0",
                                  brand_fields: [{ field_name: "date_of_birth",
                                                   field_type: "date" },
                                                 { field_name: "zip",
                                                   field_type: "text" },
                                                 { field_name: "marketing_email_opt_in",
                                                   field_type: "boolean" }],
                                  loyalty_features: { supports_history: true,
                                                      supports_join: true,
                                                      supports_link_card: true,
                                                      loyalty_type: "remote",
                                                      loyalty_labels: [{ label: "Rewards balance", type: "usd" },
                                                                       { label: "Points balance", type: "points" }] },
                                  merchants_with_delivery: true,
                                  iphone_app_link: "http://itunes.mapple.com/us/app/moes-pit/id461735388?mt=8",
                                  http_code: "200",
                                  loyalty_tnc_url: "http://www.google.com",
                                  loyalty_card_management_link: "www.mysnafscard.com" })

        visit history_user_loyalty_path
      end

      it "should display desired remote structure" do
        within ".value-group" do
          expect(page).to have_content("Rewards balance $25")
          expect(page).to have_content("Points balance 500")
          expect(first("span").text).to eq("Rewards balance $25")
        end
      end
    end

    it "displays the correct tab content when the user is loyal" do
      # user on loyalty info page
      expect(URI.parse(current_url).request_uri).to eq("/user/loyalty/history")
      expect(page).to have_content "Cash balance $25"
      expect(page).to have_content "Points balance 500"
      expect(page).to have_content "History"
      expect(page).to have_content "My Card"
      expect(page).to have_content "Rules"

      # history tab
      expect(page.find('nav.secondary .current')).to have_content "History"

      # my card tab
      click_link('My Card')
      expect(page.find('nav.secondary .current')).to have_content "My Card"
      expect(page).to have_content "Manage your card"
      expect(page).to have_content "Manage your card on www.mysnafscard.com"

      # rules tab
      click_link('Rules')
      expect(page.find('nav.secondary .current')).to have_content "Rules"
      expect(page).to have_content "Reward points redemption"
      expect(page).to have_content "See our local redemption schedule below. But beware...your local Pita Pit may offer even more great deals!"
      expect(page).to have_content "Standard Pita / Fork Style 90 Points"
      expect(page).to have_content "6\" Pita / Kids Pita 70 Points"
      expect(page).to have_content "32 oz Fountain Drink 30 Points"
      expect(page).to have_content "Bag of Chips 15 Points"
      expect(page).to have_content "Fresh Baked Cookie 10 Points"
      expect(page).to have_content "Learn more on the Pit Card and FAQ's page."
    end

    it "should display the correct Transaction history table" do
      within "div.loyalty-content" do
        expect(page).to have_css("tr", count: 2)
        expect(page).to have_css("tbody tr", count: 1)

        within "tbody" do
          expect(page).to have_css("td[data-label='DATE']", text: "20-1005")
          expect(page).to have_css("td[data-label='ACTIVITY']", text: "2468408")
          expect(page).to have_css("td[data-label='description']", text: "test")
          expect(page).to have_css("td[data-label='amount']", text: "174")
        end
      end
    end
  end

  context "does not support cash balance" do
    it "displays the correct tab content when the user is loyal" do
      sign_in_loyal_user_no_cash

      click_link "500 Points"

      # user on loyalty info page
      expect(URI.parse(current_url).request_uri).to eq("/user/loyalty/history")
      expect(page).not_to have_content "Cash balance"
      expect(page).to have_content "Points balance 500"
      expect(page).to have_content "History"
      expect(page).to have_content "My Card"
      expect(page).to have_content "Rules"

      # history tab
      expect(page.find('nav.secondary .current')).to have_content "History"

      # my card tab
      click_link('My Card')
      expect(page.find('nav.secondary .current')).to have_content "My Card"
      expect(page).to have_content "Manage your card"
      expect(page).to have_content "Manage your card on www.mysnafscard.com"

      # rules tab
      click_link('Rules')
      expect(page.find('nav.secondary .current')).to have_content "Rules"
      expect(page).to have_content "Reward points redemption"
      expect(page).to have_content "See our local redemption schedule below. But beware...your local Pita Pit may offer even more great deals!"
      expect(page).to have_content "Standard Pita / Fork Style 90 Points"
      expect(page).to have_content "6\" Pita / Kids Pita 70 Points"
      expect(page).to have_content "32 oz Fountain Drink 30 Points"
      expect(page).to have_content "Bag of Chips 15 Points"
      expect(page).to have_content "Fresh Baked Cookie 10 Points"
      expect(page).to have_content "Learn more on the Pit Card and FAQ's page."
    end
  end

  context "does not support join" do
    it "should not allow a user to join, only link account" do
      clear_skin_cache

      skin_where_stub(return: { skin_name: "Snarfs",
                                facebook_thumbnail_url: "http =>//itunes.apple.com/us/app/moes-pit/id461735388?mt=8",
                                twitter_handle: "MoesUSA",
                                supports_join: "0",
                                brand_fields: [{ field_name: "date_of_birth",
                                                 field_type: "date" },
                                               { field_name: "zip",
                                                 field_type: "text" },
                                               { field_name: "marketing_email_opt_in",
                                                 field_type: "boolean" }],
                                loyalty_features: { supports_history: true,
                                                    supports_join: false,
                                                    supports_link_card: true,
                                                    loyalty_type: "remote",
                                                    loyalty_labels: [{ label: "Cash balance", type: "usd" },
                                                                     { label: "Points balance", type: "points" }] },
                                merchants_with_delivery: true,
                                iphone_app_link: "http://itunes.mapple.com/us/app/moes-pit/id461735388?mt=8",
                                http_code: "200",
                                loyalty_tnc_url: "http://www.google.com",
                                loyalty_card_management_link: "www.mysnafscard.com" })

      feature_sign_in

      click_link "Loyalty"

      # correct page
      expect(URI.parse(current_url).request_uri).to eq("/user/loyalty")

      # loyalty card content
      expect(page).to have_content "Link Your Loyalty Account"
      expect(page).to have_content "Sign up below and get points for every purchase. Points are redeemable for menu items."
      expect(page).to have_content "Link your existing loyalty account"
      expect(page).to have_content "Enter your loyalty number below."
      expect(page).not_to have_content "By continuing I agree to the terms and conditions"
      expect(page).not_to have_content "Create loyalty account"
      expect(page).not_to have_content "Join Our Rewards Program"

      stub_pin_error_response

      fill_in("brand_loyalty_loyalty_number", with: "1287381738172837182")
      fill_in("brand_loyalty_pin", with: "100000000000000000000000")
      click_button "Go"

      # display loyalty error messages
      expect(page).to have_content "The parameter \"pin\" cannot be more than 10 characters."

      stub_update_link_loyalty
      stub_loyal_user_response

      # link loyalty account
      fill_in("brand_loyalty_loyalty_number", with: "1287381738172837182")
      fill_in("brand_loyalty_pin", with: "6666")
      click_button "Go"

      # user on loyalty history page
      expect(URI.parse(current_url).request_uri).to eq("/user/loyalty/history")
      expect(page).to have_content "Cash balance $25"
      expect(page).to have_content "Points balance 500"
    end
  end

  it "links an existing loyalty account" do
    feature_sign_in

    click_link "Loyalty"

    # correct page
    expect(URI.parse(current_url).request_uri).to eq("/user/loyalty")

    # loyalty card content
    expect(page).to have_content "Join Our Rewards Program"
    expect(page).to have_content "Sign up below and get points for every purchase. Points are redeemable for menu items."
    expect(page).to have_content "Link your existing loyalty account"
    expect(page).to have_content "Enter your loyalty number below."
    expect(page).to have_content "By continuing I agree to the terms and conditions"

    stub_pin_error_response

    fill_in("brand_loyalty_loyalty_number", with: "1287381738172837182")
    fill_in("brand_loyalty_pin", with: "100000000000000000000000")
    click_button "Go"

    # display loyalty error messages
    expect(page).to have_content "The parameter \"pin\" cannot be more than 10 characters."

    stub_update_link_loyalty
    stub_loyal_user_response

    # link loyalty account
    fill_in("brand_loyalty_loyalty_number", with: "1287381738172837182")
    fill_in("brand_loyalty_pin", with: "6666")
    click_button "Go"

    # user on loyalty history page
    expect(URI.parse(current_url).request_uri).to eq("/user/loyalty/history")
    expect(page).to have_content "Cash balance $25"
    expect(page).to have_content "Points balance 500"
  end

  it "creates a new loyalty account" do
    feature_sign_in

    click_link "Loyalty"

    # correct page
    expect(URI.parse(current_url).request_uri).to eq("/user/loyalty")

    # loyalty card content
    expect(page).to have_content "Join Our Rewards Program"
    expect(page).to have_content "Sign up below and get points for every purchase. Points are redeemable for menu items."
    expect(page).to have_content "Link your existing loyalty account"
    expect(page).to have_content "Enter your loyalty number below."
    expect(page).to have_content "By continuing I agree to the terms and conditions"

    stub_loyal_user_response

    # create a new loyalty account
    click_button "Create loyalty account"

    # user on loyalty history page
    expect(URI.parse(current_url).request_uri).to eq("/user/loyalty/history")
    expect(page).to have_content "Cash balance $25"
    expect(page).to have_content "Points balance 500"
  end

  context "third party loyalty service" do
    before do
      feature_sign_in(user_return: { brand_loyalty: { loyalty_number: "140105420000001793",
                                                      pin: "9189",
                                                      points: "200",
                                                      usd: "25" } })

      click_link "200 Points"
    end

    it "should display card link and back card" do
      expect(page).to have_content("What's my loyalty card number?")
      click_link("What's my loyalty card number?")

      expect(page).to have_content("What's my loyalty card balance?")
      click_link("What's my loyalty card balance?")

      expect(page).to have_content("What's my loyalty card number?")
    end
  end

  context "splickit loyalty service" do
    before do
      clear_skin_cache

      skin_where_stub(return: { loyalty_features: { supports_history: true,
                                                    supports_join: true,
                                                    supports_link_card: true,
                                                    loyalty_type: "splickit_earn" } })

      feature_sign_in(user_return: { brand_loyalty: { loyalty_number: "140105420000001793",
                                                      pin: "9189",
                                                      points: "200",
                                                      usd: "25" } })

      click_link "200 Points"
    end

    it "should not display card link" do
      expect(page).not_to have_content("What's my loyalty card number?")
      expect(page).not_to have_css("div.back.loyalty-card-bg")
    end
  end

  def stub_pin_error_response
    stub_request(
      :post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2")
      .to_return(status: 400, body: { error: { error: "The parameter \"pin\" cannot be more than 10 characters." } }.to_json)
  end

  def stub_update_link_loyalty(options = {})
    auth_token = options[:auth_token] || "ASNDKASNDAS"
    stub_request(
      :post, "#{ API.protocol }://splickit_authentication_token:#{ auth_token }@#{ API.domain }#{ API.base_path }/users/2")
      .to_return(status: 200, body: { data: get_loyal_user_data }.to_json)
  end

  def stub_loyal_user_response
    stub_request(
      :get, "#{ API.protocol }://bob%40roberts.com:password@#{ API.domain }#{ API.base_path }/usersession?email=bob@roberts.com&password=password").to_return(
      :status => 200,
      :body => get_loyal_user_data_json)
    stub_request(
      :get, "#{ API.protocol }://bob%40roberts.com:password@#{ API.domain }#{ API.base_path }/usersession").to_return(
      :status => 200,
      :body => get_loyal_user_data_json)
    stub_request(
      :get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2")
      .to_return(status: 200, body: { data: get_loyal_user_data }.to_json)
  end
end
