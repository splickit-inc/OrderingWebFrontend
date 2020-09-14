require "support/feature_spec_helper"

describe "ordering", js: true do
  let(:current_time) { 92391731239 }
  let(:modifier_item_1) { create_modifier_item("modifier_item_name" => "Spicy Club Sauce", "modifier_item_pre_selected" => "yes") }

  let(:modifier_item_2) { create_modifier_item("modifier_item_name" => "Vegetarian Club Sauce") }
  let(:modifier_item_3) { create_modifier_item("modifier_item_name" => "Lutefisk Club Sauce") }
  let(:modifier_group_1) { create_modifier_group(modifier_group_display_name: "Club Sauce",
                                                 modifier_items: [modifier_item_1,
                                                                  modifier_item_2,
                                                                  modifier_item_3],
                                                 "modifier_group_credit" => "1.00") }

  before do
    allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731239)

    menu_item_1 = create_menu_item(item_id: 931,
                                   modifier_groups: [modifier_group_1],
                                   item_name: "Pastrami Salad",
                                   description: "A bed of fresh pastrami topped with cool ranch pastrami.")
    menu_item_2 = create_menu_item(item_id: 932,
                                   modifier_groups: [modifier_group_1],
                                   item_name: "Zero Item",
                                   description: "Zero description")
    menu_type_1 = create_menu_type(menu_type_name: "Frozen Salads",
                                   menu_items: [menu_item_1, menu_item_2])

    menu = Menu.new
    menu.menu_id = 3300
    menu.name = "Salads in Bowls"
    menu.menu_types = [menu_type_1]

    # this overrides the menu size prices ObjectCreationMethods#get_size_prices
    menu.menu_types.first.menu_items.first.size_prices[0]["price"] = "6.65"
    menu.menu_types.first.menu_items.first.size_prices.delete_at(2)
    menu.menu_types.first.menu_items.first.size_prices.delete_at(1)

    menu.menu_types.first.menu_items.last.size_prices[0]["price"] = "0.00"
    menu.menu_types.first.menu_items.last.size_prices.delete_at(2)
    menu.menu_types.first.menu_items.last.size_prices.delete_at(1)

    @merchant = Merchant.new("merchant_id" => "4000",
                             "menu_id" => "#{ menu.menu_id }",
                             "menu_key" => "1122334455",
                             "name" => "Wooden Shjips",
                             "address1" => "1234 Bacon Lane",
                             "city" => "Deadwood",
                             "state" => "SD",
                             "phone_no" => "2224448899",
                             "brand" => "Acid Western",
                             "trans_fee_rate" => "5.00",
                             "show_tip" => "Y",
                             "time_zone_offset" => "-5")

    @merchant.menu = menu

    @merchant_json = { data: @merchant }.to_json

    @merchant_without_transaction_fee_rate = Merchant.new("merchant_id" => "5000",
                                                          "menu_id" => "#{ menu.menu_id }",
                                                          "menu_key" => "1122334455",
                                                          "name" => "Wooden Shjips",
                                                          "address1" => "1234 Bacon Lane",
                                                          "city" => "Deadwood",
                                                          "state" => "SD",
                                                          "phone_no" => "2224448899",
                                                          "brand" => "Acid Western",
                                                          "show_tip" => "Y",
                                                          "time_zone_offset" => "-5")

    @merchant_without_transaction_fee_rate.menu = menu

    # GET /merchants/:id
    merchant_find_stub(merchant_id: @merchant.merchant_id, return: @merchant.as_json(root: false))

    # GET /merchants/:id - signed in request
    merchant_find_stub(merchant_id: @merchant.merchant_id, auth_token: "ASNDKASNDAS",
                       return: @merchant.as_json(root: false))

    # GET /merchants/:id - signed in request
    merchant_find_stub(merchant_id: @merchant.merchant_id, auth_token: "X538YPT87I6U59GSWYHD",
                       return: @merchant.as_json(root: false))

    # GET /merchants/:id - signed in request
    merchant_find_stub(merchant_id: @merchant.merchant_id, auth_token: "S56LKZ92UD9W07V99806",
                       return: @merchant.as_json(root: false))

    # POST /cart/checkout
    order_submit_stub(auth_token: "ASNDKASNDAS",
                      body: { user_id: "2" },
                      return: checkout_json)
  end

  it "allows for orders to be placed on any page" do
    stub_merchants_for_zip("80305")
    stub_signed_in_merchants_for_zip("80305")

    visit merchants_path

    fill_in("location", with: "80305")
    click_button("Search")

    merchant_find_stub({merchant_id: "1106", return: @merchant.as_json(root: false) })

    first(".pickup.button").click

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first("article.item").click
    first("button.add").click

    first(".my-order-link").click

    items = cart_session_items

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   body: { items:[{ item_id: 931,
                                    quantity: 1,
                                    mods:[{ modifier_item_id: modifier_item_1.modifier_item_id,
                                            mod_quantity: 1,
                                            name: "Spicy Club Sauce" }],
                                    size_id: "1",
                                    order_detail_id: nil,
                                    status: "new",
                                    external_detail_id: 92391731239,
                                    points_used: nil,
                                    brand_points_id: nil,
                                    note: "" }] },
                   return: { grand_total: "7.30",
                             order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                             item_price: "6.89",
                                                             item_quantity: "1",
                                                             item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                             order_detail_id: "6082053",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: items.first["uuid"],
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] } })

    click_button("Checkout - $6.65")

    feature_sign_in(sign_in_selector: ".sign-in")

    # verify checkout page
    expect(page).to have_content("Place order")

    # back to index
    first(".logo").click

    # verify 'my order' dialog
    first(".my-order-link").click

    expect(page).to have_selector("#my-order h5", count: 1)

    # add more items from same merchant
    click_link("Add more items")

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731243)

    first("article.item").click
    first("button.add").click

    # item added popup:view order
    expect(page).to have_content("Item successfully added")

    click_link("View order")

    expect(page).to have_selector("#my-order h5", count: 2)
    expect(page).to have_content("$13.30")

    page.find(:xpath, "//span[@data-dialog-close]").click

    expect(page).not_to have_content("Item successfully added")

    # back to index
    first(".logo").click

    # verify My Order dialog
    first(".my-order-link").click

    click_link("Add more items")

    first(".my-order-link").click

    expect(page).to have_selector("#my-order h5", count: 2)
    expect(page).to have_content("$13.30")

    # remove item
    first(".remove-item").click

    expect(page).to have_content("Checkout - $6.65")

    # remove item again
    first(".remove-item").click

    page.find(:xpath, "//span[@data-dialog-close]").click

    # add item
    allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)
    first("article.item").click
    first("button.add").click

    items = cart_session_items

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "9705-j069h-ce8w3-425di",
                   body: { items:[{ item_id: 931,
                                    quantity: 1,
                                    mods:[{ modifier_item_id: modifier_item_1.modifier_item_id,
                                            mod_quantity: 1,
                                            name: "Spicy Club Sauce" }],
                                    size_id: "1",
                                    order_detail_id: "27479804",
                                    status: "deleted",
                                    external_detail_id: items.first["uuid"],
                                    points_used: nil,
                                    brand_points_id: nil,
                                    note: "" },
                                  { item_id: 931,
                                    quantity: 1,
                                    mods:[{ modifier_item_id: modifier_item_1.modifier_item_id,
                                            mod_quantity: 1,
                                            name: "Spicy Club Sauce" }],
                                    size_id: "1",
                                    order_detail_id: nil,
                                    status: "new",
                                    external_detail_id: items.last["uuid"],
                                    points_used: nil,
                                    brand_points_id: nil,
                                    note: "" }] },
                   return: { grand_total: "7.30",
                             order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                             item_price: "6.89",
                                                             item_quantity: "1",
                                                             item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                             order_detail_id: "6082053",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479807",
                                                                                             external_detail_id: items.last["uuid"],
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] } })

    # item added popup:checkout
    click_link("Checkout")

    # verify checkout page
    expect(page).to have_content("Place order")

    # back to index
    first(".logo").click

    fill_in("location", with: "80305")
    click_button("Search")

    # verify 'change store' dialog
    page.all(".pickup.button")[1].click

    expect(page).to have_content("Change store?")
    expect(page).to have_content("You have an existing order at Wooden Shjips")
    expect(page).to have_content("Would you like to create a new order at Geisty's Dogg House")

    click_link("Cancel")

    expect(page).not_to have_content("Change store?")
    expect(page).not_to have_content("You have an existing order at Wooden Shjips")
    expect(page).not_to have_content("Would you like to create a new order at Geisty's Dogg House")

    # navigate to new merchant
    merchant_find_stub({merchant_id: "103893", auth_token: "ASNDKASNDAS", return: @merchant.as_json(root: false) })

    fill_in("location", with: "80305")
    click_button("Search")

    page.all(".pickup.button")[1].click

    click_link("Go")

    # verify cart is clear

    first(".my-order-link").click

    expect(page).to have_selector("#my-order h5", count: 0)
  end

  it "allows a user to place an order with store credit" do
    skip # Due to new loyalty flow
    stub_request(:get, "http://splickit_authentication_token:X538YPT87I6U59GSWYHD@test.splickit.com/app2/apiv2/users/7088-yybmg-o52uw-5f23d").
      to_return(
      :status => 200,
      :body => {
        "http_code"=>200,
        "stamp"=>"tweb03-i-027c8323-V328IUO",
        "data"=>{"user_id"=>"7088-yybmg-o52uw-5f23d",
                 "uuid"=>"7088-yybmg-o52uw-5f23d",
                 "last_four"=>"0000",
                 "flags" => "1C21000001",
                 "first_name"=>"Mr.",
                 "last_name"=>"fat",
                 "email"=>"mr@fat.com",
                 "contact_no"=>"1231231234",
                 "device_id"=>nil,
                 "balance"=>"55.00",
                 "referrer"=>nil,
                 "orders"=>"0",
                 "points_lifetime"=>"0",
                 "points_current"=>"10",
                 "custom_message"=>nil,
                 "user_groups"=>[],
                 "loyalty_number"=>"splick-1U497U7CYZ",
                 "brand_points"=>"10",
                 "brand_loyalty_history"=>[],
                 "brand_loyalty"=>{"map_id"=>"71037",
                                   "user_id"=>"1468052",
                                   "brand_id"=>"174",
                                   "loyalty_number"=>"splick-1U497U7CYZ",
                                   "points"=>"10",
                                   "loyalty_transactions"=>[],
                                   "loyalty_points"=>"10"
                 },
                 "splickit_authentication_token"=>"X538YPT87I6U59GSWYHD",
                 "splickit_authentication_token_expires_at"=>1413619815
        }, "message"=>nil}.to_json)

    checkout_stubs(auth_token: "X538YPT87I6U59GSWYHD",
                   body: { user_id: "7088-yybmg-o52uw-5f23d",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     status: "new",
                                     external_detail_id: anything,
                                     points_used:nil,
                                     brand_points_id: nil,
                                     note:"" }] },
                   return: { order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                             item_price: "6.89",
                                                             item_quantity: "1",
                                                             item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                             order_detail_id: "6082053",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] } })

    order_submit_stub(auth_token: "X538YPT87I6U59GSWYHD",
                      body: { merchant_id: 4000,
                              note: "",
                              user_id: "7088-yybmg-o52uw-5f23d",
                              tip:"0",
                              merchant_payment_type_map_id: "1002",
                              requested_time: "1405006471",
                              items: [{ item_id: "931",
                                        quantity: "1",
                                        name: "Pastrami Salad",
                                        note: "",
                                        size_id: "1",
                                        sizeName: "Small",
                                        cash: "6.65",
                                        price_string: "$6.65",
                                        uuid: current_time }],
                              total_points_used:0,
                              loyalty_number: "splick-1U497U7CYZ",
                              cart_ucid: "",
                              sub_total: "6.65",
                              user_addr_id: nil },
                      return: valid_orders_response)

    ## merchants#show
    visit merchant_path(@merchant.merchant_id, order_type: "pickup")

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first("article").click
    find_button("Add item & checkout").click

    feature_sign_in(sign_in_selector: ".sign-in",
                    email: "mr@fat.com",
                    password: "password",
                    user_return: { user_id: "7088-yybmg-o52uw-5f23d",
                                   balance: "55.00",
                                   splickit_authentication_token: "X538YPT87I6U59GSWYHD" })


    ## checkouts#new
    expect(page).to have_content("You have $55.00 store credit")
  end

  it "allows a new user to place an order" do
    stub_request(:post, "http://admin:welcome@test.splickit.com/app2/apiv2/users").
      with(
        :body => "{\"first_name\":\"Mr.\",\"last_name\":\"Bacon\",\"email\":\"mr@bacon.com\",\"contact_no\":\"888-555-1234\",\"birthday\":\"\",\"password\":\"password\"}").
      to_return(
        :status => 200,
        :body => {
          "http_code" => 200,
          "stamp" => "tweb03-i-027c8323-B05CK9X",
          "data" => {
            "first_name" => "Mr.",
            "last_name" => "Bacon",
            "email" => "mr@bacon.com",
            "contact_no" => "1231231234",
            "uuid" => "7088-yybmg-o52uw-5f23g",
            "balance" => 0,
            "user_id" => "7088-yybmg-o52uw-5f23g",
            "user_message_title" => "Hello!",
            "user_message" => "Welcome to mobile ordering! The future is friendly!",
            "splickit_authentication_token" => "S56LKZ92UD9W07V99806",
            "splickit_authentication_token_expires_at" => 1413619815
          },
          "message" => "Welcome to mobile ordering! The future is friendly!"
        }.to_json)

    visit merchant_path(@merchant.merchant_id, menu_type: "pickup")
    expect(page).to have_content "PICKUP MENU"

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click
    first('button.checkout').click

    within("div.sign-in") do
      click_link "JOIN NOW"
    end

    fill_in "First name", with: "Mr."
    fill_in "Last name", with: "Bacon"
    fill_in "Email address", with: "mr@bacon.com"
    fill_in "Phone number", with: "888-555-1234"
    fill_in "Create a password", with: "password"

    stub_request(:get, "http://splickit_authentication_token:S56LKZ92UD9W07V99806@test.splickit.com/app2/apiv2/users/7088-yybmg-o52uw-5f23g").
      to_return(
        :status => 200,
        :body => {
          "http_code"=>200,
          "stamp"=>"tweb03-i-027c8323-V328IUO",
          "data"=>{
            "user_id"=>"7088-yybmg-o52uw-5f23g",
            "uuid"=>"7088-yybmg-o52uw-5f23g",
            "last_four"=>"0000",
            "flags" => "1000000001",
            "first_name"=>"Mr.",
            "last_name"=>"Bacon",
            "email"=>"mr@bacon.com",
            "contact_no"=>"1231231234",
            "device_id"=>nil,
            "balance"=>"0.00",
            "referrer"=>nil,
            "orders"=>"0",
            "points_lifetime"=>"0",
            "points_current"=>"10",
            "custom_message"=>nil,
            "user_groups"=>[],
            "loyalty_number"=>"splick-1U497U7CYZ",
            "brand_points"=>"10",
            "brand_loyalty_history"=>[],
            "brand_loyalty"=>{
              "map_id"=>"71037",
              "user_id"=>"1468052",
              "brand_id"=>"174",
              "loyalty_number"=>"splick-1U497U7CYZ",
              "points"=>"10",
              "loyalty_transactions"=>[],
              "loyalty_points"=>"10"
            },
            "splickit_authentication_token"=>"S56LKZ92UD9W07V99806",
            "splickit_authentication_token_expires_at"=>1413619815
          },
          "message"=>nil
        }.to_json)

    checkout_stubs(auth_token: "S56LKZ92UD9W07V99806",
                   body: { user_id:"7088-yybmg-o52uw-5f23g",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     external_detail_id: 92391731239,
                                     status: "new",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: { order_amt: "$6.89",
                             grand_total: "7.30",
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "5000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                             item_price: "6.89",
                                                             item_quantity: "1",
                                                             item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                             order_detail_id: "6082053",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Tip",
                                                                amount: "$0.00" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] } })

    order_submit_stub(auth_token: "S56LKZ92UD9W07V99806",
                      body: { user_id: "7088-yybmg-o52uw-5f23g",
                              cart_ucid: "9705-j069h-ce8w3-425di",
                              tip: "0",
                              note: "",
                              requested_time: "1415823383" },
                      return: valid_orders_response)

    click_button "Sign Up"

    find("#tip #tip").find(:xpath, "option[2]").select_option
    find_button("Place order ($7.30)").click
    expect(page).to have_content "Thanks! Your order has been placed."
  end

  it "persist order detail" do
    checkout_stubs(auth_token: "ASNDKASNDAS",
                   body: { user_id:"2",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     external_detail_id: 92391731239,
                                     status: "new",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: { order_amt: "$6.89",
                             grand_total: "7.30",
                             lead_times_array:[1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456,
                                               1415830516, 1415830576, 1415830636, 1415830696, 1415830756, 1415830816,
                                               1415830876, 1415830936, 1415830996, 1415831056, 1415831356, 1415831656,
                                               1415831956, 1415832256, 1415832556, 1415832856, 1415833156, 1415833456,
                                               1415833756, 1415834056, 1415834356, 1415834656, 1415834956, 1415835256,
                                               1415835556, 1415835856, 1415836756, 1415837656, 1415838556, 1415839456,
                                               1415840356, 1415841256, 1415842156, 1415843056, 1415843956],
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "5000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479804",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Tip",
                                                                amount: "$0.00" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] } })

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "9705-j069h-ce8w3-425di",
                   body: { user_id:"2",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479804",
                                     external_detail_id: 92391731239,
                                     status: "saved",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: { order_amt: "$6.89",
                             grand_total: "7.30",
                             lead_times_array:[1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456,
                                               1415830516, 1415830576, 1415830636, 1415830696, 1415830756, 1415830816,
                                               1415830876, 1415830936, 1415830996, 1415831056, 1415831356, 1415831656,
                                               1415831956, 1415832256, 1415832556, 1415832856, 1415833156, 1415833456,
                                               1415833756, 1415834056, 1415834356, 1415834656, 1415834956, 1415835256,
                                               1415835556, 1415835856, 1415836756, 1415837656, 1415838556, 1415839456,
                                               1415840356, 1415841256, 1415842156, 1415843056, 1415843956],
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "5000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479804",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Tip",
                                                                amount: "$0.00" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] } })

    ## sign in user ##
    visit root_path
    feature_sign_in

    ## go to my order / checkout ##
    visit_merchant_buy_and_checkout(@merchant)

    ## verify checkout page content ##
    within("nav") do
      expect(page).not_to have_content("0")
      expect(page).not_to have_content("My order")
    end

    expect(page).to have_content "Place order"

    within "#details" do
      expect(page).to have_content "Select a pickup time"
      expect(page).to have_content "Select a tip"
      expect(page).to have_content "Order notes"
      expect(page).to have_content "Payment information"
      expect(page).to have_selector "button", text: "Place order ($7.30)"
    end

    within "#summary" do
      expect(page).to have_content "1234 Bacon Lane"
      expect(page).to have_content "Deadwood, SD"
      expect(page).to have_content "(222) 444-8899"
      expect(page).to have_content "Pastrami Salad"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Subtotal"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Tip"
      expect(page).to have_content "$0.00"
      expect(page).to have_content "Tax"
      expect(page).to have_content "$0.41"
      expect(page).to have_content "Promo Discount"
      expect(page).to have_content "Add promotional code"
      expect(page).to have_content "$7.30"

      expect(page).to_not have_content "Place order ($7.30)"
    end

    ## change some stuff ##
    find("#time #time").find(:xpath, "option[2]").select_option

    find(".credit-card label").click

    find("#tip #tip").find(:xpath, "option[4]").select_option

    expect(page).to have_content("250")
    fill_in("Order notes", with: "Something with bacon, please.")
    expect(page).to have_content("221")


    ## get selected detail order
    time = find("#time #time").find(:xpath, "option[2]").text
    tip = find("#tip #tip").find(:xpath, "option[4]").text
    note = find("#note").value

    ## verify changes to page content ##
    within "#details" do
      expect(page).to have_selector "button"
    end

    within "#summary" do
      expect(page).to have_content "$0.41"
      expect(page).to have_content "$1.03"
      expect(page).to have_content "$8.33"
    end

    ## submit invalid order ##
    stubs_invalid_order("There was a problem with that order.")

    find_button("Place order ").click

    # verify modal
    verify_error_modal("There was a problem with that order.")

    ## verify order failed ##
    expect(page).to have_content "There was a problem with that order."

    expect(page).to have_content "Place order"

    ## if input fields for order detail is saved
    expect(time).to eq(find("#time #time").find(:xpath, "option[2]").text)
    expect(tip).to eq(find("#tip #tip").find(:xpath, "option[4]").text)
    expect(note).to eq(find("#note").value)

    within "#details" do
      expect(page).to have_content "Select a pickup time"
      expect(page).to have_content "Select a tip"
      expect(page).to have_content "Order notes"
      expect(page).to have_content "Payment information"
      expect(page).to have_selector "button", text: "Place order "
    end

    within "#summary" do
      expect(page).to have_content "1234 Bacon Lane"
      expect(page).to have_content "Deadwood, SD"
      expect(page).to have_content "(222) 444-8899"
      expect(page).to have_content "Pastrami Salad"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Subtotal"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Tax"
      expect(page).to have_content "$0.41"
      expect(page).to have_content "Tip"
      expect(page).to have_content "$1.03"
      expect(page).to have_content "Discount"
      expect(page).to have_content "Add promotional code"
      expect(page).to have_content "$8.33"
    end

    ## change some stuff ##
    find(".credit-card label").click
    find("#time #time").find(:xpath, "option[2]").select_option
    find("#tip #tip").find(:xpath, "option[4]").select_option
    fill_in("Order notes", with: "Something with bacon, please.")

    ##save order detail data
    time = find("#time #time").find(:xpath, "option[2]").text
    tip = find("#tip #tip").find(:xpath, "option[4]").text
    note = find("#note").value

    ## verify changes to page content ##
    within "#details" do
      expect(page).to have_selector "button", text: "Place order"
    end

    within "#summary" do
      expect(page).to have_content "$1.03"
      expect(page).to have_content "$8.33"
    end

    # invalid promo error
    # TODO: change to new checkout stub
    promo_code_stubs("ASNDKASNDAS", "9705-j069h-ce8w3-425di", "-1.00", true, false)

    apply_promo_code("invalid")

    expect(URI.parse(current_url).request_uri).to include("/checkouts/new?merchant_id=4000")

    verify_error_modal("error_message")

    expect(page).to have_content "error_message"

    expect(find("input#promo_code", visible: false).value).to eq("")

    ## if input fields for order detail is saved
    expect(time).to eq(find("#time #time").find(:xpath, "option[2]").text)
    expect(tip).to eq(find("#tip #tip").find(:xpath, "option[4]").text)
    expect(note).to eq(find("#note").value)

    # requirement promo
    # TODO: change to new checkout stub
    promo_code_stubs("ASNDKASNDAS", "9705-j069h-ce8w3-425di", "0.00", true, true)

    apply_promo_code("lucky")

    expect(URI.parse(current_url).request_uri).to include("/checkouts/new?merchant_id=4000")

    expect(page).to have_content "Congratulations!  You're geting $1.00 off your current order!"

    # valid promo
    cart_promo_stub(auth_token: "ASNDKASNDAS",
                    cart_id: "9705-j069h-ce8w3-425di",
                    promo_code: "lucky",
                    message: "Congratulations!  You're geting $1.00 off your current order!",
                    return: { promo_amt: "-1.00",
                              grand_total: "6.30",
                              order_summary: { cart_items: [{ size_name: "Regular Pita",
                                                              item_name: "Awakin with Bacon",
                                                              item_price: "$6.89",
                                                              item_quantity: "1",
                                                              item_description: "White, Bacon, Eggs, Hashdevins, Onions, Green Peppers, Cheddar",
                                                              order_detail_id: "6098633",
                                                              item_note: "" }],
                                               receipt_items: [{ title: "Promo Discount",
                                                                 amount: "$-1.00" },
                                                               { title: "Subtotal",
                                                                 amount: "$6.89" },
                                                               { title: "Tax",
                                                                 amount: "$0.41" },
                                                               { title: "Tip",
                                                                 amount: "$0.00" },
                                                               { title: "Total",
                                                                 amount: "$6.30" }] },
                              user_info: { last_four: "1111" },
                              accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                                         name: "Cash",
                                                         splickit_accepted_payment_type_id: "1000",
                                                         billing_entity_id: "1006" },
                                                       { merchant_payment_type_map_id: "1066",
                                                         name: "Credit Card",
                                                         splickit_accepted_payment_type_id: "2000",
                                                         billing_entity_id: "1000" }],
                              ucid: "3623-6py84-7186j-m0445" })

    fill_in("Enter Promo Code", with: "lucky")
    click_button("Apply")

    expect(page).to have_content "Congratulations!  You're geting $1.00 off your current order!"

    within "#summary" do
      within "#promo-discount" do
        expect(page).to have_content "Promo Discount"
        expect(page).to have_content "$-1.00"
      end

      within "#total" do
        expect(page).to have_content "Total"
        expect(page).to have_content "$7.33"
      end
    end

    ## if input fields for order detail is saved
    expect(time).to eq(find("#time #time").find(:xpath, "option[2]").text)
    expect(tip).to eq(find("#tip #tip").find(:xpath, "option[4]").text)
    expect(note).to eq(find("#note").value)

    checkout_stubs(cart_id: "9705-j069h-ce8w3-425di",
                   body: { items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479804",
                                     status: "saved",
                                     external_detail_id: 92391731239,
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" },
                                   { item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     status: "new",
                                     external_detail_id: 92391731240,
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }] },
                   return: { order_amt: "$6.89",
                             promo_amt: "-1.00",
                             lead_times_array:[1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456,
                                               1415830516, 1415830576, 1415830636, 1415830696, 1415830756, 1415830816,
                                               1415830876, 1415830936, 1415830996, 1415831056, 1415831356, 1415831656,
                                               1415831956, 1415832256, 1415832556, 1415832856, 1415833156, 1415833456,
                                               1415833756, 1415834056, 1415834356, 1415834656, 1415834956, 1415835256,
                                               1415835556, 1415835856, 1415836756, 1415837656, 1415838556, 1415839456,
                                               1415840356, 1415841256, 1415842156, 1415843056, 1415843956],
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "5000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479804",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] },
                                                                                           { item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479807",
                                                                                             external_detail_id: "92391731240",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Promo Discount",
                                                                amount: "$-1.00" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] } })

    visit merchant_path(@merchant.merchant_id, menu_type: "pickup")
    expect(page).to have_content "PICKUP MENU"

    allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)

    first('article').click
    first('button.checkout').click

    expect(time).to eq(find("#time #time").find(:xpath, "option[2]").text)
    expect(tip).to eq(find("#tip #tip").find(:xpath, "option[4]").text)
    expect(note).to eq(find("#note").value)

    within "#summary" do
      within "#promo-discount" do
        expect(page).to have_content "Promo Discount"
        expect(page).to have_content "$-1.00"
      end
    end

    sleep 120

    expect(page).to have_content("Lead Times Expired")
    expect(page).to have_content("Your pick up / delivery times are no longer valid due to inactivity. Please press here to refresh the options")

    find("button.modal-close").click

    expect(URI.parse(current_url).request_uri).to eq(new_checkout_path(merchant_id: "4000", order_type: "pickup"))
  end

  it "show warning message when pickup/delivery time has been reset" do
    checkout_return = { order_amt: "$6.89",
                        grand_total: "7.30",
                        lead_times_array:[1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456,
                                          1415830516, 1415830576, 1415830636, 1415830696, 1415830756, 1415830816,
                                          1415830876, 1415830936, 1415830996, 1415831056, 1415831356, 1415831656,
                                          1415831956, 1415832256, 1415832556, 1415832856, 1415833156, 1415833456,
                                          1415833756, 1415834056, 1415834356, 1415834656, 1415834956, 1415835256,
                                          1415835556, 1415835856, 1415836756, 1415837656, 1415838556, 1415839456,
                                          1415840356, 1415841256, 1415842156, 1415843056, 1415843956],
                        accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                   name: "Cash",
                                                   splickit_accepted_payment_type_id: "5000",
                                                   billing_entity_id: nil },
                                                 { merchant_payment_type_map_id: "2000",
                                                   name: "Credit",
                                                   splickit_accepted_payment_type_id: "2000",
                                                   billing_entity_id: nil }],
                        order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                        item_price: "$6.89",
                                                        item_quantity: "1",
                                                        item_description: "Pastrami, salad, pretty much that's it",
                                                        order_detail_id: "27479804",
                                                        note: "" }],
                                         order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                              user_id: "4777193",
                                                                              items: [{ item_id: "931",
                                                                                        size_id: "1",
                                                                                        quantity: "1",
                                                                                        order_detail_id: "27479804",
                                                                                        external_detail_id: "92391731239",
                                                                                        status: "saved",
                                                                                        mods: [{ modifier_item_id: "2",
                                                                                                 mod_quantity: "1" }] }] },
                                         receipt_items: [{ title: "Subtotal",
                                                           amount: "$6.89" },
                                                         { title: "Tax",
                                                           amount: "$0.41" },
                                                         { title: "Tip",
                                                           amount: "$0.00" },
                                                         { title: "Total",
                                                           amount: "$7.30" }] } }

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   body: { user_id:"2",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     external_detail_id: 92391731239,
                                     status: "new",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: checkout_return)

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "9705-j069h-ce8w3-425di",
                   body: { user_id:"2",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479804",
                                     external_detail_id: 92391731239,
                                     status: "saved",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: checkout_return)

    ## sign in user ##
    visit root_path
    feature_sign_in

    ## go to my order / checkout ##

    visit_merchant_buy_and_checkout(@merchant)

    ## verify checkout page content ##
    within("nav") do
      expect(page).not_to have_content("0")
      expect(page).not_to have_content("My order")
    end

    expect(page).to have_content "Place order"

    within "#details" do
      expect(page).to have_content "Select a pickup time"
      expect(page).to have_content "Select a tip"
      expect(page).to have_content "Order notes"
      expect(page).to have_content "Payment information"
      expect(page).to have_selector "button", text: "Place order ($7.30)"
    end

    within "#summary" do
      expect(page).to have_content "1234 Bacon Lane"
      expect(page).to have_content "Deadwood, SD"
      expect(page).to have_content "(222) 444-8899"
      expect(page).to have_content "Pastrami Salad"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Subtotal"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Tip"
      expect(page).to have_content "$0.00"
      expect(page).to have_content "Tax"
      expect(page).to have_content "$0.41"
      expect(page).to have_content "Discount"
      expect(page).to have_content "Add promotional code"
      expect(page).to have_content "$7.30"

      expect(page).to_not have_content "Place order ($7.30)"
    end

    ## change some stuff ##
    find("#time #time").find(:xpath, "option[2]").select_option

    find(".credit-card label").click

    find("#tip #tip").find(:xpath, "option[4]").select_option

    expect(page).to have_content("250")
    fill_in("Order notes", with: "Something with bacon, please.")
    expect(page).to have_content("221")

    ## get selected detail order
    time = find("#time #time").find(:xpath, "option[2]").text
    tip = find("#tip #tip").find(:xpath, "option[4]").text
    note = find("#note").value

    ## verify changes to page content ##
    within "#details" do
      expect(page).to have_selector "button", text: "Place order "
    end

    within "#summary" do
      expect(page).to have_content "$0.41"
      expect(page).to have_content "$1.03"
      expect(page).to have_content "$8.33"
    end

    click_link("bob")
    click_link("Delivery address")

    expect(page).to have_content "Delivery address"

    first(".my-order-link").click
    first('button.checkout').click

    ## if input fields for order detail is saved
    expect(time).to eq(find("#time #time").find("option[selected]").text)
    expect(tip).to eq(find("#tip #tip").find(:xpath, "option[4]").text)
    expect(note).to eq(find("#note").value)

    within "#details" do
      expect(page).to have_content "Select a pickup time"
      expect(page).to have_content "Select a tip"
      expect(page).to have_content "Order notes"
      expect(page).to have_content "Payment information"
      expect(page).to have_selector "button", text: "Place order "
    end

    within "#summary" do
      expect(page).to have_content "1234 Bacon Lane"
      expect(page).to have_content "Deadwood, SD"
      expect(page).to have_content "(222) 444-8899"
      expect(page).to have_content "Pastrami Salad"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Subtotal"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Tax"
      expect(page).to have_content "$0.41"
      expect(page).to have_content "Tip"
      expect(page).to have_content "$1.03"
      expect(page).to have_content "Discount"
      expect(page).to have_content "Add promotional code"
      expect(page).to have_content "$8.33"
    end

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "9705-j069h-ce8w3-425di",
                   body: { user_id:"2",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479804",
                                     external_detail_id: 92391731239,
                                     status: "saved",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: checkout_return.merge(lead_times_array:[1415831056,1415831116,1415831176,1415831236,1415831296,
                                                                   1415831356,1415831416,1415831476,1415831536,1415831596,
                                                                   1415831656,1415831716,1415831776,1415831836,1415831896,
                                                                   1415831956,1415832256,1415832556,1415832856,1415833156,
                                                                   1415833456,1415833756,1415834056,1415834356,1415834656,
                                                                   1415834956,1415835256,1415835556,1415835856,1415836156,
                                                                   1415836456,1415836756,1415837656,1415838556,1415839456,
                                                                   1415840356,1415841256,1415842156,1415843056,1415843956,
                                                                   1415844856]))

    go_back_to_menu_and_checkout

    expect(page).to have_content "Place order"

    expect(find("#time #time").value).to eq("1415831056")

    expect(time).not_to eq(find("#time #time").find("option[selected]").text)
    expect(tip).to eq(find("#tip #tip").find(:xpath, "option[4]").text)
    expect(note).to eq(find("#note").value)

    time = find("#time #time").find("option[selected]").text

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "9705-j069h-ce8w3-425di",
                   body: { user_id:"2",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479804",
                                     external_detail_id: 92391731239,
                                     status: "saved",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: checkout_return.merge(lead_times_array: ["As soon as possible", 1415811056, 1415811100]))

    go_back_to_menu_and_checkout

    expect(page).to have_content "Place order"

    expect(find("#time #time").value).to eq("1415811100")

    expect(time).not_to eq(find("#time #time").find("option[selected]").text)

    ## Change to ASAP
    find("#time #time").find(:xpath, "option[1]").select_option

    time = find("#time #time").find("option[selected]").text

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "9705-j069h-ce8w3-425di",
                   body: { user_id:"2",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479804",
                                     external_detail_id: 92391731239,
                                     status: "saved",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: checkout_return.merge(lead_times_array: ["As soon as possible", 1415811056, 1415811100]))

    go_back_to_menu_and_checkout

    expect(page).to have_content "Place order"

    expect(find("#time #time").value).to eq("As soon as possible")

    time = find("#time #time").find("option[selected]").text

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "9705-j069h-ce8w3-425di",
                   body: { user_id:"2",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479804",
                                     external_detail_id: 92391731239,
                                     status: "saved",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: checkout_return.merge(lead_times_array: [1415811056, 1415811100]))

    go_back_to_menu_and_checkout

    expect(page).to have_content "Place order"

    expect(find("#time #time").value).to eq("1415811056")
  end

  it "allows a user place an order" do
    checkout_stubs(auth_token: "ASNDKASNDAS",
                   body: { user_id:"2",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     external_detail_id: 92391731239,
                                     status: "new",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: { order_amt: "$6.89",
                             grand_total: "7.30",
                             lead_times_array:[1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456,
                                               1415830516, 1415830576, 1415830636, 1415830696, 1415830756, 1415830816,
                                               1415830876, 1415830936, 1415830996, 1415831056, 1415831356, 1415831656,
                                               1415831956, 1415832256, 1415832556, 1415832856, 1415833156, 1415833456,
                                               1415833756, 1415834056, 1415834356, 1415834656, 1415834956, 1415835256,
                                               1415835556, 1415835856, 1415836756, 1415837656, 1415838556, 1415839456,
                                               1415840356, 1415841256, 1415842156, 1415843056, 1415843956],
                             user_info: { last_four: "1111" },
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "1000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit Card",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479804",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Tip",
                                                                amount: "$0.00" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] } })

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "9705-j069h-ce8w3-425di",
                   body: { user_id:"2",
                           merchant_id: "4000",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479804",
                                     external_detail_id: 92391731239,
                                     status: "saved",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }]},
                   return: { order_amt: "$6.89",
                             grand_total: "7.30",
                             lead_times_array:[1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456,
                                               1415830516, 1415830576, 1415830636, 1415830696, 1415830756, 1415830816,
                                               1415830876, 1415830936, 1415830996, 1415831056, 1415831356, 1415831656,
                                               1415831956, 1415832256, 1415832556, 1415832856, 1415833156, 1415833456,
                                               1415833756, 1415834056, 1415834356, 1415834656, 1415834956, 1415835256,
                                               1415835556, 1415835856, 1415836756, 1415837656, 1415838556, 1415839456,
                                               1415840356, 1415841256, 1415842156, 1415843056, 1415843956],
                             user_info: { last_four: "1111" },
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "1000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit Card",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479804",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Tip",
                                                                amount: "$0.00" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] } })

    ## sign in user ##
    visit root_path
    feature_sign_in

    ## go to my order / checkout ##
    visit_merchant_buy_and_checkout(@merchant)

    ## verify checkout page content ##
    within("nav") do
      expect(page).not_to have_content("0")
      expect(page).not_to have_content("My order")
    end

    expect(page).to have_content "Place order"

    within "#details" do
      expect(page).to have_content "Select a pickup time"
      expect(page).to have_content "Select a tip"
      expect(page).to have_content "Order notes"
      expect(page).to have_content "Payment information"
      expect(page).to have_selector "button", text: "Place order ($7.30)"
    end

    within "#summary" do
      expect(page).to have_content "1234 Bacon Lane"
      expect(page).to have_content "Deadwood, SD"
      expect(page).to have_content "(222) 444-8899"
      expect(page).to have_content "Pastrami Salad"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Subtotal"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Tip"
      expect(page).to have_content "$0.00"
      expect(page).to have_content "Tax"
      expect(page).to have_content "$0.41"
      expect(page).to have_content "Discount"
      expect(page).to have_content "Add promotional code"
      expect(page).to have_content "$7.30"

      expect(page).to_not have_content "Place order ($7.30)"
    end

    # List payments and names from API response
    within "#payment" do
      expect(page).to have_content("Cash")
      expect(page).to have_content("••••1111")
    end

    within "select#time" do
      lead_times = [1415830156,1415830216,1415830276,1415830336,1415830396,1415830456,1415830516,1415830576,1415830636,1415830696,1415830756,1415830816,1415830876,1415830936,1415830996,1415831056,1415831356,1415831656,1415831956,1415832256,1415832556,1415832856,1415833156,1415833456,1415833756,1415834056,1415834356,1415834656,1415834956,1415835256,1415835556,1415835856,1415836756,1415837656,1415838556,1415839456,1415840356,1415841256,1415842156,1415843056,1415843956]
      expect(page).to have_selector "option", count:41
      page.all('option').each_with_index  do |option, index|
        expect(option.text.strip).to eq (Time.at(lead_times[index]).utc + @merchant.time_zone_offset.to_i.hours).strftime("%l:%M %p").strip
      end
    end

    ## change some stuff ##
    find("#time #time").find(:xpath, "option[2]").select_option

    find(".credit-card label").click

    find("#tip #tip").find(:xpath, "option[4]").select_option

    expect(page).to have_content("250")
    fill_in("Order notes", with: "Something with bacon, please.")
    expect(page).to have_content("221")

    ## get selected detail order
    time = find("#time #time").find(:xpath, "option[2]").text
    tip = find("#tip #tip").find(:xpath, "option[4]").text
    note = find("#note").value

    ## verify changes to page content ##
    within "#details" do
      expect(page).to have_selector "button", text: "Place order "
    end

    within "#summary" do
      expect(page).to have_content "$0.41"
      expect(page).to have_content "$1.03"
      expect(page).to have_content "$8.33"
    end

    ## submit invalid order ##
    stubs_invalid_order("There was a problem with that order.")

    find_button("Place order ").click

    # verify modal
    verify_error_modal("There was a problem with that order.")

    ## verify order failed ##
    expect(page).to have_content "There was a problem with that order."

    expect(page).to have_content "Place order"

    # List payments and names from API response
    within "#payment" do
      expect(page).to have_content("Cash")
      expect(page).to have_content("••••1111")
    end

    ## if input fields for order detail is saved
    expect(time).to eq(find("#time #time").find(:xpath, "option[2]").text)
    expect(tip).to eq(find("#tip #tip").find(:xpath, "option[4]").text)
    expect(note).to eq(find("#note").value)

    within "#details" do
      expect(page).to have_content "Select a pickup time"
      expect(page).to have_content "Select a tip"
      expect(page).to have_content "Order notes"
      expect(page).to have_content "Payment information"
      expect(page).to have_selector "button", text: "Place order"
    end

    within "#summary" do
      expect(page).to have_content "1234 Bacon Lane"
      expect(page).to have_content "Deadwood, SD"
      expect(page).to have_content "(222) 444-8899"
      expect(page).to have_content "Pastrami Salad"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Subtotal"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Tax"
      expect(page).to have_content "$0.41"
      expect(page).to have_content "Tip"
      expect(page).to have_content "$1.03"
      expect(page).to have_content "Discount"
      expect(page).to have_content "Add promotional code"
      expect(page).to have_content "$8.33"
    end

    ## change some stuff ##
    find(".credit-card label").click
    find("#time #time").find(:xpath, "option[2]").select_option
    find("#tip #tip").find(:xpath, "option[4]").select_option
    fill_in("Order notes", with: "Something with bacon, please.")

    ##save order detail data
    time = find("#time #time").find(:xpath, "option[2]").text
    tip = find("#tip #tip").find(:xpath, "option[4]").text
    note = find("#note").value

    ## verify changes to page content ##
    within "#details" do
      expect(page).to have_selector "button", text: "Place order "
    end

    within "#summary" do
      expect(page).to have_content "$1.03"
      expect(page).to have_content "$8.33"
    end

    # invalid promo error
    # TODO: change to new checkout stub
    promo_code_stubs("ASNDKASNDAS", "9705-j069h-ce8w3-425di", "-1.00", true, false)

    apply_promo_code("invalid")

    expect(URI.parse(current_url).request_uri).to include("/checkouts/new?merchant_id=4000")

    verify_error_modal("error_message")

    expect(page).to have_content "error_message"

    expect(find("input#promo_code", visible: false).value).to eq("")

    ## if input fields for order detail is saved
    expect(time).to eq(find("#time #time").find(:xpath, "option[2]").text)
    expect(tip).to eq(find("#tip #tip").find(:xpath, "option[4]").text)
    expect(note).to eq(find("#note").value)


    # requirement promo
    # TODO: change to new checkout stub
    promo_code_stubs("ASNDKASNDAS", "9705-j069h-ce8w3-425di", "0.00", true, true)

    apply_promo_code("lucky")

    expect(URI.parse(current_url).request_uri).to include("/checkouts/new?merchant_id=4000")

    expect(page).to have_content "Congratulations! You're geting $1.00 off your current order!"

    # valid promo
    # TODO: change to new checkout stub
    promo_code_stubs("ASNDKASNDAS", "9705-j069h-ce8w3-425di", "-1.00", true, true)

    fill_in("Enter Promo Code", with: "lucky")
    click_button("Apply")

    expect(page).to have_content "Congratulations!  You're geting $1.00 off your current order!"

    within "#summary" do
      within "#promo-discount" do
        expect(page).to have_content "Promo Discount"
        expect(page).to have_content "$-1.00"
      end

      within "#total" do
        expect(page).to have_content "Total"
        expect(page).to have_content "$7.33"
      end
    end

    fill_in("Order notes", with: "extra salty lettuce please")

    ## submit valid order ##
    order_submit_stub(auth_token: "ASNDKASNDAS",
                      body: { user_id: "2",
                              cart_ucid: "9705-j069h-ce8w3-425di",
                              tip: "1.03",
                              note: "extra salty lettuce please",
                              merchant_payment_type_map_id: "1008",
                              requested_time: "1415830216" },
                      return: { order_id: "2474268",
                                stamp: "tweb03-i-027c8323-P5H9W6N",
                                merchant_id: "102237",
                                order_dt_tm: 1415802502,
                                user_id: "1469183",
                                pickup_dt_tm: 1415803380,
                                order_amt: "6.89",
                                promo_code: "",
                                promo_id: nil,
                                promo_amt: "0.00",
                                total_tax_amt: "0.41",
                                trans_fee_amt: "0.00",
                                delivery_amt: "0.00",
                                tip_amt: "0.00",
                                customer_donation_amt: "0.00",
                                grand_total: "6.30",
                                grand_total_to_merchant: 7.3,
                                cash: "N",
                                merchant_donation_amt: "0.00",
                                note: "extra salty lettuce please",
                                status: "O",
                                order_qty:"1",
                                payment_file: nil,
                                order_type: "R",
                                phone_no: nil,
                                user_delivery_location_id: nil,
                                requested_delivery_time: nil,
                                device_type: "web",
                                app_version: "3",
                                skin_id: "13",
                                distance_from_store: 0,
                                pickup_time_string: "2:43pm",
                                requested_time_string: "2:43pm",
                                user_message: "Your order to PitaPit will be ready for pickup at  2:43pm\\nPlease come again!",
                                user_message_title: "Order Info",
                                facebook: { facebook_title: "Ordered from PitaPit",
                                            facebook_caption: "I just ordered and paid at @PitaPitUSA, powered by @splickit web ordering. Cut the line, just grab and go!",
                                            facebook_slogan: "",
                                            facebook_thumbnail_url: "https://s3.amazonaws.com/splickit-mobile-assets/com.splickit.pitapit/icon_store.png",
                                            facebook_thumbnail_link: "http://itunes.apple.com/us/app/pita-pit/id461735388?mt=8",
                                            caption_link:"http://www.splickit.com",
                                            action_link:"http://itunes.apple.com/us/app/splick-it/id375047368?mt=8",
                                            action_text: "Get splick-it" },
                                twitter: { twitter_caption: "I just ordered and paid at @PitaPitUSA, powered by @splickit web ordering. Cut the line, just grab and go!" },
                                payment_service_used: "AccountCreditPaymentService",
                                points_earned: 6.89,
                                points_current: 556,
                                points_lifetime: 556,
                                order_items: nil,
                                additional_message: "Buy 3 Pitas Get 4th Free! Enter Promo Code LOLJK",
                                order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                item_price: "$6.89",
                                                                item_quantity: "1",
                                                                item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                order_detail_id: "6082213",
                                                                note: "" }],
                                                 receipt_items: [{ title: "Subtotal",
                                                                   amount: "$6.89" },
                                                                 { title: "Tax",
                                                                   amount: "$0.41" },
                                                                 { title: "Total",
                                                                   amount: "$7.30" }] },
                                loyalty_message: "You earned 7 points on this order." },
                        message: "Your order to PitaPit will be ready for pickup at  2:43pm\\nPlease come again!")

    find(".cash label").click

    find_button("Place order ").click

    ## verify confirmation page
    expect(URI.parse(current_url).request_uri).to eq("/last_order")
    expect(page).to have_content "Thanks! Your order has been placed."
    expect(page).to have_content "Buy 3 Pitas Get 4th Free! Enter Promo Code LOLJK"


    ## If there is no payment info it should not display this section
    expect(page).not_to have_css("section#loyalty")

    within("nav") do
      expect(page).not_to have_content("MY ORDER")
    end

    within "#details" do
      expect(page).to have_content "Order Notes: extra salty lettuce please"
      expect(page).to have_content "Pickup Time: 2:43pm"
      expect(page).to have_content "Order Number: 2474268"
      expect(page).to have_content "Email: bob@roberts.com"
      expect(page).to have_content "On pickup, just bypass the line and ask for your order."
      #Hidden because we need to think in the functionality for this button, but using Mapbox
      #expect(page).to have_content "Get Directions"
      #expect(page).to have_selector "a.primary-btn[href='https://maps.google.com/?q=1234%20Bacon%20Lane,%20Deadwood,%20SD']"
    end

    within "#summary" do
      expect(page).to have_content "Deadwood, SD"
      expect(page).to have_content "(222) 444-8899"

      within "#items" do
        expect(page).to have_content "Ham n' Eggs"
        expect(page).to have_content "$6.89"
        expect(page).to have_content "Cheddar Onions Green Peppers Eggs Hashbrowns"
      end

      within "#amounts" do
        expect(page).to have_content "Subtotal"
        expect(page).to have_content "$6.89"
        expect(page).to have_content "Tax"
        expect(page).to have_content "$0.41"
        expect(page).to_not have_content "Promo Discount"
        expect(page).to_not have_content "Add promotional code"
      end

      expect(page).to have_content "Total"
      expect(page).to have_content "$7.30"
    end
  end

  it "pick up time in place order" do
    ## sign in user ##
    visit root_path
    feature_sign_in

    ## go to my order / checkout ##
    visit merchant_path(@merchant.merchant_id, menu_type: "pickup")
    expect(page).to have_content "PICKUP MENU"

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   body: { items:[{ item_id: 931,
                                    quantity: 1,
                                    mods:[{ modifier_item_id: modifier_item_1.modifier_item_id,
                                            mod_quantity: 1,
                                            name: "Spicy Club Sauce" }],
                                    size_id: "1",
                                    order_detail_id: nil,
                                    external_detail_id: 92391731239,
                                    status: "new",
                                    points_used: nil,
                                    brand_points_id: nil,
                                    note: "" }] },
                   return: { grand_total: "7.30",
                             lead_times_array:[1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456,
                                               1415830516, 1415830576, 1415830636, 1415830696, 1415830756, 1415830816,
                                               1415830876, 1415830936, 1415830996, 1415831056, 1415831356, 1415831656,
                                               1415831956, 1415832256, 1415832556, 1415832856, 1415833156, 1415833456,
                                               1415833756, 1415834056, 1415834356, 1415834656, 1415834956, 1415835256,
                                               1415835556, 1415835856, 1415836756, 1415837656, 1415838556, 1415839456,
                                               1415840356, 1415841256, 1415842156, 1415843056, 1415843956, 1415912356,
                                               1415912656, 1415998756, 1415999056],
                             order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479804",
                                                             note: "" }],
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Tip",
                                                                amount: "$0.00" },
                                                              { title: "Total",
                                                                amount: "$7.30" }],
                                              order_data_as_ids_for_cart_update: { items: [{ order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved" }] } } })
    first('button.checkout').click

    ## verify checkout page content ##
    within("nav") do
      expect(page).not_to have_content("0")
      expect(page).not_to have_content("My order")
    end

    expect(page).to have_content "Place order"

    within "#details" do
      expect(page).to have_content "Select a pickup time"
      expect(page).to have_content "Select a tip"
      expect(page).to have_content "Order notes"
      expect(page).to have_content "Payment information"
      expect(page).to have_selector "button", text: "Place order "
    end

    within "#summary" do
      expect(page).to have_content "1234 Bacon Lane"
      expect(page).to have_content "Deadwood, SD"
      expect(page).to have_content "(222) 444-8899"
      expect(page).to have_content "Pastrami Salad"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Subtotal"
      expect(page).to have_content "$6.89"
      expect(page).to have_content "Tip"
      expect(page).to have_content "$0.00"
      expect(page).to have_content "Tax"
      expect(page).to have_content "$0.41"
      expect(page).to have_content "Promo Discount"
      expect(page).to have_content "Add promotional code"
      expect(page).to have_content "$7.30"

      expect(page).to_not have_content "Place order ($7.30)"
    end

    within "select#time" do
      lead_times = [1415830156,1415830216,1415830276,1415830336,1415830396,1415830456,1415830516,1415830576,1415830636,1415830696,1415830756,1415830816,1415830876,1415830936,1415830996,1415831056,1415831356,1415831656,1415831956,1415832256,1415832556,1415832856,1415833156,1415833456,1415833756,1415834056,1415834356,1415834656,1415834956,1415835256,1415835556,1415835856,1415836756,1415837656,1415838556,1415839456,1415840356,1415841256,1415842156,1415843056,1415843956, 1415912356, 1415912656, 1415998756, 1415999056]

      time_now = Time.now.utc + @merchant.time_zone_offset.to_i.hours

      end_of_day =  Time.new(time_now.year, time_now.month, time_now.day, 23, 59, 59, "+00:00").utc

      values_for_next_day = lead_times.count { |t| Time.at(t.to_i).utc + @merchant.time_zone_offset.to_i.hours > end_of_day}

      expect(page).to have_selector "option", count:45
      page.all('option').each_with_index  do |option, index|
        format = "%l:%M %p"
        current_time = Time.at(lead_times[index]).utc + @merchant.time_zone_offset.to_i.hours
        if values_for_next_day > 0
          format << if current_time <= end_of_day
                      " Today"
                    else
                      " %A"
                    end
        end
        expect(option.text.strip).to eq (current_time).strftime(format).strip
      end
    end
  end

  it "allows a user add a card if they do not have one and merchant supports credit cards" do
    checkout_stubs(auth_token: "ASNDKASNDAS",
                   body: { items:[{ item_id: 931,
                                    quantity: 1,
                                    mods:[{ modifier_item_id: modifier_item_1.modifier_item_id,
                                            mod_quantity: 1,
                                            name: "Spicy Club Sauce" }],
                                    size_id: "1",
                                    order_detail_id: nil,
                                    status: "new",
                                    external_detail_id: 92391731239,
                                    points_used: nil,
                                    brand_points_id: nil,
                                    note: "" }] },
                   return: { time_zone_string: "America/Denver",
                             time_zone_offset: -7,
                             lead_times_array: [1415833736, 1415833796, 1415833856, 1415833916, 1415833976,
                                                1415834036, 1415834096, 1415834156, 1415834216, 1415834276,
                                                1415834336, 1415834396, 1415834456, 1415834516, 1415834576,
                                                1415834636, 1415834936, 1415835236, 1415835536, 1415835836,
                                                1415836136, 1415836436, 1415836736, 1415837036, 1415837336,
                                                1415837636, 1415837936, 1415838236, 1415838536, 1415838836,
                                                1415839136, 1415839436, 1415840336, 1415841236, 1415842136,
                                                1415843036, 1415843936, 1415844836, 1415845736, 1415846636,
                                                1415847536 ],
                             order_amt: "2.30",
                             tip_array: [{ "No Tip" => 0 }, { "10%" => "0.23" }, { "15%" => "0.35" }, { "20%" => "0.46" },
                                         { "$1.00" => 1 }, { "$2.00" => 2 }, { "$3.00" => 3 }, { "$4.00" => 4 }, { "$5.00" => 5 },
                                         { "$6.00" => 6 }, { "$7.00" => 7 }, { "$8.00" => 8 }, { "$9.00" => 9 }, { "$10.00" => 10 },
                                         { "$11.00" => 11 }, { "$12.00" => 12 }, { "$13.00" => 13 }, { "$14.00" => 14 },
                                         { "$15.00" => 15 }, { "$16.00" => 16 }, { "$17.00" => 17 }, { "$18.00" => 18 },
                                         { "$19.00" => 19 }, { "$20.00" => 20 }, { "$21.00" => 21 }, { "$22.00" => 22 },
                                         { "$23.00" => 23 }, { "$24.00" => 24 }, { "$25.00" => 25 }],
                             total_tax_amt: "0.32",
                             user_info: { last_four: "1111" },
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1010",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "1000",
                                                        billing_entity_id: "1004"},
                                                      { merchant_payment_type_map_id: "1021",
                                                        name: "Credit Card",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: "1006"}],
                             order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                             item_price: "6.89",
                                                             item_quantity: "1",
                                                             item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                             order_detail_id: "6082053",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "new",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] },
                             ucid: "5668-x5z9f-s58hh-ed56a" })

    ## sign in user ##

    visit root_path
    sign_in_user_no_cc

    ## go to my order / checkout ##

    visit merchant_path(@merchant.merchant_id, menu_type: "pickup")
    expect(page).to have_content "PICKUP MENU"

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click
    first('button.checkout').click

    ## verify checkout page content ##
    #click_link "Add a new credit card"
    first('input[type=submit].add').click

    expect(URI.parse(current_url).request_uri).to eq("/user/payment")
  end

  it "allows a user add a card if is a button" do
    checkout_stubs(auth_token: "ASNDKASNDAS",
                       body: { items:[{ item_id: 931,
                                        quantity: 1,
                                        mods:[{ modifier_item_id: modifier_item_1.modifier_item_id,
                                                mod_quantity: 1,
                                                name: "Spicy Club Sauce" }],
                                        size_id: "1",
                                        order_detail_id: nil,
                                        status: "new",
                                        external_detail_id: 92391731239,
                                        points_used: nil,
                                        brand_points_id: nil,
                                        note: "" }] },
                       return: { time_zone_string: "America/Denver",
                                 time_zone_offset: -7,
                                 lead_times_array: [1415833736, 1415833796, 1415833856, 1415833916, 1415833976,
                                                    1415834036, 1415834096, 1415834156, 1415834216, 1415834276,
                                                    1415834336, 1415834396, 1415834456, 1415834516, 1415834576,
                                                    1415834636, 1415834936, 1415835236, 1415835536, 1415835836,
                                                    1415836136, 1415836436, 1415836736, 1415837036, 1415837336,
                                                    1415837636, 1415837936, 1415838236, 1415838536, 1415838836,
                                                    1415839136, 1415839436, 1415840336, 1415841236, 1415842136,
                                                    1415843036, 1415843936, 1415844836, 1415845736, 1415846636,
                                                    1415847536 ],
                                 order_amt: "2.30",
                                 tip_array: [{ "No Tip" => 0 }, { "10%" => "0.23" }, { "15%" => "0.35" }, { "20%" => "0.46" },
                                             { "$1.00" => 1 }, { "$2.00" => 2 }, { "$3.00" => 3 }, { "$4.00" => 4 }, { "$5.00" => 5 },
                                             { "$6.00" => 6 }, { "$7.00" => 7 }, { "$8.00" => 8 }, { "$9.00" => 9 }, { "$10.00" => 10 },
                                             { "$11.00" => 11 }, { "$12.00" => 12 }, { "$13.00" => 13 }, { "$14.00" => 14 },
                                             { "$15.00" => 15 }, { "$16.00" => 16 }, { "$17.00" => 17 }, { "$18.00" => 18 },
                                             { "$19.00" => 19 }, { "$20.00" => 20 }, { "$21.00" => 21 }, { "$22.00" => 22 },
                                             { "$23.00" => 23 }, { "$24.00" => 24 }, { "$25.00" => 25 }],
                                 total_tax_amt: "0.32",
                                 user_info: { last_four: "1111" },
                                 accepted_payment_types: [{ merchant_payment_type_map_id: "1010",
                                                            name: "Cash",
                                                            splickit_accepted_payment_type_id: "1000",
                                                            billing_entity_id: "1004"},
                                                          { merchant_payment_type_map_id: "1021",
                                                            name: "Credit Card",
                                                            splickit_accepted_payment_type_id: "2000",
                                                            billing_entity_id: "1006"}],
                                 order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                 item_price: "6.89",
                                                                 item_quantity: "1",
                                                                 item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                 order_detail_id: "6082053",
                                                                 note: "" }],
                                                  order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                       user_id: "4777193",
                                                                                       items: [{ item_id: "931",
                                                                                                 size_id: "1",
                                                                                                 quantity: "1",
                                                                                                 order_detail_id: "27479804",
                                                                                                 external_detail_id: "92391731239",
                                                                                                 status: "saved",
                                                                                                 mods: [{ modifier_item_id: "2",
                                                                                                          mod_quantity: "1" }] }] },
                                                  receipt_items: [{ title: "Subtotal",
                                                                    amount: "$6.89" },
                                                                  { title: "Tax",
                                                                    amount: "$0.41" },
                                                                  { title: "Total",
                                                                    amount: "$7.30" }] },
                                 ucid: "5668-x5z9f-s58hh-ed56a" })

    ## sign in user ##

    visit root_path
    sign_in_user_no_cc

    ## go to my order / checkout ##

    visit merchant_path(@merchant.merchant_id, menu_type: "pickup")
    expect(page).to have_content "PICKUP MENU"

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click
    first('button.checkout').click

    ## verify checkout page content ##
    # List payments and names from API response
    within "#payment" do
      expect(page).to have_content("Cash")
    end

    expect(page).to_not have_link "Add a new credit card"
    expect(page).to have_selector "input[type=submit].add", count: 1
  end

  it "allows a user replace a card if they have one and merchant supports credit cards" do
    checkout_stubs(auth_token: "ASNDKASNDAS",
                       body: { items:[{ item_id: 931,
                                        quantity: 1,
                                        mods:[{ modifier_item_id: modifier_item_1.modifier_item_id,
                                                mod_quantity: 1,
                                                name: "Spicy Club Sauce" }],
                                        size_id: "1",
                                        order_detail_id: nil,
                                        status: "new",
                                        external_detail_id: 92391731239,
                                        points_used: nil,
                                        brand_points_id: nil,
                                        note: ""}] },
                       return: { time_zone_string: "America/Denver",
                                 time_zone_offset: -7,
                                 lead_times_array: [1415833736, 1415833796, 1415833856, 1415833916, 1415833976,
                                                    1415834036, 1415834096, 1415834156, 1415834216, 1415834276,
                                                    1415834336, 1415834396, 1415834456, 1415834516, 1415834576,
                                                    1415834636, 1415834936, 1415835236, 1415835536, 1415835836,
                                                    1415836136, 1415836436, 1415836736, 1415837036, 1415837336,
                                                    1415837636, 1415837936, 1415838236, 1415838536, 1415838836,
                                                    1415839136, 1415839436, 1415840336, 1415841236, 1415842136,
                                                    1415843036, 1415843936, 1415844836, 1415845736, 1415846636,
                                                    1415847536 ],
                                 order_amt: "2.30",
                                 tip_array: [{ "No Tip" => 0 }, { "10%" => "0.23" }, { "15%" => "0.35" }, { "20%" => "0.46" },
                                             { "$1.00" => 1 }, { "$2.00" => 2 }, { "$3.00" => 3 }, { "$4.00" => 4 }, { "$5.00" => 5 },
                                             { "$6.00" => 6 }, { "$7.00" => 7 }, { "$8.00" => 8 }, { "$9.00" => 9 }, { "$10.00" => 10 },
                                             { "$11.00" => 11 }, { "$12.00" => 12 }, { "$13.00" => 13 }, { "$14.00" => 14 },
                                             { "$15.00" => 15 }, { "$16.00" => 16 }, { "$17.00" => 17 }, { "$18.00" => 18 },
                                             { "$19.00" => 19 }, { "$20.00" => 20 }, { "$21.00" => 21 }, { "$22.00" => 22 },
                                             { "$23.00" => 23 }, { "$24.00" => 24 }, { "$25.00" => 25 }],
                                 total_tax_amt: "0.32",
                                 user_info: { last_four: "1234", user_has_cc: true },
                                 accepted_payment_types: [{ merchant_payment_type_map_id: "1010",
                                                            name: "Cash",
                                                            splickit_accepted_payment_type_id: "1000",
                                                            billing_entity_id: "1004"},
                                                          { merchant_payment_type_map_id: "1021",
                                                            name: "Credit Card",
                                                            splickit_accepted_payment_type_id: "2000",
                                                            billing_entity_id: "1006"}],
                                 order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                 item_price: "6.89",
                                                                 item_quantity: "1",
                                                                 item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                 order_detail_id: "6082053",
                                                                 note: "" }],
                                                  order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                       user_id: "4777193",
                                                                                       items: [{ item_id: "931",
                                                                                                 size_id: "1",
                                                                                                 quantity: "1",
                                                                                                 order_detail_id: "27479804",
                                                                                                 external_detail_id: "92391731239",
                                                                                                 status: "saved",
                                                                                                 mods: [{ modifier_item_id: "2",
                                                                                                          mod_quantity: "1" }] }] },
                                                  receipt_items: [{ title: "Subtotal",
                                                                    amount: "$6.89" },
                                                                  { title: "Tax",
                                                                    amount: "$0.41" },
                                                                  { title: "Total",
                                                                    amount: "$7.30" }] },
                                 ucid: "5668-x5z9f-s58hh-ed56a" })

    ## sign in user ##
    visit root_path
    feature_sign_in

    ## go to my order / checkout ##
    visit merchant_path(@merchant.merchant_id, menu_type: "pickup")
    expect(page).to have_content "PICKUP MENU"

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click
    first('button.checkout').click

    ## verify checkout page content ##
    expect(page).to have_content("••••1234")
    first('input[type=submit].replace').click

    expect(URI.parse(current_url).request_uri).to eq("/user/payment")
  end

  it "allows a user replace a card if is a button" do
    checkout_stubs(auth_token: "ASNDKASNDAS",
                       body: { items:[{ item_id: 931,
                                        quantity: 1,
                                        mods:[{ modifier_item_id: modifier_item_1.modifier_item_id,
                                                mod_quantity: 1,
                                                name: "Spicy Club Sauce" }],
                                        size_id: "1",
                                        order_detail_id: nil,
                                        status: "new",
                                        external_detail_id: 92391731239,
                                        points_used: nil,
                                        brand_points_id: nil,
                                        note: "" }] },
                       return: { time_zone_string: "America/Denver",
                                 time_zone_offset: -7,
                                 lead_times_array: [1415833736, 1415833796, 1415833856, 1415833916, 1415833976,
                                                    1415834036, 1415834096, 1415834156, 1415834216, 1415834276,
                                                    1415834336, 1415834396, 1415834456, 1415834516, 1415834576,
                                                    1415834636, 1415834936, 1415835236, 1415835536, 1415835836,
                                                    1415836136, 1415836436, 1415836736, 1415837036, 1415837336,
                                                    1415837636, 1415837936, 1415838236, 1415838536, 1415838836,
                                                    1415839136, 1415839436, 1415840336, 1415841236, 1415842136,
                                                    1415843036, 1415843936, 1415844836, 1415845736, 1415846636,
                                                    1415847536 ],
                                 order_amt: "2.30",
                                 tip_array: [{ "No Tip" => 0 }, { "10%" => "0.23" }, { "15%" => "0.35" }, { "20%" => "0.46" },
                                             { "$1.00" => 1 }, { "$2.00" => 2 }, { "$3.00" => 3 }, { "$4.00" => 4 }, { "$5.00" => 5 },
                                             { "$6.00" => 6 }, { "$7.00" => 7 }, { "$8.00" => 8 }, { "$9.00" => 9 }, { "$10.00" => 10 },
                                             { "$11.00" => 11 }, { "$12.00" => 12 }, { "$13.00" => 13 }, { "$14.00" => 14 },
                                             { "$15.00" => 15 }, { "$16.00" => 16 }, { "$17.00" => 17 }, { "$18.00" => 18 },
                                             { "$19.00" => 19 }, { "$20.00" => 20 }, { "$21.00" => 21 }, { "$22.00" => 22 },
                                             { "$23.00" => 23 }, { "$24.00" => 24 }, { "$25.00" => 25 }],
                                 total_tax_amt: "0.32",
                                 user_info: { last_four: "1234", user_has_cc: true },
                                 accepted_payment_types: [{ merchant_payment_type_map_id: "1010",
                                                            name: "Cash",
                                                            splickit_accepted_payment_type_id: "1000",
                                                            billing_entity_id: "1004"},
                                                          { merchant_payment_type_map_id: "1021",
                                                            name: "Credit Card",
                                                            splickit_accepted_payment_type_id: "2000",
                                                            billing_entity_id: "1006"}],
                                 order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                 item_price: "6.89",
                                                                 item_quantity: "1",
                                                                 item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                 order_detail_id: "6082053",
                                                                 note: "" }],
                                                  order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                       user_id: "4777193",
                                                                                       items: [{ item_id: "931",
                                                                                                 size_id: "1",
                                                                                                 quantity: "1",
                                                                                                 order_detail_id: "27479804",
                                                                                                 external_detail_id: "92391731239",
                                                                                                 status: "saved",
                                                                                                 mods: [{ modifier_item_id: "2",
                                                                                                          mod_quantity: "1" }] }] },
                                                  receipt_items: [{ title: "Subtotal",
                                                                    amount: "$6.89" },
                                                                  { title: "Tax",
                                                                    amount: "$0.41" },
                                                                  { title: "Total",
                                                                    amount: "$7.30" }] },
                                 ucid: "5668-x5z9f-s58hh-ed56a" })

    ## sign in user ##
    visit root_path
    feature_sign_in

    ## go to my order / checkout ##
    visit merchant_path(@merchant.merchant_id, menu_type: "pickup")
    expect(page).to have_content "PICKUP MENU"

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click
    first('button.checkout').click

    ## verify checkout page content ##
    expect(page).to have_content("••••1234")
    expect(page).to_not have_link "Replace your credit card"
    expect(page).to have_selector "input[type=submit].replace",  count: 1
  end

  context "delivery order" do
    let(:checkout_body_hash) do
      { user_addr_id: "5667",
        merchant_id: "103893",
        submitted_order_type: "delivery",
        items: [{ item_id: 931,
                  quantity: 1,
                  mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                           mod_quantity: 1,
                           name: "Spicy Club Sauce" }],
                  size_id: "1",
                  order_detail_id: nil,
                  status: "new",
                  external_detail_id: 92391731239,
                  points_used: nil,
                  brand_points_id: nil,
                  note: "extra crispy hashtags please" }],
        total_points_used: 0 }
    end

    let(:checkout_return_hash) do
      { time_zone_string: "America/Denver",
        time_zone_offset: -7,
        lead_times_array: [1415833736, 1415833796, 1415833856, 1415833916, 1415833976,
                           1415834036, 1415834096, 1415834156, 1415834216, 1415834276,
                           1415834336, 1415834396, 1415834456, 1415834516, 1415834576,
                           1415834636, 1415834936, 1415835236, 1415835536, 1415835836,
                           1415836136, 1415836436, 1415836736, 1415837036, 1415837336,
                           1415837636, 1415837936, 1415838236, 1415838536, 1415838836,
                           1415839136, 1415839436, 1415840336, 1415841236, 1415842136,
                           1415843036, 1415843936, 1415844836, 1415845736, 1415846636,
                           1415847536],
        order_amt: "2.30",
        grand_total: "13.30",
        tip_array: get_tip_array(order_amt: 2.3, porcentage: [10, 15, 20]),
        total_tax_amt: "0.32",
        user_info: { last_four: "1111" },
        accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                   name: "Cash",
                                   splickit_accepted_payment_type_id: "1000",
                                   billing_entity_id: nil },
                                 { merchant_payment_type_map_id: "2000",
                                   name: "Credit Card",
                                   splickit_accepted_payment_type_id: "2000",
                                   billing_entity_id: nil }],
        order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                        item_price: "$6.89",
                                        item_quantity: "1",
                                        item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                        order_detail_id: "6082053",
                                        item_note: "extra crispy hashtags please" }],
                         order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                              user_id: "4777193",
                                                              items: [{ item_id: "931",
                                                                        size_id: "1",
                                                                        quantity: "1",
                                                                        order_detail_id: "27479804",
                                                                        external_detail_id: "92391731239",
                                                                        status: "saved",
                                                                        mods: [{ modifier_item_id: "2",
                                                                                 mod_quantity: "1" }] }] },
                         receipt_items: [{ title: "Subtotal",
                                           amount: "$6.89" },
                                         { title: "Tax",
                                           amount: "$0.41" },
                                         { title: "Total",
                                           amount: "$13.30" },
                                         { title: "Delivery Fee",
                                           amount: "$1.00" },
                                         { title: "Convenience Fee",
                                           amount: "$5.00" }]
        },
        ucid: "9705-j069h-ce8w3-425di" }
    end

    before do
      stub_merchants_for_zip("80305")
      stub_signed_in_merchants_for_zip("80305")

      checkout_stubs(auth_token: "ASNDKASNDAS",
                         body: checkout_body_hash,
                         return: checkout_return_hash)

      @merchant.merchant_id = "103893"

      merchant_find_stub(auth_token: "ASNDKASNDAS",
                         merchant_id: "103893",
                         delivery: true,
                         return: @merchant.as_json(root: false))

      order_submit_stub(auth_token: "ASNDKASNDAS",
                        body: { user_id: "2",
                                cart_ucid: "9705-j069h-ce8w3-425di",
                                tip: "0.34",
                                note: "Something with bacon, please.",
                                merchant_payment_type_map_id: "2000",
                                delivery_time: "Wed 11-12 06:09 PM",
                                requested_time: "1415833796" },
                        return: { order_id: "2474268",
                                  stamp: "tweb03-i-027c8323-P5H9W6N",
                                  merchant_id: "102237",
                                  order_dt_tm: 1415802502,
                                  user_id: "1469183",
                                  pickup_dt_tm: 1415803380,
                                  order_amt: "$6.89",
                                  promo_code: "",
                                  promo_id: nil,
                                  promo_amt: "0.00",
                                  total_tax_amt: "0.41",
                                  trans_fee_amt: "0.00",
                                  delivery_amt: "0.00",
                                  tip_amt: "0.00",
                                  customer_donation_amt: "0.00",
                                  grand_total: "7.30",
                                  grand_total_to_merchant: 7.3,
                                  cash: "N",
                                  merchant_donation_amt: "0.00",
                                  note: "",
                                  status: "O",
                                  order_qty: "1",
                                  payment_file: nil,
                                  order_type: "R",
                                  phone_no: nil,
                                  user_delivery_location_id: "5667",
                                  requested_delivery_time: nil,
                                  device_type: "web",
                                  app_version: "3",
                                  skin_id: "13",
                                  distance_from_store: 0,
                                  pickup_time_string: "2:43pm",
                                  requested_time_string: "2:43pm",
                                  user_message: "Your order to PitaPit will be ready for pickup at 4:19pm",
                                  user_message_title: "Order Info",
                                  facebook: {
                                    facebook_title: "Ordered from PitaPit",
                                    facebook_caption: "I just ordered and paid at @PitaPitUSA, powered by @splickit web ordering. Cut the line, just grab and go!",
                                    facebook_slogan: "",
                                    facebook_thumbnail_url: "https://s3.amazonaws.com/splickit-mobile-assets/com.splickit.pitapit/icon_store.png",
                                    facebook_thumbnail_link: "http://itunes.apple.com/us/app/pita-pit/id461735388?mt=8",
                                    caption_link: "http://www.splickit.com",
                                    action_link: "http://itunes.apple.com/us/app/splick-it/id375047368?mt=8",
                                    action_text: "Get splick-it"
                                  },
                                  twitter: {
                                    twitter_caption: "I just ordered and paid at @PitaPitUSA, powered by @splickit web ordering. Cut the line, just grab and go!"
                                  },
                                  payment_service_used: "AccountCreditPaymentService",
                                  points_earned: 6.89,
                                  points_current: 556,
                                  points_lifetime: 556,
                                  order_items: nil,
                                  user_delivery_address: { user_addr_id: "5667",
                                                           user_id: "2",
                                                           name: "Metro Wastewater Reclamation Plant",
                                                           business_name: "Basement Company",
                                                           address1: "6450 York St",
                                                           address2: "Basement",
                                                           city: "Denver",
                                                           state: "CO",
                                                           zip: "80229",
                                                           lat: "39.8149386187446",
                                                           lng: "-104.956209155655",
                                                           phone_no: "(303) 286-3000",
                                                           instructions: "wear cruddy shoes" },
                                  order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                  item_price: "$6.89",
                                                                  item_quantity: "1",
                                                                  item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                  order_detail_id: "6082213",
                                                                  item_note: "extra crispy hashtags please" }],
                                                   receipt_items: [{ title: "Subtotal",
                                                                     amount: "$6.89" },
                                                                   { title: "Tax",
                                                                     amount: "$0.41" },
                                                                   { title: "Convenience Fee",
                                                                     amount: "$5.00" },
                                                                   { title: "total",
                                                                     amount: "$13.30" }] },
                                  loyalty_message: "You earned 7 points on this order." },
                        message: "Your order number is 2463458 and will be delivered to: 6450 York St Denver, CO 80229")

      visit root_path

      feature_sign_in

      fill_in "location", with: "80305"
      click_button "Search"
    end

    context "user with business name address" do
      before do
        feature_sign_out
        feature_sign_in(user_return: get_user_data_with_business_name)

        fill_in "location", with: "80305"
        click_button "Search"

        merchant_indeliveryarea_stub(auth_token: "ASNDKASNDAS", merchant_id: "103893", delivery_address_id: 5667,
                                     return: { is_in_delivery_range: true }, message: nil)

        find(".delivery.button").click
      end

      it "should display delivery name on checkout and confirmation pages" do
        within("#select-address") do
          find(".set-btn.secondary").click
        end

        expect(page).to have_content "DELIVERY MENU"

        # Verify item prices and layout
        verify_zero_item(932)
        verify_non_zero_item(931, 6.65)

        first("article").click

        within("#requests") do
          fill_in("Extra ingredients may result in additional charges", with: "extra crispy hashtags please")
        end

        first("button.checkout").click

        expect(page).to have_content("Place order - Delivery")

        expect(page).to have_content("Delivering to:")
        expect(page).to have_content("Basement Company")
        expect(page).to have_content("6450 York St, Denver, CO 80229")
        expect(page).to have_content("Note: extra crispy hashtags please")


        within("#delivery-fee") do
          expect(page).to have_content("Delivery Fee")
          expect(page).to have_content("$1.00")
        end

        within("#convenience-fee") do
          expect(page).to have_content("Convenience Fee")
          expect(page).to have_content("$5.00")
        end

        # List payments and names from API response
        within "#payment" do
          expect(page).to have_content("Cash")
          expect(page).to have_content("••••1111")
        end

        find(".credit-card label").click
        find("#time #time").find(:xpath, "option[2]").select_option
        find("#tip #tip").find(:xpath, "option[4]").select_option
        fill_in("Order notes", with: "Something with bacon, please.")

        find_button("Place order ").click

        expect(URI.parse(current_url).request_uri).to eq("/last_order")

        expect(page).to have_content "Thanks! Your order has been placed."
        expect(page).to have_content("Note: extra crispy hashtags please")

        within "#details" do
          expect(page).to have_content "Order Number:"
          expect(page).to have_content "2474268"
          expect(page).to have_content "Delivery Address:"
          expect(page).to have_content "6450 York St, Denver, CO 80229"
          expect(page).to have_content "Email:"
          expect(page).to have_content "bob@roberts.com"
        end

        within "#convenience-fee" do
          expect(page).to have_content "Convenience Fee"
          expect(page).to have_content "$5.00"
        end
      end
    end

    it "should be redirect to merchant after adding a new address" do
      find('.delivery.button').click
      find('.new-address-btn.primary').click
      expect(URI.parse(current_url).request_uri).to eq("/user/address/new?path=%2Fmerchants%2F103893%3Forder_type%3Ddelivery")

      stubs_delivery_address_for_redirect_to_merchants

      fill_in("Business Name", with: "Geisty's Company")
      fill_in("Street address", with: "1116 13th Street")
      fill_in("Suite / Apt", with: "St")
      fill_in("City", with: "Geisty's Dogg House, Boulder")
      fill_in("State", with: "CO")
      fill_in("Zip", with: "80305")
      fill_in("Phone number", with: "1234567890")
      fill_in("The doorbell is broken; please knock.", with: "Don't mind the sock.")
      click_button("Add delivery address")

      expect(URI.parse(current_url).request_uri).to eq("/merchants/103893?order_type=delivery&user_addr_id=202402")
    end

    it "should be redirect to merchant after adding a new address with invalid data" do
      find('.delivery.button').click
      find('.new-address-btn.primary').click
      expect(URI.parse(current_url).request_uri).to eq("/user/address/new?path=%2Fmerchants%2F103893%3Forder_type%3Ddelivery")

      fill_in("Business Name", with: "Tests Corporation")
      fill_in("Street address", with: "1116 13th Street")
      fill_in("Suite / Apt", with: "St")
      fill_in("City", with: "")
      fill_in("State", with: "CO")
      fill_in("Zip", with: "")
      fill_in("Phone number", with: "1234567890")
      fill_in("The doorbell is broken; please knock.", with: "Don't mind the sock.")
      click_button("Add delivery address")

      expect(URI.parse(current_url).request_uri).to eq("/user/address?path=%2Fmerchants%2F103893%3Forder_type%3Ddelivery")
    end

    it "allows to change from delivery to pickup" do
      merchant_indeliveryarea_stub(auth_token: "ASNDKASNDAS", merchant_id: "103893", delivery_address_id: 5667,
                                   return: { is_in_delivery_range: true }, message: nil)

      find(".delivery.button").click

      within("#select-address") do
        find(".set-btn.secondary").click
      end

      first("article").click

      within("#requests") do
        fill_in("Extra ingredients may result in additional charges", with: "extra crispy hashtags please")
      end

      first("button.checkout").click

      first("a.logo").click

      expect(WebMock).to have_requested(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/cart/")
                           .with(body: hash_including(submitted_order_type: "delivery", user_addr_id: "5667"))

      merchant_find_stub(auth_token: "ASNDKASNDAS", merchant_id: "103893", delivery: false,
                         return: @merchant.as_json(root: false))

      all(".pickup.button")[1].click

      find(".my-order-link").click

      checkout_body_hash.merge!(items: [{ item_id: 931,
                                          quantity: 1,
                                          mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                                   mod_quantity: 1,
                                                   name: "Spicy Club Sauce" }],
                                          size_id: "1",
                                          order_detail_id: "27479804",
                                          status: "saved",
                                          external_detail_id: 92391731239,
                                          points_used: nil,
                                          brand_points_id: nil,
                                          note: "extra crispy hashtags please" }],
                                submitted_order_type: "pickup",
                                user_addr_id: nil)

      checkout_stubs(auth_token: "ASNDKASNDAS",
                     cart_id: "9705-j069h-ce8w3-425di",
                     body: checkout_body_hash,
                     return: checkout_return_hash)

      first("button.checkout").click

      first("a.logo").click

      expect(WebMock).to have_requested(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/cart/9705-j069h-ce8w3-425di")
                           .with(body: hash_including(submitted_order_type: "pickup", user_addr_id: nil))

      find(".delivery.button").click

      within("#select-address") do
        find(".set-btn.secondary").click
      end

      find(".my-order-link").click

      checkout_stubs(auth_token: "ASNDKASNDAS",
                     cart_id: "9705-j069h-ce8w3-425di",
                     body: checkout_body_hash.merge(submitted_order_type: "delivery", user_addr_id: "5667"),
                     return: checkout_return_hash)

      first("button.checkout").click

      first("a.logo").click

      expect(WebMock).to have_requested(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/cart/9705-j069h-ce8w3-425di")
                           .with(body: hash_including(submitted_order_type: "delivery", user_addr_id: "5667"))
    end

    it "allows a user place a delivery order" do
      merchant_indeliveryarea_stub(auth_token: "ASNDKASNDAS", merchant_id: "103893", delivery_address_id: 5667,
                                   return: { is_in_delivery_range: false }, message: nil)

      find(".delivery.button").click

      within("#select-address") do
        find(".set-btn.secondary").click
      end

      expect(page).to have_content "ENTER CITY, STATE OR ZIP"
      expect(page).to have_content "Sorry, that address isn't in range."

      find(".delivery.button").click

      merchant_indeliveryarea_stub(auth_token: "ASNDKASNDAS", merchant_id: "103893", delivery_address_id: 5667,
                                   return: { is_in_delivery_range: true }, message: nil)

      within("#select-address") do
        find(".set-btn.secondary").click
      end

      expect(page).to have_content "DELIVERY MENU"

      # Verify item prices and layout
      verify_zero_item(932)
      verify_non_zero_item(931, 6.65)

      first("article").click

      within("#requests") do
        fill_in("Extra ingredients may result in additional charges", with: "extra crispy hashtags please")
      end

      first("button.checkout").click

      expect(page).to have_content("Place order - Delivery")

      expect(page).to have_content("Delivering to:")
      expect(page).to have_content("6450 York St, Denver, CO 80229")
      expect(page).to have_content("Note: extra crispy hashtags please")


      within("#delivery-fee") do
        expect(page).to have_content("Delivery Fee")
        expect(page).to have_content("$1.00")
      end

      within("#convenience-fee") do
        expect(page).to have_content("Convenience Fee")
        expect(page).to have_content("$5.00")
      end

      # List payments and names from API response
      within "#payment" do
        expect(page).to have_content("Cash")
        expect(page).to have_content("••••1111")
      end

      find(".credit-card label").click
      find("#time #time").find(:xpath, "option[2]").select_option
      find("#tip #tip").find(:xpath, "option[4]").select_option
      fill_in("Order notes", with: "Something with bacon, please.")

      find_button("Place order ").click

      expect(URI.parse(current_url).request_uri).to eq("/last_order")

      expect(page).to have_content("Thanks! Your order has been placed.")
      expect(page).to have_content("Note: extra crispy hashtags please")

      ## If there is no payment info it should not display this section
      expect(page).not_to have_css("section#loyalty")

      within "#details" do
        expect(page).to have_content "Order Number:"
        expect(page).to have_content "2474268"
        expect(page).to have_content "Delivery Address:"
        expect(page).to have_content "6450 York St, Denver, CO 80229"
        expect(page).to have_content "Email:"
        expect(page).to have_content "bob@roberts.com"
      end

      within "#convenience-fee" do
        expect(page).to have_content "Convenience Fee"
        expect(page).to have_content "$5.00"
      end
    end
  end

  it "displays an error message when error returned from /cart/checkout" do
    visit root_path

    feature_sign_in

    ## go to my order / checkout ##
    visit merchant_path(@merchant.merchant_id, order_type: "pickup")

    allow(API).to receive_message_chain(:post, :status) { 402 }
    allow(API).to receive_message_chain(:post, :body) { { error: { error: "Sorry, something has changed with this merchant." } }.to_json }

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click
    first('button.checkout').click

    expect(URI.parse(current_url).request_uri).to eq(merchant_path(id: @merchant.merchant_id, order_type: "pickup"))
    expect(page).to have_content "Sorry, something has changed with this merchant."
  end

  it "disables the tip dropdown when the user selects cash" do
    checkout_stubs(auth_token: "ASNDKASNDAS",
                   body: { items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1, name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     status: "new",
                                     external_detail_id: 92391731239,
                                     points_used: nil,
                                     brand_points_id: nil, note: "" }] },
                   return: { lead_times_array: [1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456, 1415830516,
                                                1415830576, 1415830636, 1415830696, 1415830756, 1415830816, 1415830876, 1415830936,
                                                1415830996, 1415831056, 1415831356, 1415831656, 1415831956, 1415832256, 1415832556,
                                                1415832856, 1415833156, 1415833456, 1415833756, 1415834056, 1415834356, 1415834656,
                                                1415834956, 1415835256, 1415835556, 1415835856, 1415836756, 1415837656, 1415838556,
                                                1415839456, 1415840356, 1415841256, 1415842156, 1415843056, 1415843956 ],
                             order_amt: "$6.89",
                             user_info: { last_four: "1111" },
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "1000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2008",
                                                        name: "Credit Card",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                             item_price: "6.89",
                                                             item_quantity: "1",
                                                             item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                             order_detail_id: "6082053",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] },
                             ucid: "5570-01bpq-gb5qf-7609e" })

    visit root_path
    feature_sign_in

    visit merchant_path(@merchant.merchant_id, menu_type: 'pickup')

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click
    first('button.checkout').click

    find(".cash label").click

    # List payments and names from API response
    within "#payment" do
      expect(page).to have_content("Cash")
      expect(page).to have_content("••••1111")
    end

    select = find 'select#tip'
    expect(select['disabled']).to be_truthy

    first('div.payment-type.credit-card label').click

    expect(select['disabled']).to be_falsey
  end

  it "allows the user to delete / edit items on the checkout page" do
    checkout_stubs(auth_token: "ASNDKASNDAS",
                   body: { items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     status: "new",
                                     external_detail_id: 92391731239,
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" },
                                   { item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     status: "new",
                                     external_detail_id: 92391731240,
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }] },
                   return: { lead_times_array: [ 1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456, 1415830516,
                                                 1415830576, 1415830636, 1415830696, 1415830756, 1415830816, 1415830876, 1415830936,
                                                 1415830996, 1415831056, 1415831356, 1415831656, 1415831956, 1415832256, 1415832556,
                                                 1415832856, 1415833156, 1415833456, 1415833756, 1415834056, 1415834356, 1415834656,
                                                 1415834956, 1415835256, 1415835556, 1415835856, 1415836756, 1415837656, 1415838556,
                                                 1415839456, 1415840356, 1415841256, 1415842156, 1415843056, 1415843956 ],
                             order_amt: "$6.89",
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "1000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479804",
                                                             note: "" },
                                                           { item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479807",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" },
                                                                                             ] },
                                                                                           { item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479807",
                                                                                             external_detail_id: "92391731240",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" },
                                                                                             ] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] },
                             ucid: "5570-01bpq-gb5qf-7609e" })

    ## sign in user ##
    visit root_path
    feature_sign_in

    ## go to my order / checkout ##
    visit merchant_path(@merchant.merchant_id, menu_type: "pickup")

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click
    first('button.add').click

    allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)

    first('article').click
    first('button.checkout').click

    expect(page).to have_content("Pastrami Salad", count: 2)

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "5570-01bpq-gb5qf-7609e",
                   body: { items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479804",
                                     status: "deleted",
                                     external_detail_id: 92391731239,
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" },
                                   { item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479807",
                                     status: "saved",
                                     external_detail_id: 92391731240,
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }] },
                   return: { lead_times_array: [ 1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456, 1415830516,
                                                 1415830576, 1415830636, 1415830696, 1415830756, 1415830816, 1415830876, 1415830936,
                                                 1415830996, 1415831056, 1415831356, 1415831656, 1415831956, 1415832256, 1415832556,
                                                 1415832856, 1415833156, 1415833456, 1415833756, 1415834056, 1415834356, 1415834656,
                                                 1415834956, 1415835256, 1415835556, 1415835856, 1415836756, 1415837656, 1415838556,
                                                 1415839456, 1415840356, 1415841256, 1415842156, 1415843056, 1415843956 ],
                             order_amt: "$6.89",
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "1000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479807",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479807",
                                                                                             external_detail_id: "92391731240",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] },
                             ucid: "5570-01bpq-gb5qf-7609e" })

    first(".remove-item").click

    expect(page).to have_content("Pastrami Salad", count: 1)

    first(".remove-item").click

    expect(page).to have_content("Your cart is empty.")
    expect(page).to have_content("Please add items before checking out.")

    click_link "Add more items"

    expect(page).to have_content("PICKUP MENU")

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "5570-01bpq-gb5qf-7609e",
                   body: { items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: "27479807",
                                     status: "deleted",
                                     external_detail_id: 92391731240,
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" },
                                   { item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     status: "new",
                                     external_detail_id: 92391731242,
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "" }] },
                   return: { lead_times_array: [ 1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456, 1415830516,
                                                 1415830576, 1415830636, 1415830696, 1415830756, 1415830816, 1415830876, 1415830936,
                                                 1415830996, 1415831056, 1415831356, 1415831656, 1415831956, 1415832256, 1415832556,
                                                 1415832856, 1415833156, 1415833456, 1415833756, 1415834056, 1415834356, 1415834656,
                                                 1415834956, 1415835256, 1415835556, 1415835856, 1415836756, 1415837656, 1415838556,
                                                 1415839456, 1415840356, 1415841256, 1415842156, 1415843056, 1415843956 ],
                             order_amt: "$6.89",
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "1000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479809",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479809",
                                                                                             external_detail_id: "92391731242",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" },
                                                                                             ] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] },
                             ucid: "5570-01bpq-gb5qf-7609e" })

    allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731242)

    first('article').click
    first('button.checkout').click

    expect(page).to have_content "Pastrami, salad, pretty much that's it"

    checkout_stubs(auth_token: "ASNDKASNDAS",
                   cart_id: "5570-01bpq-gb5qf-7609e",
                   body: { items: [{ item_id: "931",
                                     quantity: "1",
                                     mods: { "0" => { modifier_item_id: modifier_item_1.modifier_item_id.to_s,
                                                     mod_quantity: "1",
                                                     name: "Spicy Club Sauce" },
                                             "1" => { modifier_item_id: modifier_item_2.modifier_item_id.to_s,
                                                       mod_quantity: "1",
                                                       name: "Vegetarian Club Sauce" } },
                                     size_id: "1",
                                     order_detail_id: "27479809",
                                     status: "updated",
                                     external_detail_id: "92391731242",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: "Please add extra baconayse." }] },
                   return: { lead_times_array: [ 1415830156, 1415830216, 1415830276, 1415830336, 1415830396, 1415830456, 1415830516,
                                                 1415830576, 1415830636, 1415830696, 1415830756, 1415830816, 1415830876, 1415830936,
                                                 1415830996, 1415831056, 1415831356, 1415831656, 1415831956, 1415832256, 1415832556,
                                                 1415832856, 1415833156, 1415833456, 1415833756, 1415834056, 1415834356, 1415834656,
                                                 1415834956, 1415835256, 1415835556, 1415835856, 1415836756, 1415837656, 1415838556,
                                                 1415839456, 1415840356, 1415841256, 1415842156, 1415843056, 1415843956 ],
                             order_amt: "$6.89",
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "1000",
                                                        billing_entity_id: nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Pastrami, salad, pretty much that's it",
                                                             order_detail_id: "27479809",
                                                             notes: "Please add extra baconayse." }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479809",
                                                                                             external_detail_id: "92391731242",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] },
                             ucid: "5570-01bpq-gb5qf-7609e" })

    first(".edit-item").click
    find("dd[data-id='#{modifier_item_2.modifier_item_id}'] span").click
    page.find("#requests input").set "Please add extra baconayse."
    first('button.checkout').click
    expect(page).to have_content "Pastrami, salad, pretty much that's it Note: Please add extra baconayse."
  end

  it "allows a user place a delivery order with not transaction fee" do
    checkout_stubs(auth_token: "ASNDKASNDAS",
                   body: { merchant_id: "5000",
                           submitted_order_type: "delivery",
                           user_addr_id:"5667",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     status: "new",
                                     external_detail_id: 92391731239,
                                     points_used: nil,
                                     brand_points_id:nil,
                                     note: "extra crispy hashtags please" }] },
                   return: { time_zone_string: "America/Denver",
                             time_zone_offset: -7,
                             user_message: nil,
                             lead_times_array: [ 1415833736, 1415833796, 1415833856, 1415833916, 1415833976, 1415834036, 1415834096,
                                                 1415834156, 1415834216, 1415834276, 1415834336, 1415834396, 1415834456, 1415834516,
                                                 1415834576, 1415834636, 1415834936, 1415835236, 1415835536, 1415835836, 1415836136,
                                                 1415836436, 1415836736, 1415837036, 1415837336, 1415837636, 1415837936, 1415838236,
                                                 1415838536, 1415838836, 1415839136, 1415839436, 1415840336, 1415841236, 1415842136,
                                                 1415843036, 1415843936, 1415844836, 1415845736, 1415846636, 1415847536 ],
                             promo_amt: "0.00",
                             order_amt: "2.30",
                             grand_total: "13.30",
                             tip_array: [{ "No Tip" => 0 }, { "10%" => "0.23" }, { "15%" => "0.35" }, { "20%" => "0.46" }, { "$1.00" => 1 },
                                         { "$2.00" => 2 }, { "$3.00" =>  3 }, { "$4.00" => 4 }, { "$5.00" => 5 }, { "$6.00" =>6 },
                                         { "$7.00" => 7 }, { "$8.00" => 8 }, { "$9.00" => 9 }, { "$10.00" => 10 }, { "$11.00" => 11 },
                                         { "$12.00" => 12 }, { "$13.00" => 13 }, { "$14.00" => 14 }, { "$15.00" => 15 }, { "$16.00" => 16 },
                                         { "$17.00" => 17 }, { "$18.00" => 18 }, { "$19.00" => 19 }, { "$20.00" => 20 }, { "$21.00" => 21 },
                                         { "$22.00" => 22 }, { "$23.00" => 23 }, { "$24.00" => 24 }, { "$25.00" => 25 }],
                             total_tax_amt: "0.32",
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "1000",
                                                        billing_entity_id:nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                             order_detail_id: "6082053",
                                                             item_note: "extra crispy hashtags please" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal", amount: "$6.89" },
                                                              { title: "Tax", amount: "$0.41" },
                                                              { title: "Tip", amount: "$0.00" },
                                                              { title: "Total", amount: "$13.30" }] },
                             ucid: "9705-j069h-ce8w3-425di" })

    merchant_find_stub({ merchant_id: "103893", auth_token:"ASNDKASNDAS", delivery: true, return: @merchant_without_transaction_fee_rate.as_json(root: false) })

    order_submit_stub({ auth_token: "ASNDKASNDAS",
                        body: {
                          user_id: "2",
                          cart_ucid: "9705-j069h-ce8w3-425di",
                          tip: "0.35",
                          note: "Something with bacon, please.",
                          merchant_payment_type_map_id: "2000",
                          delivery_time: "Wed 11-12 06:09 PM",
                          requested_time: "1415833796",
                        },
                        return: {
                          order_id: "2474268",
                          stamp: "tweb03-i-027c8323-P5H9W6N",
                          merchant_id: "102237",
                          order_dt_tm: 1415802502,
                          user_id: "1469183",
                          pickup_dt_tm: 1415803380,
                          order_amt: "$6.89",
                          promo_code: "",
                          promo_id: nil,
                          promo_amt: "0.00",
                          total_tax_amt: "0.41",
                          trans_fee_amt: "0.00",
                          delivery_amt: "0.00",
                          tip_amt: "0.00",
                          customer_donation_amt: "0.00",
                          grand_total: "7.30",
                          grand_total_to_merchant: 7.3,
                          cash: "N",
                          merchant_donation_amt: "0.00",
                          note: "",
                          status: "O",
                          order_qty: "1",
                          payment_file: nil,
                          order_type: "R",
                          phone_no: nil,
                          user_delivery_location_id: "5667",
                          requested_delivery_time: nil,
                          device_type: "web",
                          app_version: "3",
                          skin_id: "13",
                          distance_from_store: 0,
                          pickup_time_string: "2:43pm",
                          requested_time_string: "2:43pm",
                          user_message: "Your order to PitaPit will be ready for pickup at 4:19pm",
                          user_message_title: "Order Info",
                          facebook: {
                            facebook_title: "Ordered from PitaPit",
                            facebook_caption: "I just ordered and paid at @PitaPitUSA, powered by @splickit web ordering. Cut the line, just grab and go!",
                            facebook_slogan: "",
                            facebook_thumbnail_url: "https://s3.amazonaws.com/splickit-mobile-assets/com.splickit.pitapit/icon_store.png",
                            facebook_thumbnail_link: "http://itunes.apple.com/us/app/pita-pit/id461735388?mt=8",
                            caption_link:"http://www.splickit.com",
                            action_link: "http://itunes.apple.com/us/app/splick-it/id375047368?mt=8",
                            action_text: "Get splick-it"
                          },
                          twitter: {
                            twitter_caption: "I just ordered and paid at @PitaPitUSA, powered by @splickit web ordering. Cut the line, just grab and go!"
                          },
                          payment_service_used: "AccountCreditPaymentService",
                          points_earned: 6.89,
                          points_current: 556,
                          points_lifetime: 556,
                          order_items: nil,
                          user_delivery_address: { user_addr_id: "5667",
                                                   user_id: "2",
                                                   name: "Metro Wastewater Reclamation Plant",
                                                   business_name: "Basement Company",
                                                   address1: "6450 York St",
                                                   address2: "Basement",
                                                   city: "Denver",
                                                   state: "CO",
                                                   zip: "80229",
                                                   lat: "39.8149386187446",
                                                   lng: "-104.956209155655",
                                                   phone_no: "(303) 286-3000",
                                                   instructions: "wear cruddy shoes" },
                          order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                          item_price: "$6.89",
                                                          item_quantity: "1",
                                                          item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                          order_detail_id: "6082213",
                                                          item_note: "extra crispy hashtags please" }],
                                           receipt_items: [{ title: "Subtotal", amount: "$6.89" },
                                                           { title: "Tax", amount: "$0.41" },
                                                           { title: "Total", amount: "$13.30" }] },
                          loyalty_message: "You earned 7 points on this order."
                        },
                        message: "Your order number is 2463458 and will be delivered to: 6450 York St Denver, CO 80229"
                      })
    
    merchant_find_stub({ merchant_id: @merchant_without_transaction_fee_rate.merchant_id, auth_token:"ASNDKASNDAS", return: @merchant_without_transaction_fee_rate.as_json(root: false) })

    stub_merchants_for_zip("80305")
    stub_signed_in_merchants_for_zip("80305")
    visit root_path

    feature_sign_in

    fill_in 'location', with: "80305"
    click_button "Search"

    page.find('.delivery.button').click

    merchant_indeliveryarea_stub(merchant_id: @merchant_without_transaction_fee_rate.merchant_id, auth_token:"ASNDKASNDAS",
                                 delivery_address_id: "5667", return: { is_in_delivery_range:false })

    within("#select-address") do
      page.find(".set-btn.secondary").click
    end

    expect(page).to have_content "ENTER CITY, STATE OR ZIP"
    expect(page).to have_content "Sorry, that address isn't in range."

    fill_in 'location', with: "80305"
    click_button "Search"

    page.find('.delivery.button').click

    merchant_indeliveryarea_stub({merchant_id: @merchant_without_transaction_fee_rate.merchant_id, auth_token:"ASNDKASNDAS", delivery_address_id: "5667", return:{is_in_delivery_range:true}})

    merchant_find_stub({merchant_id: @merchant_without_transaction_fee_rate.merchant_id, auth_token:"ASNDKASNDAS", delivery: true, return: @merchant_without_transaction_fee_rate.as_json(root: false)})

    within("#select-address") do
      page.find(".set-btn.secondary").click
    end

    expect(page).to have_content "DELIVERY MENU"

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click

    within("#requests") do
      fill_in("Extra ingredients may result in additional charges", with: "extra crispy hashtags please")
    end

    first('button.checkout').click

    expect(page).to have_content("Place order - Delivery")

    expect(page).to have_content("Delivering to:")
    expect(page).to have_content("6450 York St, Denver, CO 80229")
    expect(page).to have_content("Note: extra crispy hashtags please")

    expect(page).to_not have_selector "#delivery"

    expect(page).to_not have_selector "#transaction-fee"

    find(".credit-card label").click
    find("#time #time").find(:xpath, "option[2]").select_option
    find("#tip #tip").find(:xpath, "option[4]").select_option
    fill_in("Order notes", with: "Something with bacon, please.")

    find_button("Place order ").click

    expect(URI.parse(current_url).request_uri).to eq("/last_order")

    expect(page).to have_content "Thanks! Your order has been placed."
    expect(page).to have_content("Note: extra crispy hashtags please")

    within "#details" do
      expect(page).to have_content "Order Number:"
      expect(page).to have_content "2474268"
      expect(page).to have_content "Delivery Address:"
      expect(page).to have_content "6450 York St, Denver, CO 80229"
      expect(page).to have_content "Email:"
      expect(page).to have_content "bob@roberts.com"
    end

    expect(page).to_not have_selector "#transaction-fee"
  end

  it "show message content when API return message" do
    merchant_find_stub({ merchant_id: @merchant.merchant_id, auth_token: "ASNDKASNDAS", return: @merchant.as_json(root: false), message: "System message in menu page!!!!" })

    checkout_stubs(message: "System message in checkout page!!",
                   body: { merchant_id: @merchant.merchant_id,
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     status: "new",
                                     external_detail_id: 92391731239,
                                     points_used: nil,
                                     brand_points_id:nil,
                                     note: "" }] },
                   return: { grand_total: "7.30",
                             order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                             item_price: "6.89",
                                                             item_quantity: "1",
                                                             item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                             order_detail_id: "6082053",
                                                             note: "" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal",
                                                                amount: "$6.89" },
                                                              { title: "Tax",
                                                                amount: "$0.41" },
                                                              { title: "Total",
                                                                amount: "$7.30" }] } })
    order_submit_stub(auth_token: "ASNDKASNDAS",
                      body: { user_id: "2",
                              cart_ucid: "9705-j069h-ce8w3-425di",
                              tip: "1", 
                              merchant_payment_type_map_id: "1000" },
                      message: "System message in place order page !!!!")

    visit root_path

    feature_sign_in

    visit merchant_path(@merchant.merchant_id, menu_type: "pickup")

    expect(page).to have_content "System message in menu page!!!!"

    first('article').click
    first('button.checkout').click

    expect(page).to have_content "Place order"
    expect(page).to have_content "System message in checkout page!!"

    find("#tip #tip").find(:xpath, "option[6]").select_option

    find_button("Place order ").click

    expect(URI.parse(current_url).request_uri).to eq("/last_order")

    expect(page).to have_content "Thanks! Your order has been placed."
  end

  it "allows ASAP option on delivery order" do
    checkout_stubs(auth_token: "ASNDKASNDAS",
                   body: { merchant_id: "5000",
                           user_addr_id:"5667",
                           submitted_order_type: "delivery",
                           items: [{ item_id: 931,
                                     quantity: 1,
                                     mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                              mod_quantity: 1,
                                              name: "Spicy Club Sauce" }],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     status: "new",
                                     external_detail_id: 92391731239,
                                     points_used: nil,
                                     brand_points_id:nil,
                                     note: "extra crispy hashtags please" }] },
                   return: { time_zone_string: "America/Denver",
                             time_zone_offset: -7,
                             user_message: nil,
                             lead_times_array: [ "As soon as possible", 1415833736, 1415833796, 1415833856, 1415833916, 1415833976,
                                                 1415834036, 1415834096, 1415834156, 1415834216, 1415834276, 1415834336, 1415834396,
                                                 1415834456, 1415834516, 1415834576, 1415834636, 1415834936, 1415835236, 1415835536,
                                                 1415835836, 1415836136, 1415836436, 1415836736, 1415837036, 1415837336, 1415837636,
                                                 1415837936, 1415838236, 1415838536, 1415838836, 1415839136, 1415839436, 1415840336,
                                                 1415841236, 1415842136, 1415843036, 1415843936, 1415844836, 1415845736, 1415846636,
                                                 1415847536 ],
                             promo_amt: "0.00",
                             order_amt: "2.30",
                             tip_array: [{ "No Tip" => 0 }, { "10%" => "0.23" }, { "15%" => "0.35" }, { "20%" => "0.46" }, { "$1.00" => 1 },
                                         { "$2.00" => 2 }, { "$3.00" =>  3 }, { "$4.00" => 4 }, { "$5.00" => 5 }, { "$6.00" =>6 },
                                         { "$7.00" => 7 }, { "$8.00" => 8 }, { "$9.00" => 9 }, { "$10.00" => 10 }, { "$11.00" => 11 },
                                         { "$12.00" => 12 }, { "$13.00" => 13 }, { "$14.00" => 14 }, { "$15.00" => 15 }, { "$16.00" => 16 },
                                         { "$17.00" => 17 }, { "$18.00" => 18 }, { "$19.00" => 19 }, { "$20.00" => 20 }, { "$21.00" => 21 },
                                         { "$22.00" => 22 }, { "$23.00" => 23 }, { "$24.00" => 24 }, { "$25.00" => 25 }],
                             total_tax_amt: "0.32",
                             grand_total: "13.30",
                             accepted_payment_types: [{ merchant_payment_type_map_id: "1008",
                                                        name: "Cash",
                                                        splickit_accepted_payment_type_id: "1000",
                                                        billing_entity_id:nil },
                                                      { merchant_payment_type_map_id: "2000",
                                                        name: "Credit",
                                                        splickit_accepted_payment_type_id: "2000",
                                                        billing_entity_id: nil }],
                             order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                             item_price: "$6.89",
                                                             item_quantity: "1",
                                                             item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                             order_detail_id: "6082053",
                                                             item_note: "extra crispy hashtags please" }],
                                              order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                   user_id: "4777193",
                                                                                   items: [{ item_id: "931",
                                                                                             size_id: "1",
                                                                                             quantity: "1",
                                                                                             order_detail_id: "27479804",
                                                                                             external_detail_id: "92391731239",
                                                                                             status: "saved",
                                                                                             mods: [{ modifier_item_id: "2",
                                                                                                      mod_quantity: "1" }] }] },
                                              receipt_items: [{ title: "Subtotal", amount: "$6.89" },
                                                              { title: "Tax", amount: "$0.41" },
                                                              { title: "Total", amount: "$13.30" }] },
                             ucid: "9705-j069h-ce8w3-425di" })

    merchant_find_stub(merchant_id: "103893", auth_token:"ASNDKASNDAS", delivery: true,
                       return: @merchant_without_transaction_fee_rate.as_json(root: false))

    order_submit_stub({ auth_token: "ASNDKASNDAS",
                        body: {
                          user_id: "2",
                          cart_ucid: "9705-j069h-ce8w3-425di",
                          tip: "0.35",
                          note: "Something with bacon, please.",
                          merchant_payment_type_map_id: "2000",
                          delivery_time: "As soon as possible",
                          requested_time: "As soon as possible",
                        },
                        return: {
                          order_id: "2474268",
                          stamp: "tweb03-i-027c8323-P5H9W6N",
                          merchant_id: "102237",
                          order_dt_tm: 1415802502,
                          user_id: "1469183",
                          pickup_dt_tm: 1415803380,
                          order_amt: "$6.89",
                          promo_code: "",
                          promo_id: nil,
                          promo_amt: "0.00",
                          total_tax_amt: "0.41",
                          trans_fee_amt: "0.00",
                          delivery_amt: "0.00",
                          tip_amt: "0.00",
                          customer_donation_amt: "0.00",
                          grand_total: "7.30",
                          grand_total_to_merchant: 7.3,
                          cash: "N",
                          merchant_donation_amt: "0.00",
                          note: "",
                          status: "O",
                          order_qty: "1",
                          payment_file: nil,
                          order_type: "R",
                          phone_no: nil,
                          user_delivery_location_id: "5667",
                          requested_delivery_time: nil,
                          device_type: "web",
                          app_version: "3",
                          skin_id: "13",
                          distance_from_store: 0,
                          pickup_time_string: "2:43pm",
                          requested_time_string: "2:43pm",
                          user_message: "Your order to PitaPit will be ready for pickup at 4:19pm",
                          user_message_title: "Order Info",
                          facebook: {
                            facebook_title: "Ordered from PitaPit",
                            facebook_caption: "I just ordered and paid at @PitaPitUSA, powered by @splickit web ordering. Cut the line, just grab and go!",
                            facebook_slogan: "",
                            facebook_thumbnail_url: "https://s3.amazonaws.com/splickit-mobile-assets/com.splickit.pitapit/icon_store.png",
                            facebook_thumbnail_link: "http://itunes.apple.com/us/app/pita-pit/id461735388?mt=8",
                            caption_link:"http://www.splickit.com",
                            action_link: "http://itunes.apple.com/us/app/splick-it/id375047368?mt=8",
                            action_text: "Get splick-it"
                          },
                          twitter: {
                            twitter_caption: "I just ordered and paid at @PitaPitUSA, powered by @splickit web ordering. Cut the line, just grab and go!"
                          },
                          payment_service_used: "AccountCreditPaymentService",
                          points_earned: 6.89,
                          points_current: 556,
                          points_lifetime: 556,
                          order_items: nil,
                          user_delivery_address: { user_addr_id: "5667",
                                                   user_id: "2",
                                                   name: "Metro Wastewater Reclamation Plant",
                                                   business_name: "Basement Company",
                                                   address1: "6450 York St",
                                                   address2: "Basement",
                                                   city: "Denver",
                                                   state: "CO",
                                                   zip: "80229",
                                                   lat: "39.8149386187446",
                                                   lng: "-104.956209155655",
                                                   phone_no: "(303) 286-3000",
                                                   instructions: "wear cruddy shoes" },
                          order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                          item_price: "$6.89",
                                                          item_quantity: "1",
                                                          item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                          order_detail_id: "6082213",
                                                          item_note: "extra crispy hashtags please" }],
                                           receipt_items: [{ title: "Subtotal", amount: "$6.89" },
                                                           { title: "Tax", amount: "$0.41" },
                                                           { title: "Total", amount: "$13.30" }] },
                          loyalty_message: "You earned 7 points on this order."
                        },
                        message: "Your order to Pita Pit has been scheduled for delivery as soon as possible."
                      })

    merchant_find_stub({ merchant_id: @merchant_without_transaction_fee_rate.merchant_id, auth_token:"ASNDKASNDAS", return: @merchant_without_transaction_fee_rate.as_json(root: false) })

    stub_merchants_for_zip("80305")
    stub_signed_in_merchants_for_zip("80305")
    visit root_path

    feature_sign_in

    fill_in 'location', with: "80305"
    click_button "Search"

    page.find('.delivery.button').click

    merchant_indeliveryarea_stub({merchant_id: @merchant_without_transaction_fee_rate.merchant_id, auth_token:"ASNDKASNDAS", delivery_address_id: "5667", return:{is_in_delivery_range:true}})

    merchant_find_stub({merchant_id: @merchant_without_transaction_fee_rate.merchant_id, auth_token:"ASNDKASNDAS", delivery: true, return: @merchant_without_transaction_fee_rate.as_json(root: false)})

    within("#select-address") do
      page.find(".set-btn.secondary").click
    end

    expect(page).to have_content "DELIVERY MENU"

    # Verify item prices and layout
    verify_zero_item(932)
    verify_non_zero_item(931, 6.65)

    first('article').click

    within("#requests") do
      fill_in("Extra ingredients may result in additional charges", with: "extra crispy hashtags please")
    end

    first('button.checkout').click

    expect(page).to have_content("Place order - Delivery")

    expect(page).to have_content("Delivering to:")
    expect(page).to have_content("6450 York St, Denver, CO 80229")
    expect(page).to have_content("6450 York St, Denver, CO 80229")
    expect(page).to have_content("Note: extra crispy hashtags please")

    find(".credit-card label").click
    asap = find("#time #time").find(:xpath, "option[1]")
    expect(asap.text).to eq "As soon as possible"
    asap.select_option
    find("#tip #tip").find(:xpath, "option[4]").select_option
    fill_in("Order notes", with: "Something with bacon, please.")

    find_button("Place order ").click

    expect(URI.parse(current_url).request_uri).to eq("/last_order")

    expect(page).to have_content "Thanks! Your order has been placed."
    expect(page).to have_content("Note: extra crispy hashtags please")

    within "#details" do
      expect(page).to have_content "Order Number:"
      expect(page).to have_content "2474268"
      expect(page).to have_content "Delivery Address:"
      expect(page).to have_content "6450 York St, Denver, CO 80229"
      expect(page).to have_content "Email:"
      expect(page).to have_content "bob@roberts.com"
    end

  end

  def verify_error_modal(message)
    within "#error-message" do
      expect(page).to have_content "Incomplete Order"
      expect(page).to have_selector "div.description", text: "Your order is incomplete"
      expect(page).to have_selector "ul li", text: message
      expect(page).to have_selector "div.buttons button", text: "OK"
    end
    click_button "OK"
  end

  def verify_zero_item(item_id)
    expect(page).not_to have_text("$0.00")
    expect(page).to have_selector("div.items [data-menu-item-id='#{ item_id }'] div.item-description br")
  end

  def verify_non_zero_item(item_id, price)
    expect(page).to have_text("$#{ price }")
    expect(page).to have_selector("div.items [data-menu-item-id='#{ item_id }'] div.item-description h4.price")
    item = page.find("div.items [data-menu-item-id='#{ item_id }'] div.item-description h4.price")
    expect(item.text).to include("$#{ price }")
  end
end
