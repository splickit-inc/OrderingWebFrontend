module CheckoutsSpecHelper
  def cart_find_stub(options = {})
    @hash = {ucid: "9109-nyw5d-g8225-irawz",
             stamp: "tweb05-YI0TMP4",
             merchant_id: "103351",
             order_dt_tm: "0000-00-00 00:00:00",
             pickup_dt_tm: "0000-00-00 00:00:00",
             order_amt: "4.50",
             promo_code: "",
             promo_id: "0",
             promo_amt: "0.00",
             total_tax_amt: "0.47",
             trans_fee_amt: "0.25",
             tip_amt: "0.00",
             customer_donation_amt: "0.00",
             grand_total: "5.22",
             grand_total_to_merchant: "0.00",
             cash: "N",
             merchant_donation_amt: "0.00",
             note: "",
             status: "Y",
             order_qty: "1",
             payment_file: nil,
             order_type: "R",
             phone_no: nil,
             user_delivery_location_id: nil,
             requested_delivery_time: nil,
             device_type: nil,
             app_version: "",
             skin_id: "0",
             distance_from_store: "0.00",
             order_summary: {cart_items: [{size_name: "one size",
                                           item_name: "BaconEggnCheese",
                                           item_price: "$4.50",
                                           item_quantity: "1",
                                           item_description: "American, Egg, Bacon",
                                           order_detail_id: "22112721",
                                           item_note: ""}],
                             receipt_items: [{title: "Subtotal",
                                              amount: "$4.50"},
                                             {title: "Tax",
                                              amount: "$0.47"},
                                             {title: "Convenience Fee",
                                              amount: "$0.25"},
                                             {title: "Total",
                                              amount: "$5.22"}]}}
    default_return = @hash

    auth_token = get_auth_token(options[:auth_token] || "72JZAQC5D81A1QDU44K3")
    cart_id = options[:merchant_id] || "9109-nyw5d-g8225-irawz"
    var_return = default_return.merge(options[:return] || {})

    stub_request(:get, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/cart/#{ cart_id }")
      .to_return(status: 200, body: { data: var_return }.to_json)
  end

  def cart_create_stub(options = {})
    default_body = { user_id: "2",
                     merchant_id: "4000",
                     user_addr_id: nil,
                     items: [{ item_id: 931,
                               quantity: 1,
                               mods: [{ modifier_item_id: "2",
                                        mod_quantity: 1,
                                        name: "Spicy Club Sauce" }],
                               size_id: "1",
                               points_used: nil,
                               brand_points_id: nil,
                               note: "" }],
                     total_points_used: 0 }
    default_return = { id: "3903",
                       ucid: "9705-j069h-ce8w3-425di",
                       stamps: "tweb03-i-027c8323-ZD0N023;tweb03-i-027c8323-ZD0N023",
                       status: "A",
                       submitted_date_time: 943920000,
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
                                                          amount: "$7.30" }] }}

    auth_token = get_auth_token(options[:auth_token] || "ASNDKASNDAS")
    body = default_body.merge(options[:body] || {})
    var_return = default_return.merge(options[:return] || {})

    stub_request(:post, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/cart")
      .with(body: body)
      .to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def cart_update_stub(options = {})
    default_body = { user_id: "2",
                     merchant_id: "4000",
                     submitted_order_type: "pickup",
                     user_addr_id: nil,
                     group_order_token: nil,
                     items: [{ item_id: 931,
                               quantity: 1,
                               mods: [{ modifier_item_id: "2",
                                        mod_quantity: 1,
                                        name: "Spicy Club Sauce" }],
                               size_id: "1",
                               order_detail_id: nil,
                               status: "new",
                               external_detail_id: anything,
                               points_used: nil,
                               brand_points_id: nil,
                               note: "" }],
                     total_points_used: 0 }

    default_body.delete(:items) if options[:no_items]

    default_return = { promo_amt: "0.00",
                       order_amt: "6.89",
                       total_tax_amt: "0.41",
                       convenience_fee: "0.00",
                       order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                       item_price: "6.89",
                                                       item_quantity: "1",
                                                       item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                       order_detail_id: "27479804",
                                                       note: "" }],
                                        order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                             user_id: "4777193",
                                                                             items: [{ item_id: "931",
                                                                                       size_id: "1",
                                                                                       quantity: "1",
                                                                                       order_detail_id: "27479804",
                                                                                       external_detail_id: "8945-as",
                                                                                       status: "saved",
                                                                                       mods: [{ modifier_item_id: "2",
                                                                                                mod_quantity: "1" }] }] },
                                        receipt_items: [{ title: "Subtotal",
                                                          amount: "$6.89" },
                                                        { title: "Tax",
                                                          amount: "$0.41" },
                                                        { title: "Total",
                                                          amount: "$7.30" }] },
                       ucid: "9705-j069h-ce8w3-425di",
                       cart_ucid: "9705-j069h-ce8w3-425di" }

    auth_token = get_auth_token(options[:auth_token] || "ASNDKASNDAS")
    body = options[:body] == anything ? options[:body] : default_body.merge(options[:body] || {})
    var_return = default_return.merge(options[:return] || {})

    stub = stub_request(:post, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/cart/#{ options[:cart_id] }")
             .with(body: hash_including(body))

    return stub.to_return(status: 422, body: { error: options[:error] }.to_json) if options[:error]

    stub.to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def cart_checkout_stub(options = {})
    default_body = { user_id: "2",
                     merchant_id: "4000",
                     submitted_order_type: "pickup",
                     user_addr_id: nil,
                     group_order_token: nil,
                     items: [{ item_id: 931,
                               quantity: 1,
                               mods: [{ modifier_item_id: "2",
                                        mod_quantity: 1,
                                        name: "Spicy Club Sauce" }],
                               size_id: "1",
                               order_detail_id: nil,
                               status: "new",
                               external_detail_id: anything,
                               points_used: nil,
                               brand_points_id: nil,
                               note: "" }],
                     total_points_used: 0 }

    default_body.delete(:items) if options[:no_items]

    default_return = { time_zone_string: "America Los_Angeles",
                       time_zone_offset: -8,
                       user_message: nil,
                       lead_times_array: [1415823383, 1415823443, 1415823503, 1415823563, 1415823623, 1415823683,
                                          1415823743, 1415823803, 1415823863, 1415823923, 1415823983, 1415824043,
                                          1415824103, 1415824163, 1415824223, 1415824283, 1415824583, 1415824883,
                                          1415825183, 1415825483, 1415825783, 1415826083, 1415826383, 1415826683,
                                          1415826983, 1415827283, 1415827583, 1415827883, 1415828183, 1415828483,
                                          1415828783, 1415829083, 1415829983, 1415830883, 1415831783, 1415832683,
                                          1415833583, 1415834483, 1415835383, 1415836283, 1415837183],
                       promo_amt: "0.00",
                       order_amt: "6.89",
                       tip_array: get_tip_array(order_amt: 6.89, percentage: [10, 15, 20]),
                       total_tax_amt: "0.41",
                       convenience_fee: "0.00",
                       accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                  name: "Account Credit",
                                                  splickit_accepted_payment_type_id: "5000",
                                                  billing_entity_id: nil }],
                       order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                       item_price: "6.89",
                                                       item_quantity: "1",
                                                       item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                       order_detail_id: "27479804",
                                                       note: "" }],
                                        order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                             user_id: "4777193",
                                                                             items: [{ item_id: "931",
                                                                                       size_id: "1",
                                                                                       quantity: "1",
                                                                                       order_detail_id: "27479804",
                                                                                       external_detail_id: "8945-as",
                                                                                       status: "saved",
                                                                                       mods: [{ modifier_item_id: "2",
                                                                                                mod_quantity: "1" }] }] },
                                        receipt_items: [{ title: "Subtotal",
                                                          amount: "$6.89" },
                                                        { title: "Tax",
                                                          amount: "$0.41" },
                                                        { title: "Total",
                                                          amount: "$7.30" }] },
                       cart_ucid: "9705-j069h-ce8w3-425di" }

    auth_token = get_auth_token(options[:auth_token] || "ASNDKASNDAS")
    cart_id = "#{ options[:cart_id] }/" if options[:cart_id].present?
    body = options[:body] == anything ? options[:body] : default_body.merge(options[:body] || {})
    var_return = default_return.merge(options[:return] || {})

    stub = stub_request(:post, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/cart/#{ cart_id }checkout")
             .with(body: hash_including(body))

    return stub.to_return(status: 422, body: { error: options[:error] }.to_json) if options[:error]

    stub.to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def cart_promo_stub(options = {})
    default_return = { time_zone_string: "America Los_Angeles",
                       time_zone_offset: -8,
                       user_message: nil,
                       lead_times_array: [1415823383, 1415823443, 1415823503, 1415823563, 1415823623, 1415823683,
                                          1415823743, 1415823803, 1415823863, 1415823923, 1415823983, 1415824043,
                                          1415824103, 1415824163, 1415824223, 1415824283, 1415824583, 1415824883,
                                          1415825183, 1415825483, 1415825783, 1415826083, 1415826383, 1415826683,
                                          1415826983, 1415827283, 1415827583, 1415827883, 1415828183, 1415828483,
                                          1415828783, 1415829083, 1415829983, 1415830883, 1415831783, 1415832683,
                                          1415833583, 1415834483, 1415835383, 1415836283, 1415837183],
                       promo_amt: "-1.00",
                       order_amt: "6.89",
                       tip_array: get_tip_array(order_amt: 6.89, percentage: [10, 15, 20]),
                       total_tax_amt: "0.41",
                       convenience_fee: "0.00",
                       discount_amt: "1.00",
                       accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                  name: "Account Credit",
                                                  splickit_accepted_payment_type_id: "5000",
                                                  billing_entity_id: nil }],
                       order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                       item_price: "6.89",
                                                       item_quantity: "1",
                                                       item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                       order_detail_id: "6082053",
                                                       note: "" }],
                                        receipt_items: [{ title: "Promo Discount",
                                                          amount: "$-1.00" },
                                                        { title: "Subtotal",
                                                          amount: "$6.89" },
                                                        { title: "Tax",
                                                          amount: "$0.41" },
                                                        { title: "Total",
                                                          amount: "$6.30" }] },
                       cart_ucid: "9705-j069h-ce8w3-425di" }

    auth_token = get_auth_token(options[:auth_token] || "ASNDKASNDAS" )
    cart_id = options[:cart_id] || "9705-j069h-ce8w3-425di"
    promo_code = options[:promo_code] || "promo"
    var_return = default_return.merge(options[:return] || {})

    stub = stub_request(:get, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/cart/#{ cart_id }/checkout?promo_code=#{ promo_code }")

    return stub.to_return(status: 200, body: { error: options[:error] }.to_json) if options[:error]

    stub.to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def cart_get_checkout_stub(options = {})
    default_return = { time_zone_string: "America Los_Angeles",
                       time_zone_offset: -8,
                       user_message: nil,
                       lead_times_array: [1415823383, 1415823443, 1415823503, 1415823563, 1415823623, 1415823683,
                                          1415823743, 1415823803, 1415823863, 1415823923, 1415823983, 1415824043,
                                          1415824103, 1415824163, 1415824223, 1415824283, 1415824583, 1415824883,
                                          1415825183, 1415825483, 1415825783, 1415826083, 1415826383, 1415826683,
                                          1415826983, 1415827283, 1415827583, 1415827883, 1415828183, 1415828483,
                                          1415828783, 1415829083, 1415829983, 1415830883, 1415831783, 1415832683,
                                          1415833583, 1415834483, 1415835383, 1415836283, 1415837183],
                       promo_amt: "0.00",
                       order_amt: "6.89",
                       tip_array: get_tip_array(order_amt: 6.89, percentage: [10, 15, 20]),
                       total_tax_amt: "0.41",
                       convenience_fee: "0.00",
                       accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                  name: "Account Credit",
                                                  splickit_accepted_payment_type_id: "5000",
                                                  billing_entity_id: nil }],
                       order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                       item_price: "6.89",
                                                       item_quantity: "1",
                                                       item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                       order_detail_id: "27479804",
                                                       note: "" }],
                                        order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                             user_id: "4777193",
                                                                             items: [{ item_id: "931",
                                                                                       size_id: "1",
                                                                                       quantity: "1",
                                                                                       order_detail_id: "27479804",
                                                                                       external_detail_id: "8945-as",
                                                                                       status: "saved",
                                                                                       mods: [{ modifier_item_id: "2",
                                                                                                mod_quantity: "1" }] }] },
                                        receipt_items: [{ title: "Subtotal",
                                                          amount: "$6.89" },
                                                        { title: "Tax",
                                                          amount: "$0.41" },
                                                        { title: "Total",
                                                          amount: "$7.30" }] },
                       cart_ucid: "9705-j069h-ce8w3-425di" }

    auth_token = get_auth_token(options[:auth_token] || "ASNDKASNDAS")
    cart_id = options[:cart_id] || "9705-j069h-ce8w3-425di"
    var_return = default_return.merge(options[:return] || {})

    stub = stub_request(:get, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/cart/#{ cart_id }/checkout")

    return stub.to_return(status: 422, body: { error: options[:error] }.to_json) if options[:error]

    stub.to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def checkout_stubs(options = {})
    cart_update_stub(options)
    options[:cart_id] = options[:return][:ucid] || "9705-j069h-ce8w3-425di" if options[:cart_id].blank? && options[:return].present?
    cart_get_checkout_stub(options)
  end
end