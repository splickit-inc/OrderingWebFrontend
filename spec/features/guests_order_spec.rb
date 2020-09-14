require "support/feature_spec_helper"

describe "guest order", js: true do
  let!(:user_data) { get_user_data }

  let(:menu_data) { get_default_menu }
  let(:menu) { menu_data[:menu] }
  let(:modifier_item_1) { menu_data[:modifier_item_1] }

  let(:merchant) do
    merchant = Merchant.new
    merchant.merchant_id = "102237"
    merchant.name = "Coeur d'Restaurant"
    merchant.display_name = "Coeur d'Alene"
    merchant.address1 = "320 Sherman Ave"
    merchant.city = "Coeur d'Alene"
    merchant.state = "83814"
    merchant.delivery = "Y"
    merchant.group_ordering_on = "1"
    merchant.show_tip = true
    merchant.menu = menu

    merchant
  end

  let(:checkout_group_order_items_body) do
    { group_order_token: nil,
      merchant_id: merchant.merchant_id,
      items: [{ item_id: 931,
                quantity: 1,
                mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                         mod_quantity: 1,
                         name: "Spicy Club Sauce"}],
                size_id: "3",
                order_detail_id: nil,
                status: "new",
                external_detail_id: 92391731240,
                points_used: nil,
                brand_points_id: nil,
                note: "" }] }
  end

  let(:checkout_return_hash) do
    { grand_total: "7.30",
      accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                 name: "Cash",
                                 splickit_accepted_payment_type_id: "1000",
                                 billing_entity_id: "1006" },
                               { merchant_payment_type_map_id: "1066",
                                 name: "Credit Card",
                                 splickit_accepted_payment_type_id: "2000",
                                 billing_entity_id: "1000" }],
      order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                      item_price: "6.89",
                                      item_quantity: "1",
                                      item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                      order_detail_id: "6082053",
                                      note: "" }],
                       order_data_as_ids_for_cart_update: { merchant_id: merchant.merchant_id,
                                                            user_id: "4777193",
                                                            items: [{ item_id: "931",
                                                                      size_id: "1",
                                                                      quantity: "1",
                                                                      order_detail_id: "6082053",
                                                                      external_detail_id: 92391731240,
                                                                      status: "saved",
                                                                      mods: [{ modifier_item_id: "2",
                                                                               mod_quantity: "1" }] }] },
                       receipt_items: [{ title: "Subtotal",
                                         amount: "$6.89" },
                                       { title: "Tip",
                                         amount: "$0.00" },
                                       { title: "Tax",
                                         amount: "$0.41" },
                                       { title: "Total",
                                         amount: "$7.30" }] } }
  end

  let(:order_body_hash) do
    { cart_ucid: "9705-j069h-ce8w3-425di",
      user_id: user_data["user_id"],
      requested_time: "1415823383",
      tip: "1.03",
      note: "",
      merchant_payment_type_map_id: "1066" }
  end

  let(:order_return_hash) do
    { tip_amt: 0,
      grand_total: "7.30",
      order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                      item_price: "6.89",
                                      item_quantity: "1",
                                      item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                      order_detail_id: "6082053",
                                      note: "" }],
                       receipt_items: [{ title: "Subtotal",
                                         amount: "$6.89" },
                                       { title: "Tax",
                                         amount: "$0.41" },
                                       { title: "Total",
                                         amount: "$7.30" }] } }
  end

  before do
    merchant_where_stub(params: { location: "83814" },
                        return: { merchants: [merchant.as_json(root: false)], promos: [] })

    merchant_find_stub(merchant_id: merchant.merchant_id,
                       return: merchant.as_json(root: false))

    visit merchants_path

    fill_in("location", with: "83814")

    click_button("Search")

    allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)
  end

  context "pickup" do
    before do
      checkout_stubs(body: checkout_group_order_items_body, return: checkout_return_hash)

      order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                        body: order_body_hash,
                        return: order_return_hash)

      within("aside") do
        click_link("Pickup")
      end

      first("article").click
      first("button.add.cash").click

      first(".my-order-link").click

      first("button.checkout").click
    end

    it "should continue guest flow" do
      # should have Continue as Guest link on sign in page
      expect(URI.parse(current_url).request_uri).to include(sign_in_path)

      expect(page).to have_link("Continue as Guest")

      click_link("Continue as Guest")

      # should render all Guest sign up page
      within "div.sign-up" do
        fill_in "First name", with: "Tony"
        fill_in "Email", with: "tony@starkindustries.com"
        fill_in "Phone number", with: "5555555555"

        expect(page).to have_css("input[type='submit']")
        expect(find("input[type='submit']").value).to eq("Continue as Guest")
      end

      user_create_stub(body: { first_name: "Tony",
                               email: "tony@starkindustries.com",
                               contact_no: "5555555555",
                               is_guest: "true" },
                       return: get_user_data.merge("flags" => "1C21000021"))

      user_find_stub(auth_token: "ASNDKASNDAS", return: get_user_data.merge("flags" => "1C21000021"))

      click_button "Continue as Guest"

      expect(URI.parse(current_url).request_uri).to include(new_checkout_path)

      expect(page).to have_content "HOME"

      find("#tip #tip").find(:xpath, "option[4]").select_option

      click_button "Place order"

      expect(page).to have_content "HOME"

      expect(page).to_not have_css("div#save-favorite")

      expect(page).not_to have_content("Add order to favorites")
      expect(page).not_to have_content("Name your favorite")
      expect(page).not_to have_content("Add to favorites")
    end
  end

  context "delivery" do
    before do
      checkout_stubs(body: checkout_group_order_items_body.merge(submitted_order_type: "delivery",
                                                                 user_addr_id: "202402"),
                     return: checkout_return_hash)

      order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                        body: order_body_hash.merge(delivery_time: "Wed 11-12 08:16 PM"),
                        return: order_return_hash)

      within("aside") do
        click_link("Delivery")
      end
    end

    it "should continue guest flow" do
      # should have Continue as Guest link on sign in page
      expect(URI.parse(current_url).request_uri).to include(sign_in_path)

      expect(page).to have_link("Continue as Guest")

      click_link("Continue as Guest")

      # should render all Guest sign up page
      within "div.sign-up" do
        fill_in "First name", with: "Tony"
        fill_in "Email", with: "tony@starkindustries.com"
        fill_in "Phone number", with: "5555555555"

        expect(page).to have_css("input[type='submit']")
        expect(find("input[type='submit']").value).to eq("Continue as Guest")
      end

      user_create_stub(body: { first_name: "Tony",
                               email: "tony@starkindustries.com",
                               contact_no: "5555555555" },
                       return: get_user_data.merge("flags" => "1C21000021"))

      user_find_stub(auth_token: "ASNDKASNDAS", return: get_user_data.merge("flags" => "1C21000021"))

      click_button "Continue as Guest"
    end

    context "order flow" do
      before do
        merchant_where_stub(params: { location: "83814" },
                            auth_token: user_data["splickit_authentication_token"],
                            return: { merchants: [merchant.as_json(root: false)], promos: [] })

        merchant_find_stub(merchant_id: merchant.merchant_id,
                           delivery: true,
                           auth_token: user_data["splickit_authentication_token"],
                           return: merchant.as_json(root: false))

        feature_guest_sign_up(first_name: "Tony",
                              email: "tony@starkindustries.com",
                              contact_no: "5555555555",
                              user_return: get_user_data.merge("delivery_locations" => [],
                                                               "flags" => "1C21000021"))

        find(".new-address-btn.primary").click

        expect(URI.parse(current_url).request_uri).to eq(new_user_address_path(path: "/merchants/102237?order_type=delivery"))

        user_store_address_stub

        merchant_indeliveryarea_stub(merchant_id: merchant.merchant_id,
                                     delivery_address_id: "202402",
                                     auth_token: user_data["splickit_authentication_token"])

        fill_in("Business Name", with: "Geisty's Company")
        fill_in("Street address", with: "1116 13th Street")
        fill_in("Suite / Apt", with: "St")
        fill_in("City", with: "Geisty's Dogg House, Boulder")
        fill_in("State", with: "CO")
        fill_in("Zip", with: "80305")
        fill_in("Phone number", with: "1234567890")
        fill_in("The doorbell is broken; please knock.", with: "Don't mind the sock.")

        click_button("Add delivery address")

        first("article").click
        first("button.add.cash").click

        first(".my-order-link").click

        click_button("Checkout")
      end

      it "should not render common user elements" do
        expect(URI.parse(current_url).request_uri).to include(new_checkout_path)

        expect(page).to have_content "HOME"

        find("#tip #tip").find(:xpath, "option[4]").select_option

        click_button "Place order"

        expect(page).to have_content "HOME"

        within "section#details" do
          expect(page).to have_content("Email:")
          expect(page).to have_content("bob@roberts.com")
        end

        expect(page).to_not have_css("div#save-favorite")

        expect(page).not_to have_content("Add order to favorites")
        expect(page).not_to have_content("Name your favorite")
        expect(page).not_to have_content("Add to favorites")
      end
    end
  end
end