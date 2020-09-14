module ObjectCreationMethods

  @@ctr = 1

  def ctr
    @@ctr += 1
  end

  def get_merchant_data
    {
      "merchant_id" => ctr.to_s,
      "brand_id" => ctr.to_s,
      "lat" => "39.32",
      "lng" => "105.7",
      "name" => "The Breakfast Club",
      "address1" => "888 Main Street",
      "address2" => "",
      "city" => "Shermer",
      "state" => "IL",
      "zip" => "30502",
      "phone_no" => "",
      "delivery" => "N",
      "distance" => "",
      "description" => "",
      "menu_key" => "1701",
      "menu" => get_menu_data,
      "modifier_groups" => [get_modifier_group_data],
      "time_zone_offset" => "-7"
    }
  end

  def create_merchant(options = {})
    data = get_merchant_data.merge(options)
    Merchant.new(data)
  end

  def invalid_merchants_index
    {
      http_code: 200,
      stamp: "tweb03-i-027c8323-IE31RVC",
      error: {
        error: "Sorry, that is not a valid zip code.",
        error_code: 999
      }
    }
  end

  def get_menu_type_data
    {
      "menu_type_id" => ctr.to_s,
      "menu_type_name" => "Salads In Bowls",
      "menu_type_description" => "These are salads in bowls",
      "start_time" => "00:00:00",
      "end_time" => "23:59:59",
      "menu_items" => [get_menu_item_data]
    }
  end

  def create_menu_type(options = {})
    MenuType.new(get_menu_type_data.merge(options))
  end

  def get_menu_data
    {"menu_id" => ctr.to_s, "name" => "World Cup Salads", "menu_key" => "1701", "description" => "The Best Salads", "menu_types" => [get_menu_type_data]}
  end

  def create_menu(options = {})
    data = get_menu_data.merge(options)
    Menu.new(data)
  end

  def get_order_data
    {user_id: ctr.to_s, merchant_id: ctr.to_s, items: [get_line_item_data], sub_total: "6.49", tip: "18.49", tax: "0.66", grand_total: "25.68", note: "Harry Potter", pickup_time: (Time.now + 20.minutes).tv_sec, promo_code: "quidditch", set_cash: "yes", loyalty_number: "EB44-YU", order: {merchant_id: ctr.to_s}}
  end

  def orders_params
    "{\"merchant_id\":33,\"note\":\"extra bacon\",\"user_id\":\"1701\",\"tip\":\"5\",\"merchant_payment_type_map_id\":\"1000\",\"requested_time\":\"1408398185\",\"items\":[{\"item_id\":\"4352\",\"mods\":[{\"modifier_item_id\":\"4012\",\"mod_quantity\":\"1\",\"name\":\"Cheddar\",\"size_id\":\"1643\"},{\"modifier_item_id\":\"3998\",\"mod_quantity\":\"1\",\"name\":\"Onions\",\"size_id\":\"1643\"},{\"modifier_item_id\":\"4048\",\"mod_quantity\":\"1\",\"name\":\"Hash Browns\",\"size_id\":\"1643\"},{\"modifier_item_id\":\"3999\",\"mod_quantity\":\"1\",\"name\":\"Green Peppers\",\"size_id\":\"1643\"}],\"quantity\":1,\"name\":\"Ham n' Eggs\",\"cash\":\"6.65\",\"price_string\":\"$6.65\",\"note\":\"\",\"size_id\":\"1643\",\"sizeName\":\"Pita\"}],\"cart_ucid\":\"7217-ue7y4-k2ec5-lp446\",\"sub_total\":\"25.00\"}"
  end

  def invalid_promo_response
    {
      http_code: 200,
      stamp:"tweb03-i-027c8323-J6Y99SK",
      error:
        {
          error: "Sorry! The promo code you entered, barfwubs, is not valid.",
          error_code: 800
        }
    }
  end

  def valid_orders_response
    {
      "data" => {
        "order_id" => "2463458",
        "user_delivery_location_id" => "5667",
        "tip_amt" => "1.04",
        "requested_time_string" => "2:46pm",
        "order_summary" => {
          "cart_items" => [
            {
              "item_name" => "Morning Glory",
              "item_price" => "6.65",
              "item_quantity" => "1",
              "item_description" => "Cheddar,Tomatoes,Onions,Hash Browns,Green Peppers",
              "order_detail_id" => "6066075",
              "item_note" => ""
            }
          ],
          "receipt_items" => [
            {
              "title" => "Subtotal",
              "amount" => "$6.65"
            },
            {
              "title" => "Tax",
              "amount" => "$0.54"
            },
            {
              "title" => "Total",
              "amount" => "$7.19"
            }
          ]
        },
        "loyalty_message" => "You earned 7 points on this order."
      },
      "message" => "Your order to The Pita Pit will be ready for pickup at 2:46pm"
    }
  end

  def valid_loyal_orders_response
    {
      "data" => {
        "order_id" => "2463458",
        "user_delivery_location_id" => "202402",
        "tip_amt" => "1.04",
        "requested_time_string" => "2:46pm",
        "order_summary" => {
          "cart_items" => [
            {
              "item_name" => "Pastrami Salad",
              "item_price" => "0.00",
              "item_quantity" => "1",
              "item_description" => "",
              "order_detail_id" => "6066075",
              "item_note" => ""
            }
          ],
          "receipt_items" => [
            {
              "title" => "Subtotal",
              "amount" => "$0.00"
            },
            {
              "title" => "Tax",
              "amount" => "$0.00"
            },
            {
              "title" => "Total",
              "amount" => "$0.00"
            }
          ]
        },
        "loyalty_message" => "You earned 7 points on this order."
      },
      "message" => "Your order to The Pita Pit will be ready for pickup at 2:46pm"
    }
  end

  def invalid_orders_response(message)
    {
      "error" => {
        "error" => message
      }
    }
  end

  def create_order(options = {})
    data = get_order_data.merge(options)
    Checkout.new(data)
  end

  def get_default_merchant_list(options = {})
    zip = options[:location] || "80305"
    lat = options[:lat] || "40.049599"
    lng = options[:lng] || "-105.276901"

    [{ active: "Y",
       merchant_id: "4000",
       merchant_external_id: "001",
       brand_id: "162",
       lat: "#{ lat }",
       lng: "#{ lng }",
       name: "Illegal Pete's",
       display_name: "The Hill--Boulder",
       address1: "1320 College Ave",
       description: "Fast, Fresh, Healthy",
       city: "Boulder",
       state: "CO",
       zip: "#{ zip }",
       phone_no: "3034443055",
       delivery: "N",
       distance: "2.2647914903494777",
       brand: "Illegal Pete's",
       promo_count: "NA",
       group_ordering_on: "1" },
     { active: "Y",
       merchant_id: "103893",
       merchant_external_id: "bdce5f3e-3a94-11e2-87ed-00163eeae34c",
       brand_id: "340",
       lat: "#{ lat }",
       lng: "#{ lng }",
       name: "Geisty's Dogg House",
       display_name: "Boulder",
       address1: "1116 13th Street",
       description: "N",
       city: "Boulder",
       state: "CO",
       zip: "#{ zip }",
       phone_no: "3034025000",
       delivery: "Y",
       distance: "2.303197522850048",
       brand: "MenuSherpa",
       promo_count: "NA",
       group_ordering_on: "0" },
     { active: "Y",
       merchant_id: "1051",
       merchant_external_id: "",
       brand_id: "100",
       lat: "#{ lat }",
       lng: "#{ lng }",
       name: "Flatiron Coffee",
       display_name: "Boulder",
       address1: "2721 Arapahoe Avenue",
       description: "Great Coffee Shop in Boulder",
       city: "Boulder",
       state: "CO",
       zip: "#{ zip }",
       phone_no: "3034494111",
       delivery: "N",
       distance: "2.453691516326954",
       brand: "System Default",
       promo_count: "NA",
       group_ordering_on: "0" }]
  end

  def get_default_menu
    modifier_item_1 = create_modifier_item({ "modifier_item_name" => "Spicy Club Sauce",
                                             "modifier_item_pre_selected" => "yes" })
    modifier_item_2 = create_modifier_item({ "modifier_item_name" => "Vegetarian Club Sauce" })
    modifier_item_3 = create_modifier_item({ "modifier_item_name" => "Lutefisk Club Sauce" })
    modifier_group_1 = create_modifier_group({ modifier_group_display_name: "Club Sauce",
                                               modifier_items: [modifier_item_1,
                                                                modifier_item_2,
                                                                modifier_item_3],
                                               "modifier_group_credit" => "1.00",
                                               "modifier_group_credit_by_size" => [[
                                                   "size_id": "1",
                                                   "modifier_price": "1.00"
                                               ],
                                               [
                                                   "size_id": "2",
                                                   "modifier_price": "2.00"
                                               ],
                                               [
                                                   "size_id": "3",
                                                   "modifier_price": "3.00"
                                               ]]
                                             })

    menu_item_1 = create_menu_item({ item_id: 931,
                                     modifier_groups: [modifier_group_1],
                                     item_name: "Pastrami Salad",
                                     description: "A bed of fresh pastrami topped with cool ranch pastrami." })
    menu_item_2 = create_menu_item({ item_id: 932,
                                     modifier_groups: [modifier_group_1],
                                     item_name: "Zero Item",
                                     description: "Zero description" })

    menu = { menu_id: 3300,
             name: "Salads in Bowls",
             menu_types: [create_menu_type({ menu_type_name: "Frozen Salads",
                                             menu_items: [menu_item_1, menu_item_2] })] }

    { menu: menu, modifier_item_1: modifier_item_1 }
  end

  def get_menu_item_data
    {
      "item_id" => ctr.to_s,
      "points" => "340",
      "item_name" => "Dumbledore's Burrito",
      "size_prices" => get_size_prices(ctr.to_s),
      "description" => "Expelliguacamoleus",
      "modifier_groups" => [
        get_modifier_group_data
      ],
      "photos" => [
        {
          "url" => "https://www.placehold.it/1x/640x420",
          "width" => "640",
          "height" => "420",
          "item_id" => ctr.to_s
        },
        {
          "url" => "https://www.placehold.it/2x/640x420",
          "width" => "640",
          "height" => "420",
          "item_id" => ctr.to_s
        },
        {
          "url" => "https://www.placehold.it/1x/158x158",
          "width" => "158",
          "height" => "158",
          "item_id" => ctr.to_s
        },
        {
          "url" => "https://www.placehold.it/2x/158x158",
          "width" => "158",
          "height" => "158",
          "item_id" => ctr.to_s
        }
      ]
    }
  end

  def create_menu_item(options = {})
    MenuItem.new(get_menu_item_data.merge(options))
  end

  def get_modifier_group_data
    {
      "modifier_group_display_name" => "options",
      "modifier_group_credit" => "0.00",
      "modifier_group_max_price" => "999.00",
      "modifier_group_max_modifier_count" => "3",
      "modifier_group_min_modifier_count" => "1",
      "modifier_items" => [
        get_modifier_item_data
      ]
    }
  end

  def create_modifier_group(options = {})
    ModifierGroup.new(get_modifier_group_data.merge(options))
  end

  def get_line_item_data
    {menu_item: get_menu_item_data, modifier_items: [get_ordered_item_modifier_data], quantity: "1", note: "This is a note", item_size_id: ctr.to_s}
  end

  def create_line_item(options = {})
    data = get_line_item_data.merge(options)
    LineItem.new(data["menu_item"], data["modifier_items"], data["quantity"], data["note"], data["item_size_id"])
  end

  def get_modifier_item_data
    {
      "modifier_item_id" => ctr.to_s,
      "modifier_item_name" => "soup",
      "modifier_item_max" => "1",
      "modifier_item_min" => "0",
      "modifier_item_pre_selected" => "no",
      "modifier_prices_by_item_size_id" => [
        {
          "size_id" => "1",
          "modifier_price" => "1.00"
        },
        {
          "size_id" => "2",
          "modifier_price" => "2.00"
        },
        {
          "size_id" => "3",
          "modifier_price" => "3.00"
        }
      ]
    }
  end

  def get_size_prices(id)
    item_id = id || ctr.to_s

    [
      {
        "item_size_id" => "1",
        "item_id" => item_id,
        "size_id" => "1",
        "tax_group" => "1",
        "price" => "8.24",
        "points" => "88",
        "brand_points_id" => "888",
        "active" => "Y",
        "priority" => "80",
        "size_name" => "Small"
      },
      {
        "item_size_id" => "2",
        "item_id" => item_id,
        "size_id" => "2",
        "tax_group" => "1",
        "price" => "9.24",
        "active" => "Y",
        "priority" => "90",
        "size_name" => "Medium"
      },
      {
        "item_size_id" => "3",
        "item_id" => item_id,
        "size_id" => "3",
        "tax_group" => "3",
        "price" => "10.24",
        "active" => "Y",
        "priority" => "100",
        "size_name" => "Large"
      }
    ]
  end

  def create_modifier_item(options = {})
    ModifierItem.initialize(get_modifier_item_data.merge(options))
  end

  def get_ordered_item_modifier_data
    {modifier_item: get_modifier_item_data, size_id: ctr.to_s, quantity: "1"}
  end

  def get_authenticated_user_json
    "{\"http_code\":\"200\",\"stamp\":\"tweb03-i-027c8323-FY6FPUS\",\"data\":#{ get_user_data.to_json }}"
  end

  def get_authenticated_user_json_business_name
    "{\"http_code\":\"200\",\"stamp\":\"tweb03-i-027c8323-FY6FPUS\",\"data\":#{get_user_data_with_business_name.to_json}}"
  end

  def get_authenticated_user_no_cc_json
    "{\"http_code\":\"200\",\"stamp\":\"tweb03-i-027c8323-FY6FPUS\",\"data\":#{get_user_data.merge("flags" => "000000").to_json}}"
  end

  def user_address_params(params={})
    {
      "business_name" => "",
      "address1" => "Fortune and Glory Ln.",
      "address2" => "101",
      "city" => "Shanghai",
      "state" => "UT",
      "zip" => "80123",
      "phone_no" => "123-123-1234",
      "instructions" => "Don't mind the sock."
    }.merge(params)
  end

  def user_address_params_business_name_with_value(params={}){
      "business_name" => "Tests Corporation",
      "address1" => "Fortune and Glory Ln.",
      "address2" => "101",
      "city" => "Boulder",
      "state" => "St",
      "zip" => "80302",
      "phone_no" => "123-123-1234",
      "instructions" => "Don't mind the sock."
  }.merge(params)
  end

  def set_user_address_request_invalid
    {
      address1: "",
      address2: "",
      city: "",
      state: "",
      zip: "",
      phone_no: "",
      instructions: ""
    }
  end

  def set_user_address_response
    {
      business_name:"",
      address1: "Fortune and Glory Ln.",
      address2: "101",
      city: "Shanghai",
      state: "UT",
      zip: "80123",
      phone_no: "123-123-1234",
      instructions: "Dont' mind the sock.",
      user_id: "1463069",
      class: "resource",
      mimetype: "application/tonic-resource",
      created: 1409867676,
      modified: 1409867674,
      lat: 42.8140012,
      lng: -73.9814578,
      user_addr_id: 202780,
      stamp: "tweb03-i-027c8323-KXTZE96"
    }
  end

  def set_user_address_response_with_business_name
    {
        business_name:"Tests Corporation",
        address1: "Fortune and Glory Ln.",
        address2: "101",
        city: "Boulder",
        state: "St",
        zip: "80302",
        phone_no: "123-123-1234",
        instructions: "Dont' mind the sock.",
        user_id: "1463069",
        class: "resource",
        mimetype: "application/tonic-resource",
        created: 1409867676,
        modified: 1409867674,
        lat: 42.8140012,
        lng: -73.9814578,
        user_addr_id: 202780,
        stamp: "tweb03-i-027c8323-KXTZE96"
    }
  end

  def set_user_address_response_invalid
    {
      ERROR: "address cannot be null",
      ERROR_CODE: "11",
      TEXT_TITLE: nil,
      TEXT_FOR_BUTTON: nil,
      FATAL: nil,
      URL: nil,
      stamp: "tweb03-i-027c8323-YK4ZH1D"
    }
  end

  def user_payment_response
    {
      http_code: 200,
      stamp: "UUUU09-9JRYR4S",
      data: {
        user_id: "288563",
        last_four: "1111",
        flags: "1C21000001",
        first_name: "First",
        last_name: "Last",
        email: "testuser_1405879153_kzg@splickit.com",
        contact_no: "1234567890",
        device_id: "2176-5at8u-3cplz-bn34f",
        balance: "0.00",
        points_current: "0",
        user_message_title: "Credit Card Response",
        user_message: "Your credit card info has been securely stored."
      },
      message: "Your credit card info has been securely stored."
    }
  end

  def user_delivery_response
    {
      address1: "45 Ogden St.",
      address2: "#105",
      city: "Denver",
      state: "CO",
      zip: "80218",
      phone_no: "5555555555",
      instructions: "",
      user_id: "1460321",
      class: "resource",
      mimetype: "application/tonic-resource",
      created: 1409174256,
      modified: 1409174254,
      lat: 39.717307,
      lng: -104.976055,
      user_addr_id: 202641,
      stamp: "tweb03-i-027c8323-CX1TITZ"
    }.to_json
  end

  def get_user_data
    { "user_id" => "2",
      "first_name" => "bob",
      "last_name" => "roberts",
      "email" => "bob@roberts.com",
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
                                 "instructions" => "wear cruddy shoes" },
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
      "marketing_email_opt_in" => nil,
      "zipcode" => nil,
      "birthday" => nil,
      "privileges" => { "caching_action" => "respect",
                        "ordering_action"=>"send",
                        "send_emails" => true,
                        "see_inactive_merchants" => false },
      "splickit_authentication_token" => "ASNDKASNDAS" }
  end

  def get_user_data_with_business_name
    {
        "delivery_locations" => [{
                                     "user_addr_id" => "5667",
                                     "user_id" => "2",
                                     "name" => "Metro Wastewater Reclamation Plant",
                                     "business_name" =>"Basement Company",
                                     "address1" => "6450 York St",
                                     "address2" => "Basement",
                                     "city" => "Denver",
                                     "state" => "CO",
                                     "zip" => "80229",
                                     "lat" => "39.8149386187446",
                                     "lng" => "-104.956209155655",
                                     "phone_no" => "(303) 286-3000",
                                     "instructions" => "wear cruddy shoes"
                                 },
                                 {
                                     "user_addr_id" => "202403",
                                     "user_id" => "1449579",
                                     "name" => "",
                                     "business_name" =>"Basement Company",
                                     "address1" => "555 5th st ",
                                     "address2" => "",
                                     "city" => "Boulder",
                                     "state" => "CT",
                                     "zip" => "06001",
                                     "lat" => "33.813101",
                                     "lng" => "-111.917054",
                                     "phone_no" => "5555555555",
                                     "instructions" => nil
                                 }],
        "last_four" => "9861",
        "flags" => "1C21000001",
        "user_id" => "2",
        "first_name" => "bob",
        "last_name" => "roberts",
        "email" => "bob@roberts.com",
        "contact_no" => "4442221111",
        "group_order_token" => "1234-ABCD",
        "privileges"=>{"caching_action"=>"respect", "ordering_action"=>"send", "send_emails"=>true, "see_inactive_merchants"=>false},
        "splickit_authentication_token" => "ASNDKASNDAS"
    }
  end

  def get_loyal_user_data_json
    {
      "http_code" => "200",
      "stamp" => "tweb03-i-027c8323-FY6FPUS",
      "data" => {
        "last_four" => "9862",
        "flags" => "1C21000001",
        "user_id" => "2",
        "first_name" => "bob",
        "last_name" => "roberts",
        "email" => "bob@roberts.com",
        "contact_no" => "4442221112",
        "splickit_authentication_token" => "ASNDKASNDAS",
        "brand_loyalty" => {
          "loyalty_number" => "140105420000001793",
          "pin" => "9189",
          "points" => "500",
          "usd" => "25"
        }
      }
    }.to_json
  end

  def get_loyal_user_no_cash_data_json
    {
      "http_code" => "200",
      "stamp" => "tweb03-i-027c8323-FY6FPUS",
      "data" => {
        "last_four" => "9862",
        "flags" => "1C21000001",
        "user_id" => "2",
        "first_name" => "bob",
        "last_name" => "roberts",
        "email" => "bob@roberts.com",
        "contact_no" => "4442221112",
        "splickit_authentication_token" => "ASNDKASNDAS",
        "brand_loyalty" => {
          "loyalty_number" => "140105420000001793",
          "pin" => "9189",
          "points" => "500"
        }
      }
    }.to_json
  end

  def get_loyal_user_data
    {
        "delivery_locations" => [{
          "user_addr_id" => "4",
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
          "instructions" => "wear cruddy shoes"
        }],
        "last_four" => "9861",
        "flags" => "1C21000001",
        "user_id" => "2",
        "first_name" => "bob",
        "last_name" => "roberts",
        "email" => "bob@roberts.com",
        "contact_no" => "4442221111",
        "splickit_authentication_token" => "ASNDKASNDAS",
        "brand_loyalty" => { "loyalty_number" => "140105420000001793",
                             "pin" => "9189",
                             "points" => "500",
                             "usd" => "25" } }
  end

  def get_loyalty_error_message_json
    "{\"http_code\": \"400\", \"stamp\": \"tweb03-i-027c8323-LJN48WW\", \"error\": { \"error\": \"The parameter \"pin\" cannot be more than 10 characters.\", \"error_code\": \"400\"}}"
  end

  def create_authenticated_user
    User.initialize(get_user_data)
  end

  def get_signup_user
    { user_id: "3",
      first_name: "Tony",
      last_name: "Stark",
      email: "tony@starkindustries.com",
      contact_no: "5555555555",
      splickit_authentication_token: "TONYTONY" }
  end

  def get_signup_user_json
    { data: get_signup_user }.to_json
  end

  def get_user_orders_json
    {
      "orders" => [{
                     "order_id" => "6928716",
                     "merchant_id" => "101411",
                     "order_dt_tm" => 1444138396,
                     "tip_amt" => "17.00",
                     "status" => "O",
                     "order_date" => "10/06/15",
                     "order_date2" => "2015-10-06",
                     "order_date3" => "10/6 9:33AM",
                     "order_date_task_retail" => "2015-10-06T09:33:00.0000",
                     "order_time" => "9:33",
                     "merchant" => {
                       "merchant_id" => "101411",
                       "merchant_user_id" => "1002",
                       "merchant_external_id" => "163",
                       "numeric_id" => "24645802",
                       "alphanumeric_id" => "50um144192f7",
                       "rewardr_programs" => nil,
                       "shop_email" => "mojos6679@hotmail.com",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Raleigh",
                       "address1" => "6679 Falls of the Neuse Rd",
                       "address2" => "",
                       "city" => "Raleigh",
                       "state" => "NC",
                       "zip" => "27615",
                       "country" => "US",
                       "lat" => "35.874863",
                       "lng" => "-78.622627",
                       "EIN_SS" => "16-1648470",
                       "description" => "",
                       "phone_no" => "9198469274",
                       "fax_no" => "",
                       "twitter_handle" => "",
                       "time_zone" => "-5",
                       "cross_street" => "",
                       "trans_fee_type" => "P",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "Y",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "Y",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => "5",
                       "show_search" => "Y",
                       "lead_time" => "15",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => "9999999999",
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.080",
                       "minimum_android_version" => "2.080",
                       "live_dt" => "2012-04-02",
                       "facebook_caption_link" => "",
                       "custom_order_message" => "",
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-05:00) Eastern Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Reglr",
                                          "item_name" => "Sriracha Burrito",
                                          "item_price" => "$10.18",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Rice, Black Beans, Chicken, Extra Chicken, Sriracha Sauce, Pico de Gallo, Sour Cream, Pickled Jalapenos, Crushed Tortilla Chips, Cotija Cheese",
                                          "order_detail_id" => "16622882",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$10.18"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$0.79"
                                           },
                                           {
                                             "title" => "Tip",
                                             "amount" => "$17.00"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$27.97"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$10.18"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$0.79"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$10.97"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$17.00"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$27.97"
                                                               }
                     ]
                   },
                   {
                     "order_id" => "6928713",
                     "merchant_id" => "101413",
                     "order_dt_tm" => 1444138344,
                     "tip_amt" => "16.00",
                     "status" => "O",
                     "order_date" => "10/06/15",
                     "order_date2" => "2015-10-06",
                     "order_date3" => "10/6 9:32AM",
                     "order_date_task_retail" => "2015-10-06T09:32:00.0000",
                     "order_time" => "9:32",
                     "merchant" => {
                       "merchant_id" => "101413",
                       "merchant_user_id" => "1002",
                       "merchant_external_id" => "345",
                       "numeric_id" => "97519187",
                       "alphanumeric_id" => "13fe0hk4s752",
                       "rewardr_programs" => nil,
                       "shop_email" => "moestriangle@ctc.net",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Raleigh",
                       "address1" => "3721 Sumner Blvd.",
                       "address2" => "",
                       "city" => "Raleigh",
                       "state" => "NC",
                       "zip" => "27616",
                       "country" => "US",
                       "lat" => "35.863463",
                       "lng" => "-78.574483",
                       "EIN_SS" => "20-2759848",
                       "description" => "",
                       "phone_no" => "9197922960",
                       "fax_no" => "",
                       "twitter_handle" => "",
                       "time_zone" => "-5",
                       "cross_street" => "",
                       "trans_fee_type" => "P",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "Y",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "N",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => "5",
                       "show_search" => "Y",
                       "lead_time" => "15",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => "9999999999",
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.080",
                       "minimum_android_version" => "2.080",
                       "live_dt" => "2012-04-11",
                       "facebook_caption_link" => "",
                       "custom_order_message" => "",
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-05:00) Eastern Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Reglr",
                                          "item_name" => "ART VANDALAY",
                                          "item_price" => "$6.09",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Rice, Pinto Beans, Shredded Cheese, Pico de Gallo, Sour Cream, Lettuce, Guacamole",
                                          "order_detail_id" => "16622880",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$6.09"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$0.47"
                                           },
                                           {
                                             "title" => "Tip",
                                             "amount" => "$16.00"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$22.56"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$6.09"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$0.47"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$6.56"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$16.00"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$22.56"
                                                               }
                     ]
                   },
                   {
                     "order_id" => "6928710",
                     "merchant_id" => "101393",
                     "order_dt_tm" => 1444138296,
                     "tip_amt" => "0.00",
                     "status" => "O",
                     "order_date" => "10/06/15",
                     "order_date2" => "2015-10-06",
                     "order_date3" => "10/6 9:31AM",
                     "order_date_task_retail" => "2015-10-06T09:31:00.0000",
                     "order_time" => "9:31",
                     "merchant" => {
                       "merchant_id" => "101393",
                       "merchant_user_id" => "1002",
                       "merchant_external_id" => "683",
                       "numeric_id" => "78434867",
                       "alphanumeric_id" => "90k9ksydh232",
                       "rewardr_programs" => nil,
                       "shop_email" => "mojos280@hotmail.com",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Cary",
                       "address1" => "280 Meeting St.",
                       "address2" => "",
                       "city" => "Cary",
                       "state" => "NC",
                       "zip" => "27511",
                       "country" => "US",
                       "lat" => "35.756664",
                       "lng" => "-78.744787",
                       "EIN_SS" => "16-1648470",
                       "description" => "",
                       "phone_no" => "9198541111",
                       "fax_no" => "",
                       "twitter_handle" => "",
                       "time_zone" => "-5",
                       "cross_street" => "",
                       "trans_fee_type" => "P",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "Y",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "Y",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => "",
                       "show_search" => "Y",
                       "lead_time" => "15",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => "9999999999",
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.080",
                       "minimum_android_version" => "2.080",
                       "live_dt" => "2012-03-28",
                       "facebook_caption_link" => "",
                       "custom_order_message" => "",
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-05:00) Eastern Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Reglr",
                                          "item_name" => "JOEY BAG",
                                          "item_price" => "$6.99",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Rice, No Beans, Pork, Shredded Cheese, Pico de Gallo",
                                          "order_detail_id" => "16622878",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$6.99"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$0.54"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$7.53"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$6.99"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$0.54"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$7.53"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$0.00"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$7.53"
                                                               }
                     ]
                   },
                   {
                     "order_id" => "6928707",
                     "merchant_id" => "101405",
                     "order_dt_tm" => 1444138196,
                     "tip_amt" => "14.00",
                     "status" => "O",
                     "order_date" => "10/06/15",
                     "order_date2" => "2015-10-06",
                     "order_date3" => "10/6 9:29AM",
                     "order_date_task_retail" => "2015-10-06T09:29:00.0000",
                     "order_time" => "9:29",
                     "merchant" => {
                       "merchant_id" => "101405",
                       "merchant_user_id" => "1002",
                       "merchant_external_id" => "299",
                       "numeric_id" => "77898076",
                       "alphanumeric_id" => "36s4l27f61g0",
                       "rewardr_programs" => nil,
                       "shop_email" => "mojos4350@hotmail.com",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Raleigh",
                       "address1" => "4350 Lassiter at North Hills Ave; Ste 100",
                       "address2" => "",
                       "city" => "Raleigh",
                       "state" => "NC",
                       "zip" => "27609",
                       "country" => "US",
                       "lat" => "35.837959",
                       "lng" => "-78.643162",
                       "EIN_SS" => "16-1648470",
                       "description" => "",
                       "phone_no" => "9197813446",
                       "fax_no" => "",
                       "twitter_handle" => "",
                       "time_zone" => "-5",
                       "cross_street" => "",
                       "trans_fee_type" => "P",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "Y",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "Y",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => nil,
                       "show_search" => "Y",
                       "lead_time" => "15",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => "9999999999",
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.080",
                       "minimum_android_version" => "2.080",
                       "live_dt" => "2012-03-30",
                       "facebook_caption_link" => "",
                       "custom_order_message" => "",
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-05:00) Eastern Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Reglr",
                                          "item_name" => "JOEY BAG",
                                          "item_price" => "$9.18",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Rice, Pinto Beans, Chicken, Extra Pork, Shredded Cheese, Pico de Gallo",
                                          "order_detail_id" => "16622876",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$9.18"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$0.71"
                                           },
                                           {
                                             "title" => "Tip",
                                             "amount" => "$14.00"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$23.89"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$9.18"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$0.71"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$9.89"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$14.00"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$23.89"
                                                               }
                     ]
                   },
                   {
                     "order_id" => "6928684",
                     "merchant_id" => "101403",
                     "order_dt_tm" => 1444080042,
                     "tip_amt" => "0.85",
                     "status" => "O",
                     "order_date" => "10/05/15",
                     "order_date2" => "2015-10-05",
                     "order_date3" => "10/5 5:20PM",
                     "order_date_task_retail" => "2015-10-05T17:20:00.0000",
                     "order_time" => "5:20",
                     "merchant" => {
                       "merchant_id" => "101403",
                       "merchant_user_id" => "1002",
                       "merchant_external_id" => "150",
                       "numeric_id" => "87653135",
                       "alphanumeric_id" => "67m82h5oek76",
                       "rewardr_programs" => nil,
                       "shop_email" => "mojos506@hotmail.com",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Cameron Village",
                       "address1" => "506 Daniels St.",
                       "address2" => "",
                       "city" => "Raleigh",
                       "state" => "NC",
                       "zip" => "27605",
                       "country" => "US",
                       "lat" => "35.791527",
                       "lng" => "-78.661145",
                       "EIN_SS" => "16-1648470",
                       "description" => "",
                       "phone_no" => "9196646637",
                       "fax_no" => "",
                       "twitter_handle" => "",
                       "time_zone" => "-5",
                       "cross_street" => "",
                       "trans_fee_type" => "P",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "Y",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "Y",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => "",
                       "show_search" => "Y",
                       "lead_time" => "15",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => "9999999999",
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.080",
                       "minimum_android_version" => "2.080",
                       "live_dt" => "2012-04-07",
                       "facebook_caption_link" => "",
                       "custom_order_message" => "",
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-05:00) Eastern Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Reglr",
                                          "item_name" => "JOEY BAG",
                                          "item_price" => "$8.48",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Rice, Pinto Beans, Chicken, Extra Chicken, Shredded Cheese, Pico de Gallo",
                                          "order_detail_id" => "16622849",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$8.48"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$0.66"
                                           },
                                           {
                                             "title" => "Tip",
                                             "amount" => "$0.85"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$9.99"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$8.48"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$0.66"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$9.14"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$0.85"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$9.99"
                                                               }
                     ]
                   },
                   {
                     "order_id" => "6928677",
                     "merchant_id" => "101403",
                     "order_dt_tm" => 1444079522,
                     "tip_amt" => "0.85",
                     "status" => "O",
                     "order_date" => "10/05/15",
                     "order_date2" => "2015-10-05",
                     "order_date3" => "10/5 5:12PM",
                     "order_date_task_retail" => "2015-10-05T17:12:00.0000",
                     "order_time" => "5:12",
                     "merchant" => {
                       "merchant_id" => "101403",
                       "merchant_user_id" => "1002",
                       "merchant_external_id" => "150",
                       "numeric_id" => "87653135",
                       "alphanumeric_id" => "67m82h5oek76",
                       "rewardr_programs" => nil,
                       "shop_email" => "mojos506@hotmail.com",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Cameron Village",
                       "address1" => "506 Daniels St.",
                       "address2" => "",
                       "city" => "Raleigh",
                       "state" => "NC",
                       "zip" => "27605",
                       "country" => "US",
                       "lat" => "35.791527",
                       "lng" => "-78.661145",
                       "EIN_SS" => "16-1648470",
                       "description" => "",
                       "phone_no" => "9196646637",
                       "fax_no" => "",
                       "twitter_handle" => "",
                       "time_zone" => "-5",
                       "cross_street" => "",
                       "trans_fee_type" => "P",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "Y",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "Y",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => "",
                       "show_search" => "Y",
                       "lead_time" => "15",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => "9999999999",
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.080",
                       "minimum_android_version" => "2.080",
                       "live_dt" => "2012-04-07",
                       "facebook_caption_link" => "",
                       "custom_order_message" => "",
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-05:00) Eastern Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Reglr",
                                          "item_name" => "JOEY BAG",
                                          "item_price" => "$8.48",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Rice, Pinto Beans, Chicken, Extra Pork, Shredded Cheese, Pico de Gallo",
                                          "order_detail_id" => "16622845",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$8.48"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$0.66"
                                           },
                                           {
                                             "title" => "Tip",
                                             "amount" => "$0.85"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$9.99"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$8.48"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$0.66"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$9.14"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$0.85"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$9.99"
                                                               }
                     ]
                   },
                   {
                     "order_id" => "6928655",
                     "merchant_id" => "101067",
                     "order_dt_tm" => 1444078782,
                     "tip_amt" => "0.00",
                     "status" => "O",
                     "order_date" => "10/05/15",
                     "order_date2" => "2015-10-05",
                     "order_date3" => "10/5 4:59PM",
                     "order_date_task_retail" => "2015-10-05T16:59:00.0000",
                     "order_time" => "4:59",
                     "merchant" => {
                       "merchant_id" => "101067",
                       "merchant_user_id" => "1002",
                       "merchant_external_id" => "1287",
                       "numeric_id" => "93871598",
                       "alphanumeric_id" => "67v2hg69ewk6",
                       "rewardr_programs" => nil,
                       "shop_email" => "Kendall@WelcometoMoes.com",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Kendall",
                       "address1" => "8746 Mills Drive",
                       "address2" => "",
                       "city" => "Kendall",
                       "state" => "FL",
                       "zip" => "33183",
                       "country" => "US",
                       "lat" => "25.686945",
                       "lng" => "-80.386569",
                       "EIN_SS" => "27-1550287",
                       "description" => "",
                       "phone_no" => "3055959898",
                       "fax_no" => "3055959899",
                       "twitter_handle" => "",
                       "time_zone" => "-5",
                       "cross_street" => "",
                       "trans_fee_type" => "P",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "N",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "Y",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => "1",
                       "show_search" => "Y",
                       "lead_time" => "30",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => nil,
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.080",
                       "minimum_android_version" => "2.080",
                       "live_dt" => "2012-03-23",
                       "facebook_caption_link" => "",
                       "custom_order_message" => "",
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-05:00) Eastern Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Rglr",
                                          "item_name" => "JOEY Moes Monday - comes with chips ",
                                          "item_price" => "$5.99",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Rice, Black Beans, Chicken, Shredded Cheese, Pico de Gallo",
                                          "order_detail_id" => "16622819",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$5.99"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$0.48"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$6.47"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$5.99"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$0.48"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$6.47"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$0.00"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$6.47"
                                                               }
                     ]
                   },
                   {
                     "order_id" => "6927957",
                     "merchant_id" => "1004",
                     "order_dt_tm" => 1442520876,
                     "tip_amt" => "0.00",
                     "status" => "O",
                     "order_date" => "09/17/15",
                     "order_date2" => "2015-09-17",
                     "order_date3" => "9/17 4:14PM",
                     "order_date_task_retail" => "2015-09-17T16:14:00.0000",
                     "order_time" => "4:14",
                     "merchant" => {
                       "merchant_id" => "1004",
                       "merchant_user_id" => "1002",
                       "merchant_external_id" => "123",
                       "numeric_id" => "82171713",
                       "alphanumeric_id" => "943rlrd48un6",
                       "rewardr_programs" => nil,
                       "shop_email" => "kbrown@moes.com",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Johnson Ferry Road / Glenridge",
                       "address1" => "860 Johnson Ferry Road",
                       "address2" => "",
                       "city" => "Atlanta",
                       "state" => "GA",
                       "zip" => "30342",
                       "country" => "US",
                       "lat" => "33.906859",
                       "lng" => "-84.359447",
                       "EIN_SS" => "26-0238526",
                       "description" => "Moes offers outstanding food with a fresh take on the southwest tradition.",
                       "phone_no" => "4043030081",
                       "fax_no" => "4043030081",
                       "twitter_handle" => nil,
                       "time_zone" => "-5",
                       "cross_street" => "",
                       "trans_fee_type" => "F",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "N",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "Y",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => "",
                       "show_search" => "Y",
                       "lead_time" => "15",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => "6178207130",
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.041",
                       "minimum_android_version" => "2.040",
                       "live_dt" => "2010-09-21",
                       "facebook_caption_link" => nil,
                       "custom_order_message" => nil,
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-05:00) Eastern Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Salad",
                                          "item_name" => "CLOSE TALKER",
                                          "item_price" => "$8.29",
                                          "item_quantity" => "1",
                                          "item_description" => "In a Bowl - No Shell, Pinto Beans, Pork, Shredded Cheese, Pico de Gallo, Tomatoes, Cucumbers, Black Olives, Fat-Free Salsa Vinaigrette(x2)",
                                          "order_detail_id" => "16621808",
                                          "item_note" => ""
                                        },
                                        {
                                          "size_name" => "TWO Tacos",
                                          "item_name" => "OVERACHIEVER",
                                          "item_price" => "$7.50",
                                          "item_quantity" => "1",
                                          "item_description" => "Soft Shell, Pinto Beans, Steak, Shredded Cheese, Pico de Gallo, Sour Cream, Lettuce, Guacamole",
                                          "order_detail_id" => "16621809",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$15.79"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$1.11"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$16.90"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$15.79"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$1.11"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$16.90"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$0.00"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$16.90"
                                                               }
                     ]
                   },
                   {
                     "order_id" => "6927897",
                     "merchant_id" => "1004",
                     "order_dt_tm" => 1442357468,
                     "tip_amt" => "0.00",
                     "status" => "O",
                     "order_date" => "09/15/15",
                     "order_date2" => "2015-09-15",
                     "order_date3" => "9/15 6:51PM",
                     "order_date_task_retail" => "2015-09-15T18:51:00.0000",
                     "order_time" => "6:51",
                     "merchant" => {
                       "merchant_id" => "1004",
                       "merchant_user_id" => "1002",
                       "merchant_external_id" => "123",
                       "numeric_id" => "82171713",
                       "alphanumeric_id" => "943rlrd48un6",
                       "rewardr_programs" => nil,
                       "shop_email" => "kbrown@moes.com",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Johnson Ferry Road / Glenridge",
                       "address1" => "860 Johnson Ferry Road",
                       "address2" => "",
                       "city" => "Atlanta",
                       "state" => "GA",
                       "zip" => "30342",
                       "country" => "US",
                       "lat" => "33.906859",
                       "lng" => "-84.359447",
                       "EIN_SS" => "26-0238526",
                       "description" => "Moes offers outstanding food with a fresh take on the southwest tradition.",
                       "phone_no" => "4043030081",
                       "fax_no" => "4043030081",
                       "twitter_handle" => nil,
                       "time_zone" => "-5",
                       "cross_street" => "",
                       "trans_fee_type" => "F",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "N",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "Y",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => "",
                       "show_search" => "Y",
                       "lead_time" => "15",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => "6178207130",
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.041",
                       "minimum_android_version" => "2.040",
                       "live_dt" => "2010-09-21",
                       "facebook_caption_link" => nil,
                       "custom_order_message" => nil,
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-05:00) Eastern Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Reglr",
                                          "item_name" => "HOMEWRECKER",
                                          "item_price" => "$7.59",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Rice, Black Beans, Chicken, Shredded Cheese, Pico de Gallo, Sour Cream, Lettuce, Guacamole",
                                          "order_detail_id" => "16621714",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$7.59"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$0.53"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$8.12"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$7.59"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$0.53"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$8.12"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$0.00"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$8.12"
                                                               }
                     ]
                   },
                   {
                     "order_id" => "6927436",
                     "merchant_id" => "101403",
                     "order_dt_tm" => 1441204300,
                     "tip_amt" => "1.26",
                     "status" => "O",
                     "order_date" => "09/02/15",
                     "order_date2" => "2015-09-02",
                     "order_date3" => "9/2 10:31AM",
                     "order_date_task_retail" => "2015-09-02T10:31:00.0000",
                     "order_time" => "10:31",
                     "merchant" => {
                       "merchant_id" => "101403",
                       "merchant_user_id" => "1002",
                       "merchant_external_id" => "150",
                       "numeric_id" => "87653135",
                       "alphanumeric_id" => "67m82h5oek76",
                       "rewardr_programs" => nil,
                       "shop_email" => "mojos506@hotmail.com",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Cameron Village",
                       "address1" => "506 Daniels St.",
                       "address2" => "",
                       "city" => "Raleigh",
                       "state" => "NC",
                       "zip" => "27605",
                       "country" => "US",
                       "lat" => "35.791527",
                       "lng" => "-78.661145",
                       "EIN_SS" => "16-1648470",
                       "description" => "",
                       "phone_no" => "9196646637",
                       "fax_no" => "",
                       "twitter_handle" => "",
                       "time_zone" => "-5",
                       "cross_street" => "",
                       "trans_fee_type" => "P",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "Y",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "Y",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => "",
                       "show_search" => "Y",
                       "lead_time" => "15",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => "9999999999",
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.080",
                       "minimum_android_version" => "2.080",
                       "live_dt" => "2012-04-07",
                       "facebook_caption_link" => "",
                       "custom_order_message" => "",
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-05:00) Eastern Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Reglr",
                                          "item_name" => "JOEY BAG",
                                          "item_price" => "$6.29",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Rice, No Beans, Chicken, Shredded Cheese, Pico de Gallo",
                                          "order_detail_id" => "16621054",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$6.29"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$0.49"
                                           },
                                           {
                                             "title" => "Tip",
                                             "amount" => "$1.26"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$8.04"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$6.29"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$0.49"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$6.78"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$1.26"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$8.04"
                                                               }
                     ]
                   }
      ],
      "totalOrders" => "11"
    }
  end

  def get_user_orders_json_2
    {
      "orders" => [{
                     "order_id" => "6923234",
                     "merchant_id" => "104998",
                     "order_dt_tm" => 1432851603,
                     "tip_amt" => "0.00",
                     "status" => "O",
                     "order_date" => "05/28/15",
                     "order_date2" => "2015-05-28",
                     "order_date3" => "5/28 5:20PM",
                     "order_date_task_retail" => "2015-05-28T17:20:00.0000",
                     "order_time" => "5:20",
                     "merchant" => {
                       "merchant_id" => "104998",
                       "merchant_user_id" => "0",
                       "merchant_external_id" => "6090",
                       "numeric_id" => "48033241",
                       "alphanumeric_id" => "2892bqirna41",
                       "rewardr_programs" => nil,
                       "shop_email" => "jof8981835@aol.com",
                       "brand_id" => "112",
                       "name" => "Moe\"s Southwest Grill",
                       "display_name" => "Springfield",
                       "address1" => "2825 S. Glenstone",
                       "address2" => "Battlefield Mall, H08F",
                       "city" => "Springfield",
                       "state" => "MO",
                       "zip" => "65804",
                       "country" => "US",
                       "lat" => "37.162575",
                       "lng" => "-93.262533",
                       "EIN_SS" => "26-3868282",
                       "description" => "N",
                       "phone_no" => "4178810022",
                       "fax_no" => "",
                       "twitter_handle" => nil,
                       "time_zone" => "-6",
                       "cross_street" => nil,
                       "trans_fee_type" => "F",
                       "trans_fee_rate" => "0.00",
                       "show_tip" => "Y",
                       "tip_minimum_percentage" => "0",
                       "tip_minimum_trigger_amount" => "0.00",
                       "donate" => "0",
                       "cc_processor" => "I",
                       "merchant_type" => "N",
                       "active" => "Y",
                       "ordering_on" => "Y",
                       "inactive_reason" => nil,
                       "show_search" => "Y",
                       "lead_time" => "15",
                       "immediate_message_delivery" => "N",
                       "delivery" => "N",
                       "advanced_ordering" => "N",
                       "order_del_type" => "T",
                       "order_del_addr" => nil,
                       "order_del_addr2" => "web1",
                       "payment_cycle" => "W",
                       "fee_payment" => "A",
                       "minimum_iphone_version" => "2.040",
                       "minimum_android_version" => "2.040",
                       "live_dt" => "2014-03-21",
                       "facebook_caption_link" => nil,
                       "custom_order_message" => nil,
                       "custom_menu_message" => "",
                       "time_zone_string" => "(GMT-06:00) Central Time (US & Canada)",
                       "moved_to_merchant_id" => nil,
                       "uploaded_menu" => nil,
                       "uploaded_logo" => nil,
                       "group_ordering_on" => "0"
                     },
                     "gift_used" => nil,
                     "order_summary" => {
                       "cart_items" => [{
                                          "size_name" => "Reglr",
                                          "item_name" => "Sriracha Burrito",
                                          "item_price" => "$7.55",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Rice, Black Beans, Chicken, Sriracha Sauce, Pico de Gallo, Sour Cream, Pickled Jalapenos, Crushed Tortilla Chips",
                                          "order_detail_id" => "16614228",
                                          "item_note" => ""
                                        },
                                        {
                                          "size_name" => " ",
                                          "item_name" => "Sriracha Stack",
                                          "item_price" => "$8.05",
                                          "item_quantity" => "1",
                                          "item_description" => "Flour Tortilla, Black Beans, Chicken, Queso Inside Your Item, Sriracha Sauce",
                                          "order_detail_id" => "16614229",
                                          "item_note" => ""
                                        }
                       ],
                       "receipt_items" => [{
                                             "title" => "Subtotal",
                                             "amount" => "$15.60"
                                           },
                                           {
                                             "title" => "Tax",
                                             "amount" => "$1.19"
                                           },
                                           {
                                             "title" => "Total",
                                             "amount" => "$16.79"
                                           }
                       ]
                     },
                     "receipt_items_for_merchant_printout" => [{
                                                                 "title" => "Subtotal",
                                                                 "amount" => "$15.60"
                                                               },
                                                               {
                                                                 "title" => "Tax",
                                                                 "amount" => "$1.19"
                                                               },
                                                               {
                                                                 "title" => "Total",
                                                                 "amount" => "$16.79"
                                                               },
                                                               {
                                                                 "title" => "Tip",
                                                                 "amount" => "$0.00"
                                                               },
                                                               {
                                                                 "title" => "Grand Total",
                                                                 "amount" => "$16.79"
                                                               }
                     ]
                   }
      ],
      "totalOrders" => "11"
    }
  end

  def get_checkout_data
    {"lead_times_array"=>[1405006471, 1405006531, 1405006591],
     "promo_amt"=>"0.00",
     "order_amt"=>"6.95",
     "tip_array"=>[{"No Tip"=>0}, {"10%"=>"0.70"}, {"15%"=>"1.04"}],
     "total_tax_amt"=>"0.56",
     "convenience_fee"=>"0.00",
     "accepted_payment_types"=>
       [{"merchant_payment_type_map_id"=>"1002", "name"=>"Cash", "splickit_accepted_payment_type_id"=>"1000", "billing_entity_id"=>nil},
        {"merchant_payment_type_map_id"=>"2002", "name"=>"Credit", "splickit_accepted_payment_type_id"=>"2000", "billing_entity_id"=>nil},
        {"merchant_payment_type_map_id"=>"3002", "name"=>"Pit Card", "splickit_accepted_payment_type_id"=>"3000", "billing_entity_id"=>nil}]}
  end

  def checkout_error_json
    {
      http_code: 200,
      stamp: "tweb03-i-027c8323-14OQ17W",
      error: {
        error: "Sorry, something has changed with this merchant.",
        error_code: 999
      }
    }.to_json
  end

  def checkout_json(params={})
    {
      data: {
        lead_times_array: [1405006471, 1405006531, 1405006591],
        promo_amt: params[:promo_amt] || nil,
        order_amt: "6.65",
        tip_array:
          [
            {"No Tip" => 0}, {"10%" => "0.70"}, {"15%" => "1.04"}
          ],
        total_tax_amt: "0.56",
        convenience_fee: "0.00",
        accepted_payment_types:
          [
            {
              merchant_payment_type_map_id: "1002",
              name: "Cash",
              splickit_accepted_payment_type_id: "1000",
              billing_entity_id: nil
            },
            {
              merchant_payment_type_map_id: "2002",
              name: "Credit",
              splickit_accepted_payment_type_id: "2000",
              billing_entity_id: nil
            },
            {
              merchant_payment_type_map_id: "3002",
              name: "Pit Card",
              splickit_accepted_payment_type_id: "3000",
              billing_entity_id: nil
            }
          ]
      }
    }
  end

  def checkout_cart_json(sub_total="0.00")
    {
     items:
      [
        {
          item_id: 931,
          mods: [],
          quantity: 1,
          size_id: "1",
          points_used: 0
        }
      ],
     merchant_id: "4000",
     user_id: "2",
     sub_total: sub_total,
     total_points_used: 0,
     loyalty_number: nil,

     delivery: "N"
    }.to_json
  end

  def delivery_checkout_cart_json(sub_total="0.00")
    {
      items:
      [
        {
          item_id: 931,
          mods: [],
          quantity: 1,
          size_id: "1",
          points_used: 0
        }
      ],
      merchant_id: "4000",
      user_id: "2",
      sub_total: sub_total,
      total_points_used: 0,
      loyalty_number: nil,
      promo_code: nil,
      user_addr_id: "202402",
      delivery: "Y"
    }.to_json
  end

  def default_readable_hours
    { "pickup" => { "1" => { "Sunday" => "11:00am-8:00pm" },
                    "2" => { "Monday" => "11:00am-9:00pm" },
                    "3" => { "Tuesday" => "closed" },
                    "4" => { "Wednesday" => "closed" },
                    "5" => { "Thursday" => "11:00am-9:00pm" },
                    "6" => { "Friday" => "11:00am-9:00pm" },
                    "7" => { "Saturday" => "11:00am-9:00pm" } },
      "delivery" => { "1" => { "Sunday" => "closed" },
                      "2" => { "Monday" => "11:00am-9:30pm" },
                      "3" => { "Tuesday" => "11:00am-9:30pm" },
                      "4" => { "Wednesday" => "11:00am-9:30pm" },
                      "5" => { "Thursday" => "12:00pm-9:30pm" },
                      "6" => { "Friday" => "11:00am-9:30pm" },
                      "7" => { "Saturday" => "11:00am-9:30pm" } } }
  end

  def create_checkout_data(options = {})
    data = get_checkout_data.merge(options)
    CheckoutData.new(data)
  end

  def valid_headers
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Faraday v0.9.0',
      'X-Splickit-Client'=>'order',
      'X-Splickit-Client-Device'=>'web',
      'X-Splickit-Client-Id'=>'com.splickit.order',
      'X-Splickit-Client-Version'=>'3'
    }
  end
end




