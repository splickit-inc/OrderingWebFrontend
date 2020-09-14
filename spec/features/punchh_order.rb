require "support/feature_spec_helper"

describe "Punchh ordering", js: true do
  let(:menu_data) { get_default_menu }
  let(:menu) { menu_data[:menu] }
  let(:modifier_item_1) { menu_data[:modifier_item_1] }

  before do
    user_authenticate_stub(punch_header: "test_token", return: { email: "test_email@mail.com" })
  end

  shared_examples "punchh nav bar" do
    it "should not display Account option" do
      expect(page).not_to have_content "ACCOUNT"
    end

    it "should not display Sign Out option" do
      expect(page).not_to have_content "SIGN OUT"
    end

    it "should not have iOS and Android metas" do
      expect(page).not_to have_css("meta[name='apple-itunes-app']", visible: false)
      expect(page).not_to have_css("meta[name='google-play-app']", visible: false)
    end
  end

  shared_examples "punchh sign in" do
    it "should sign in when punch token is present and the user is not logged in" do
      expect(page).to have_content "bob roberts"
      expect(page).to have_content "test_email@mail.com"
      expect(page).not_to have_content "SIGN UP"
      expect(page).not_to have_content "SIGN IN"
      expect(WebMock).to have_requested(:get, "http://test.splickit.com/app2/apiv2/usersession")
                           .with("headers" => { "Punch-Authentication-Token" => "test_token" })
    end

    it "should not sign in when punch token is present and the user is logged in" do
      # 2nd visit with punch token
      visit root_path(security_token: "test_token")
      expect(a_request(:get, "http://test.splickit.com/app2/apiv2/usersession")
               .with("headers" => { "Punch-Authentication-Token" => "test_token" })).to have_been_made.times(1)
    end
  end

  shared_examples "punchh checkout" do
    it "should display custom loyalty payment" do
      merchant_find_stub(auth_token: "ASNDKASNDAS",
                         merchant_id: "100030",
                         return: { menu: menu,
                                   merchant_id: "100030"})

      find("a.close-menu").click if window == "small"

      first(".pickup.button").click
      first("article.item").click
      first("button.add").click

      cart_create_stub(body: { user_id: "2",
                               merchant_id: "100030",
                               user_addr_id: nil,
                               items:[{ item_id: 931,
                                        quantity: 1,
                                        mods:[{ modifier_item_id: modifier_item_1.modifier_item_id,
                                                mod_quantity: 1,
                                                name: "Spicy Club Sauce" }],
                                        size_id: "3",
                                        points_used: nil,
                                        brand_points_id: nil,
                                        note: "" }],
                               total_points_used: 0 })

      checkout_stubs(return: { accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                          name: "Account Credit",
                                                          splickit_accepted_payment_type_id: "5000",
                                                          billing_entity_id: nil },
                                                        { merchant_payment_type_map_id: "2000",
                                                          name: "Account Credit",
                                                          splickit_accepted_payment_type_id: "8000",
                                                          billing_entity_id: nil }] })

      first("div.order").click

      click_button("Checkout - $10.24")

      expect(page).to have_content("Rockin' Rewards Credit")
    end
  end

  context "small window" do
    let(:window) { "small" }

    before do
      page.driver.browser.manage.window.resize_to 500, 700
      visit root_path(override_skin: "moes", security_token: "test_token")
      page.execute_script "$('header div.user').trigger('click')"
    end

    it_behaves_like "punchh nav bar"

    it_behaves_like "punchh sign in"

    it_behaves_like "punchh checkout"

    it "should display close button" do
      expect(page).to have_content "CLOSE"
    end

    it "close button should close menu" do
      find("a.close-menu").click
      expect(page).not_to have_content "bob roberts"
      expect(page).not_to have_content "test_email@mail.com"
    end
  end

  context "large window" do
    let(:window) { "large" }

    before do
      page.driver.browser.manage.window.resize_to 1000, 1000
      visit root_path(override_skin: "moes", security_token: "test_token")
      page.find(".user").click
    end

    it_behaves_like "punchh nav bar"

    it_behaves_like "punchh sign in"

    it_behaves_like "punchh checkout"

    it "should not display close button" do
      expect(page).not_to have_content "CLOSE"
    end
  end
end