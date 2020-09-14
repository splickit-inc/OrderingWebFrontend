require 'rails_helper'
require './spec/support/checkouts_spec_helper.rb'
require 'api'

module FeatureSpecHelper
  include CheckoutsSpecHelper

  def feature_sign_in(options = {})
    email = options[:email] || "bob@roberts.com"
    password = options[:password] || "password"
    user_return = options[:user_return]
    selector = options[:sign_in_selector] || "#sign-in"
    auth_token = user_return && (user_return[:splickit_authentication_token] || user_return["splickit_authentication_token"]) || "ASNDKASNDAS"
    remember_me = options[:remember_me] || false

    user_authenticate_stub(auth_token: { email: email, password: password },
                           return: user_return)
    user_find_stub(auth_token: auth_token, return: user_return)

    click_link("Sign in") if selector == "#sign-in"

    if remember_me
      modifier = find ".custom_align_left.checkbox-container"
      checkbox = modifier.find("label")
      checkbox.click
    end

    expect(page).to have_selector(selector)
    expect(page).to have_content("SIGN IN")

    within(selector) do
      fill_in "user_email", with: email
      fill_in "user_password", with: password
      click_button "Sign In"
    end
  end

  def feature_sign_up(options = {})
    first_name = options[:first_name] || "Mr."
    last_name = options[:last_name] || "Bacon"
    email = options[:email] || "mr@bacon.com"
    contact_no = options[:contact_no] || "888-555-1234"
    password = options[:password] || "password"
    birthday = options[:birthday] || ""

    user_return = options[:user_return]
    auth_token = user_return && (user_return[:splickit_authentication_token] || user_return["splickit_authentication_token"]) || "ASNDKASNDAS"

    user_create_stub(body: { first_name: first_name,
                             last_name: last_name,
                             email: email,
                             contact_no: contact_no,
                             birthday: birthday,
                             password: password },
                     return: user_return)

    user_find_stub(auth_token: auth_token, return: user_return)

    within("div.sign-in") do
      click_link "JOIN NOW"
    end

    expect(page).to have_selector(".sign-up")

    within(".sign-up") do
      fill_in "First name", with: first_name
      fill_in "Last name", with: last_name
      fill_in "Email address", with: email
      fill_in "Phone number", with: contact_no
      fill_in "user[birthday]", with: birthday
      fill_in "Create a password", with: password

      click_button "Sign Up"
    end
  end

  def feature_guest_sign_up(options = {})
    first_name = options[:first_name] || "Mr."
    email = options[:email] || "mr@bacon.com"
    contact_no = options[:contact_no] || "888-555-1234"
    user_return = options[:user_return]
    auth_token = user_return && (user_return[:splickit_authentication_token] || user_return["splickit_authentication_token"]) || "ASNDKASNDAS"

    user_create_stub(body: { first_name: first_name,
                             email: email,
                             contact_no: contact_no,
                             is_guest: "true" },
                     return: user_return)

    user_find_stub(auth_token: auth_token, return: user_return)

    expect(page).to have_link("Continue as Guest")

    click_link "Continue as Guest"

    expect(page).to have_selector(".sign-up")

    # should render all Guest sign up page
    within("div.sign-up") do
      fill_in "First name", with: first_name
      fill_in "Email address", with: email
      fill_in "Phone number", with: contact_no

      expect(page).to have_css("input[type='submit']")
      expect(find("input[type='submit']").value).to eq("Continue as Guest")
    end

    click_button "Continue as Guest"
  end

  def user_create_stub(options = {})
    default_body = { first_name: "Mr.",
                     email: "mr@bacon.com",
                     contact_no: "888-555-1234" }

    default_return = { first_name: "Mr.",
                       last_name: "Bacon",
                       email: "mr@bacon.com",
                       contact_no: "1231231234",
                       uuid: "7088-yybmg-o52uw-5f23g",
                       balance: 0,
                       user_id: "7088-yybmg-o52uw-5f23g",
                       user_message_title: "Hello!",
                       splickit_authentication_token: "S56LKZ92UD9W07V99806",
                       splickit_authentication_token_expires_at: 1413619815 }

    auth_token = get_auth_token(email: "admin", password: "welcome")
    body = default_body.merge(options[:body] || {})
    var_return = default_return.merge(options[:return] || {})

    stub_request(:post, "http://#{ auth_token }#{ API.domain }#{ API.base_path }/users")
        .with(body: body).to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def merchant_catering_data_stub(options = {})
    default_return = { available_catering_times: { max_days_out: 4,
                                                   time_zone: "America/Los_Angeles",
                                                   daily_time:[
                                                       [{ ts: 1483992000, time: "1:00 pm" },
                                                        { ts: 1483995600, time: "2:00 pm"}],
                                                       [{ ts: 1483999200, time: "3:00 pm"}]]},
                       catering_message_to_user_on_create_order: "test",
                       minimum_pickup_amount: "50.00",
                       minimum_delivery_amount: "50.00" }

    merchant_id = options[:merchant_id] || "102237"
    order_type = options[:order_type] || "pickup"
    auth_token = get_auth_token(options[:auth_token] || "72JZAQC5D81A1QDU44K3")
    var_return = default_return.merge(options[:return] || {})

    stub_request(:get, "http://#{ auth_token }#{ API.domain }#{ API.base_path }/merchants/#{ merchant_id }/cateringorderavailabletimes/#{ order_type }")
        .to_return(status: 200, body: { data: var_return }.to_json)
  end

  def catering_create_stub(options = {})
    default_body = { number_of_people: "1",
                     merchant_id: "106004",
                     timestamp_of_event: "1484169890",
                     contact_name: "Jose",
                     contact_phone: "555-555-5555",
                     notes: "1" }

    default_return = { id: "1001",
                       number_of_people: "1",
                       event: "",
                       order_type: "delivery",
                       order_id: "12208606",
                       user_delivery_location_id: nil,
                       date_tm_of_event: "2017-01-11 14:24:50",
                       timestamp_of_event: "1484169890",
                       contact_info: "Jose 555-555-5555",
                       notes: nil,
                       status: "In Progress",
                       insert_id: 1001,
                       ucid: "4076-1de8d-57dbc-lar86" }

    auth_token = get_auth_token(options[:auth_token] || "72JZAQC5D81A1QDU44K3")
    body = default_body.merge(options[:body] || {})
    var_return = default_return.merge(options[:return] || {})

    stub_request(:post, "http://#{ auth_token }#{ API.domain }#{ API.base_path }/catering")
        .with(body: body).to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def mockup_valid_select_time
    page.execute_script('$("#catering_timestamp_of_event").empty().enable().append($
("<option>").text("1:00 pm").val(1483992000)).removeClass("hidden");
          $(".no_time_label").addClass("hidden");')
  end

  def group_order_create_stub(options = {})
    default_body = { merchant_id: "102237",
                     merchant_menu_type: "pickup",
                     participant_emails: "",
                     group_order_type: "1",
                     notes: "" }

    default_return = { merchant_id: "102237",
                       merchant_menu_type: "pickup",
                       participant_emails: "",
                       notes: "",
                       admin_user_id: "1460321",
                       group_order_token: "9109-nyw5d-g8225-irawz",
                       expires_at: 1421789477,
                       group_order_id: 2290,
                       group_order_type: "1",
                       order_id: "2479467" }

    auth_token = get_auth_token(options[:auth_token] || "72JZAQC5D81A1QDU44K3")
    body = default_body.merge(options[:body] || {})
    var_return = default_return.merge(options[:return] || {})

    stub_request(:post, "http://#{ auth_token }#{ API.domain }#{ API.base_path }/grouporders")
        .with(body: body).to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def group_order_submit_stub(options = {})
    default_return =  {
        group_order_id: "106",
        group_order_token: "9705-j069h-ce8w3-425di",
        admin_user_id: user_data["user_id"],
        merchant_id: merchant.merchant_id,
        group_order_type: "2",
        sent_ts: "2016-05-20 16:24:09",
        notes: "",
        participant_emails: "",
        merchant_menu_type: "pickup",
        expires_at: "1463934219",
        status: "Submitted",
        user_addr_id: "0",
        order_id: "12202413",
        send_on_local_time_string: "Friday 10:38 am",
        auto_send_activity_id: "95"
    }

    auth_token = get_auth_token(options[:auth_token] || "72JZAQC5D81A1QDU44K3")
    group_order_token = options[:group_order_token] || "9109-nyw5d-g8225-irawz"
    var_return = default_return.merge(options[:return] || {})

    stub_request(:post, "http://#{ auth_token }#{ API.domain }#{ API.base_path }/grouporders/#{ group_order_token }/submit")
        .to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def group_order_increment_stub(options = {})
    default_return = { group_order_id: "2290",
                       group_order_token: "9109-nyw5d-g8225-irawz",
                       merchant_id: "102237",
                       sent_ts: "0000-00-00 00 =>00 =>00",
                       notes:"",
                       participant_emails: "",
                       merchant_menu_type: "pickup",
                       expires_at: "1421789477",
                       send_on_local_time_string: "9:31 pm",
                       group_order_type: "1",
                       status: "active",
                       group_order_admin: { first_name: "mr",
                                            last_name: "bean",
                                            email: "mr@bean.com",
                                            admin_uuid: "1195-vdi97-q2kug-38j07" },
                       order_summary: nil }

    auth_token = get_auth_token(options[:auth_token] || "72JZAQC5D81A1QDU44K3")
    group_order_token = options[:group_order_token] || "9109-nyw5d-g8225-irawz"
    time = options[:time] || "10"
    var_return = default_return.merge(options[:return] || {})

    stub = stub_request(:post, "http://#{ auth_token }#{ API.domain }#{ API.base_path }/grouporders/#{ group_order_token }/increment/#{ time }")

    return stub.to_return(status: 500, body: { error: options[:error] }.to_json) if options[:error]

    stub.to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def group_order_add_items_stub(options = {})
    default_body = { user_id: "1195-vdi97-q2kug-38j07",
                     merchant_id: "102237",
                     items: [{ item_id: 931,
                               quantity: 1,
                               mods: [{ modifier_item_id: 472,
                                        mod_quantity: 1, name: "Spicy Club Sauce" },
                                      { modifier_item_id: 477,
                                        mod_quantity: 1,
                                        name: "Just A Pile Of Beans" },
                                      { modifier_item_id: 478,
                                        mod_quantity: 1,
                                        name: "Octopus Jerky" }],
                               size_id: "3",
                               note: "" }] }

    default_return = { group_order_detail_id: 15990 }

    auth_token = get_auth_token(options[:auth_token] || "72JZAQC5D81A1QDU44K3")
    group_order_id = options[:group_order_id] || "9109-nyw5d-g8225-irawz"
    body = default_body.merge(options[:body] || {})
    var_return = default_return.merge(options[:return] || {})

    stub_request(:post, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/grouporders/#{ group_order_id }")
        .with(body: body).to_return(status: 200, body: { data: var_return }.to_json)
  end

  def group_order_find_stub(options = {})
    default_return = { group_order_id: "2290",
                       group_order_token: "9109-nyw5d-g8225-irawz",
                       merchant_id: "102237",
                       sent_ts: "0000-00-00 00 =>00 =>00",
                       notes:"",
                       participant_emails: "",
                       merchant_menu_type: "pickup",
                       expires_at: "1421789477",
                       send_on_local_time_string: "9:31 pm",
                       group_order_type: "1",
                       status: "active",
                       group_order_admin: { first_name: "mr",
                                            last_name: "bean",
                                            email: "mr@bean.com",
                                            admin_uuid: "1195-vdi97-q2kug-38j07" },
                       order_summary: nil }

    auth_token = get_auth_token(options[:auth_token] || "72JZAQC5D81A1QDU44K3")
    group_order_token = options[:group_order_token] || "9109-nyw5d-g8225-irawz"
    var_return = default_return.merge(options[:return] || {})

    stub = stub_request(:get, "http://#{ auth_token }#{ API.domain }#{ API.base_path }/grouporders/#{ group_order_token }")

    return stub.to_return(status: 422, body: { error: options[:error] }.to_json) if options[:error]

    stub.to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def user_store_address_stub(options = {})
    default_body = { business_name: "Geisty's Company",
                     address1: "1116 13th Street",
                     address2: "St",
                     city: "Geisty's Dogg House, Boulder",
                     state: "CO",
                     zip: "80305",
                     phone_no: "1234567890",
                     instructions: "Don't mind the sock." }

    default_return = { user_addr_id: "202402",
                       user_id: "2",
                       name: "Gesty's Reclamation Plant",
                       business_name: "Geisty's Company",
                       address1: "1116 13th Street",
                       address2: "St",
                       city: "Geisty's Dogg House, Boulder",
                       state: "CO",
                       zip: "80305",
                       lat: "39.8149386187446",
                       lng: "-104.956209155655",
                       phone_no: "1234567890",
                       instructions: "Don't mind the sock." }

    auth_token = get_auth_token(options[:auth_token] || "ASNDKASNDAS")
    body = default_body.merge(options[:body] || {})
    var_return = default_return.merge(options[:return] || {})

    stub_request(:post, "#{ API.protocol }://#{ auth_token }#{ API.domain }/app2/phone/setuserdelivery")
        .with(status: 200, body: body).to_return(status: 200, body: var_return.to_json)
  end

  def group_order_available_times_find_stub(options = {})
    default_return = { submit_times_array:[ 1460561580, 1460561640, 1460561700, 1460561760, 1460561820, 1460561880, 1460561940,
                                            1460562000, 1460562060, 1460562120, 1460562180, 1460562240, 1460562300, 1460562360,
                                            1460562420, 1460562480, 1460562780, 1460563080, 1460563380, 1460563680, 1460563980,
                                            1460564280, 1460564580, 1460564880, 1460565180, 1460565480, 1460565780, 1460566080,
                                            1460566380, 1460566680, 1460566980, 1460567280, 1460568180, 1460569080, 1460569980,
                                            1460570880, 1460571780, 1460572680, 1460573580, 1460574480, 1460575380, 1460576280,
                                            1460577180,1460578080,1460578980 ] }

    auth_token = get_auth_token(options[:auth_token])
    merchant_id = options[:merchant_id] || "102237"
    order_type = options[:order_type] || "pickup"
    var_return = default_return.merge(options[:return] || {})

    stub_request(:get, "http://#{ auth_token }#{ API.domain }#{ API.base_path }/merchants/#{ merchant_id }/grouporderavailabletimes/#{ order_type }")
        .to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def group_order_delete_stub(options = {})
    auth_token = get_auth_token(options[:auth_token])
    var_return = options[:return] || {}
    group_order_token = options[:group_order_token] || "9109-nyw5d-g8225-irawz"


    stub_request(:delete, "http://#{ auth_token }#{ API.domain }#{ API.base_path }/grouporders/#{ group_order_token }")
        .to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def get_auth_token(auth_token)
    ## Auth_token nil means that the stub will be without authentication_token,
    ## If it is not nil the stub will be a stub with authentication_token
    ## If it is a hash it will return an email and password for authentication
    if auth_token.nil?
      ""
    elsif auth_token.is_a?(Hash)
      "#{ auth_token[:email] }:#{ auth_token[:password] }@"
    else
      "splickit_authentication_token:#{ auth_token }@"
    end
  end

  def merchant_indeliveryarea_stub(options = {})
    delivery_address_id = options[:delivery_address_id] || "202247"
    merchant_id = options[:merchant_id] || "102237"

    default_return = { map_id: "1041",
                       name: nil,
                       price: "1.00",
                       minimum_order_amount: nil,
                       notes: "",
                       is_in_delivery_range: true }
    var_return = default_return.merge(options[:return] || {})
    auth_token = get_auth_token(options[:auth_token] || "72JZAQC5D81A1QDU44K3")

    stub_request(:get, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/merchants/#{ merchant_id }/isindeliveryarea/#{ delivery_address_id }")
        .to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
    if options[:catering]
      stub_request(:get, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/merchants/#{ merchant_id }/isindeliveryarea/#{ delivery_address_id }/catering")
          .to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
    end
  end

  def merchant_where_stub(options = {})
    ## Delete param if it is blank
    options[:params].delete_if { |k, v| v.blank? }

    default_return = { merchants: get_default_merchant_list(options[:params]) }
    auth_token = get_auth_token(options[:auth_token])
    default_params = { limit: 10, minimum_merchant_count: 5, range: 100 }
    params = default_params.merge(options[:params] || {}).to_param
    var_return = default_return.merge(options[:return] || {})

    stub_request(:any, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/merchants?#{ params }")
        .to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def merchant_find_stub(options = {})
    menu = get_default_menu[:menu]
    order_type = "/delivery" if options[:delivery]
    order_type = "/catering" if options[:catering]

    default_return = { merchant_id: "4000",
                       menu_id: "#{ menu[:menu_id] }",
                       menu_key: "1122334455",
                       name: "Wooden Shjips",
                       address1: "1234 Bacon Lane",
                       city: "Deadwood",
                       state: "SD",
                       phone_no: "2224448899",
                       brand: "Acid Western",
                       trans_fee_rate: "5.00",
                       show_tip: "Y",
                       time_zone_offset: "-5",
                       delivery: "N",
                       readable_hours: default_readable_hours,
                       menu: menu }

    auth_token = get_auth_token(options[:auth_token])
    merchant_id = options[:merchant_id] || "4000"
    var_return = default_return.merge(options[:return] || {})

    stub_request(:get, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/merchants/#{ merchant_id }#{ order_type }")
        .to_return(status: 200, body: { data: var_return, message: options[:message] }.to_json)
  end

  def order_submit_stub(options = {})
    cart_ucid = (options[:body] && options[:body][:cart_ucid]) || "9109-nyw5d-g8225-irawz"
    default_body =  { user_id: "1195-vdi97-q2kug-38j07",
                      cart_ucid: cart_ucid,
                      tip: nil,
                      note: "",
                      merchant_payment_type_map_id: nil,
                      requested_time: "1415823383" }

    default_return = valid_orders_response["data"]

    message = options[:message] || "Your order to The Pita Pit will be ready for pickup at 2:46pm"
    auth_token = get_auth_token(options[:auth_token] || "72JZAQC5D81A1QDU44K3")
    body = default_body.merge(options[:body] || {})
    var_return = default_return.merge(options[:return] || {})

    stub_request(:post, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/orders/#{ cart_ucid }")
        .with(body: body).to_return(status: 200, body: { data: var_return, message: message }.to_json)
  end

  def delete_favorite_stub(options = {})
    favorite_id = (options[:favorite_id]) || "270237"
    default_return = { user_message: "Your favorite was successfully deleted" }
    message = options[:message] || "Your favorite was successfully deleted"

    auth_token = get_auth_token(options[:auth_token] || "ASNDKASNDAS")
    var_return = default_return.merge(options[:return] || {})

    stub_request(:delete, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/favorites/#{ favorite_id }")
        .to_return(status: 200, body: { data: var_return, message: message }.to_json)
  end

  def user_loyalty_history_stub(options = {})
    default_return = { headings: { transaction_date: "DATE", activity: "ACTIVITY",
                                   description: "description", amount: "amount" },
                       rows: [{ transaction_date: "20-1005",
                                activity: "2468408",
                                description: "test",
                                amount: "174" }] }
    auth_token = get_auth_token(options[:auth_token] || "ASNDKASNDAS")
    user_id = options[:user_id] || "2"
    var_return = default_return.merge(options[:return] || {})


    stub_request(:get, "#{ API.protocol }://#{ auth_token}#{ API.domain }#{ API.base_path }/users/#{ user_id }/loyalty_history?format=v2").
        to_return(status: 200, body: { data: var_return }.to_json)

  end

  def rules_loyalty_stub(options = {})
    brand = options[:brand] || "order"
    stub_request(:get, "http://com.splickit.products.s3.amazonaws.com/com.splickit.#{ brand }/mobile/webviews/rules/index.html")
        .to_return(status: 200, body: options[:body] || "Test rules")
  end

  def skin_where_stub(options = {})
    default_return = { skin_id: "13",
                       skin_name: "Test",
                       skin_description: "Test",
                       brand_id: "282",
                       mobile_app_type: "B",
                       external_identifier: "com.splickit.test",
                       custom_skin_message: "",
                       welcome_letter_file: nil,
                       in_production: "Y",
                       web_ordering_active: "N",
                       donation_active: "N",
                       donation_organization: "Share Our Strength",
                       facebook_thumbnail_url: "http =>//itunes.apple.com/us/app/pita-pit/id461735388?mt=8",
                       android_marketplace_link: "https://play.google.com/store/apps/details?id=com.splickit.pitapit&hl=en",
                       twitter_handle: "PitaPitUSA",
                       iphone_certificate_file_name: "com.splickit.pitapit.pem",
                       current_iphone_version: "3.0.0",
                       current_android_version: "3.1",
                       facebook_app_id: "",
                       facebook_app_secret: "",
                       rules_info: "<h3>Reward points redemption</h3>\n      <p>See our local redemption schedule below. But beware...your local Pita\n        Pit may offer even more great deals!</p>\n\n      <dl>\n        <dt>Standard Pita / Fork Style</dt>\n        <dd>90 Points</dd>\n        <dt>\"6\" Pita / Kids Pita</dt>\n<dd>70 Points</ dd>\n<dt>32 oz Fountain Drink</dt>\n<dd>30 Points</ dd>\n<dt>Bag of Chips</dt>\n<dd>15 Points</ dd>\n<dt>Fresh Baked Cookie</dt>\n<dd>10 Points</ dd>\n</dl>\n\n<p>Learn more on the Pit Card and <a href=\"https://www.mypitapitcard.com/faq\">FAQ's</a> page.</p>",
                       supports_history: "1",
                       supports_join: "1",
                       supports_link_card: "1",
                       lat: "47.6737",
                       lng: "-116.781",
                       loyalty_features: { supports_history: true,
                                           supports_join: true,
                                           supports_link_card: true,
                                           loyalty_type: "remote" },
                       merchants_with_delivery: true,
                       iphone_app_link: "http://itunes.apple.com/us/app/pita-pit/id461735388?mt=8",
                       http_code: "200",
                       loyalty_tnc_url: "http://www.google.com",
                       event_merchant: "0" }

    var_return = default_return.merge(options[:return] || {})

    stub_url = options[:url] || /.*apiv2\/skins\/com.splickit.[^p]*$/

    stub_request(:any, stub_url)
        .to_return(status: 200, body: { http_code: "200", stamp: "tweb03-i-027c8323-P8X8X57", data: var_return }.to_json)
  end

  def vio_credentials_stubs(options = {})
    vio_credential = options[:vio_credential] || "splikit:vio-token"
    stub_request(:get, /apiv2\/users\/credit_card\/getviowritecredentials/).
        to_return(status: 200, body: { data: { vio_write_credentials: vio_credential }, message: options[:message] }.to_json)
  end

  def sign_in_user
    stub_request(:get, "#{ API.protocol }://bob%40roberts.com:password@#{ API.domain }#{ API.base_path }/usersession?email=bob@roberts.com&password=password").
        to_return(:status => 200,
                  :body => get_authenticated_user_json)

    stub_request(
        :get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2").
        to_return(
            :status => 200,
            :body => get_authenticated_user_json)

    click_link "Sign in"

    expect(page).to have_selector("#sign-in")
    within("#sign-in") do
      fill_in "user_email", with: "bob@roberts.com"
      fill_in "user_password", with: "password"
      click_button "Sign in"
    end
  end

  def sign_in_user_with_business_name
    stub_request(:get, "#{ API.protocol }://bob%40roberts.com:password@#{ API.domain }#{ API.base_path }/usersession?email=bob@roberts.com&password=password").
        to_return(:status => 200,
                  :body => get_authenticated_user_json_business_name)

    stub_request(
        :get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2").
        to_return(
            :status => 200,
            :body => get_authenticated_user_json_business_name)

    click_link 'Sign in'

    expect(page).to have_selector("#sign-in")
    within("#sign-in") do
      fill_in 'user_email', :with => "bob@roberts.com"
      fill_in 'user_password', :with => "password"
      click_button "Sign in"
    end
  end

  def sign_in_user_with_credit
    stub_request(:get, "http://mr%40fat.com:password@test.splickit.com/app2/apiv2/usersession?email=mr@fat.com&password=password").
        to_return(:status => 200,
                  :body => {
                      "http_code"=>200,
                      "stamp"=>"tweb03-i-027c8323-V328IUO",
                      "data"=>{
                          "user_id"=>"7088-yybmg-o52uw-5f23d",
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
                          "brand_loyalty"=>{
                              "map_id"=>"71037",
                              "user_id"=>"1468052",
                              "brand_id"=>"174",
                              "loyalty_number"=>"splick-1U497U7CYZ",
                              "points"=>"10",
                              "loyalty_transactions"=>[],
                              "loyalty_points"=>"10"
                          },
                          "splickit_authentication_token"=>"X538YPT87I6U59GSWYHD",
                          "splickit_authentication_token_expires_at"=>1413619815
                      }, "message"=>nil
                  }.to_json)

    click_link 'Sign in'

    expect(page).to have_selector("#sign-in")
    within("#sign-in") do
      fill_in 'user_email', :with => "mr@fat.com"
      fill_in 'user_password', :with => "password"
      click_button "Sign in"
    end
  end

  def sign_in_user_no_cc
    stub_request(:get, "#{ API.protocol }://bob%40roberts.com:password@#{ API.domain }#{ API.base_path }/usersession?email=bob@roberts.com&password=password").
        to_return(:status => 200,
                  :body => get_authenticated_user_no_cc_json)
    stub_request(
        :get, "#{ API.protocol }://bob%40roberts.com:password@#{ API.domain }#{ API.base_path }/usersession").to_return(
        :status => 200,
        :body => get_authenticated_user_no_cc_json)
    stub_request(
        :get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2").to_return(
        :status => 200,
        :body => {:data => get_user_data.merge("flags" => "000000")}.to_json, :headers => {})

    click_link "Sign in"

    expect(page).to have_selector("#sign-in")
    within("#sign-in") do
      fill_in "user_email", with: "bob@roberts.com"
      fill_in "user_password", with: "password"

      click_button "Sign In"
    end
  end

  def sign_in_loyal_user
    stub_request(
        :get, "#{ API.protocol }://bob%40roberts.com:password@#{ API.domain }#{ API.base_path }/usersession?email=bob@roberts.com&password=password")
        .to_return(status: 200, body: get_loyal_user_data_json)
    stub_request(
        :get, "#{ API.protocol }://bob%40roberts.com:password@#{ API.domain }#{ API.base_path }/usersession")
        .to_return(status: 200, body: get_loyal_user_data_json)
    stub_request(
        :get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2")
        .to_return(status: 200, body: { data: get_loyal_user_data }.to_json)

    click_link "Sign in"

    within("#sign-in") do
      fill_in "user_email", with: "bob@roberts.com"
      fill_in "user_password", with: "password"

      click_button "Sign In"
    end
  end

  def sign_in_loyal_user_no_cash
    stub_request(
        :get, "#{ API.protocol }://bob%40roberts.com:password@#{ API.domain }#{ API.base_path }/usersession?email=bob@roberts.com&password=password").to_return(
        :status => 200,
        :body => get_loyal_user_no_cash_data_json)
    stub_request(
        :get, "#{ API.protocol }://bob%40roberts.com:password@#{ API.domain }#{ API.base_path }/usersession").to_return(
        :status => 200,
        :body => get_loyal_user_no_cash_data_json)

    loyal_user = get_loyal_user_data.merge("brand_loyalty" => {"loyalty_number"=>"140105420000001793", "pin"=>"9189", "points"=>"500"})
    stub_request(
        :get, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2").to_return(
        :status => 200,
        :body => {:data => loyal_user}.to_json, :headers => {})

    click_link 'Sign in'

    within("#sign-in") do
      fill_in 'user_email', :with => "bob@roberts.com"
      fill_in 'user_password', :with => "password"

      click_button "Sign In"
    end
  end

  def stub_merchants_for_zip(zip="80305")
    merchants_json = [
        {
            active: "Y",
            merchant_id: "1106",
            merchant_external_id: "001",
            brand_id: "162",
            lat: "40.007172",
            lng: "-105.275903",
            name: "Illegal Pete's",
            display_name: "The Hill--Boulder",
            address1: "1320 College Ave",
            description: "Fast, Fresh, Healthy",
            city: "Boulder",
            state: "CO",
            zip: "#{zip}",
            phone_no: "3034443055",
            delivery: "N",
            distance: "2.2647914903494777",
            brand: "Illegal Pete's",
            promo_count: "NA",
            group_ordering_on: "1"
        },
        {
            active: "Y",
            merchant_id: "103893",
            merchant_external_id: "bdce5f3e-3a94-11e2-87ed-00163eeae34c",
            brand_id: "340",
            lat: "40.007679",
            lng: "-105.276216",
            name: "Geisty's Dogg House",
            display_name: "Boulder",
            address1: "1116 13th Street",
            description: "N",
            city: "Boulder",
            state: "CO",
            zip: "#{zip}",
            phone_no: "3034025000",
            delivery: "Y",
            distance: "2.303197522850048",
            brand: "MenuSherpa",
            promo_count: "NA",
            group_ordering_on: "0"
        },
        {
            active: "Y",
            merchant_id: "1051",
            merchant_external_id: "",
            brand_id: "100",
            lat: "40.014780",
            lng: "-105.259707",
            name: "Flatiron Coffee",
            display_name: "Boulder",
            address1: "2721 Arapahoe Avenue",
            description: "Great Coffee Shop in Boulder",
            city: "Boulder",
            state: "CO",
            zip: "#{zip}",
            phone_no: "3034494111",
            delivery: "N",
            distance: "2.453691516326954",
            brand: "System Default",
            promo_count: "NA",
            group_ordering_on: "0"
        }
    ]

    stub = stub_request :any, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/merchants?limit=10&minimum_merchant_count=5&range=100&location=#{zip}"
    stub.to_return status: 200, body: {data: {merchants: merchants_json}}.to_json
  end

  def stub_signed_in_merchants_for_zip(zip = "80305", auth_token = "ASNDKASNDAS")
    merchants_json = [
        {
            active: "Y",
            merchant_id: "1106",
            merchant_external_id: "001",
            brand_id: "162",
            lat: "40.007172",
            lng: "-105.275903",
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
            group_ordering_on: "1"
        },
        {
            active: "Y",
            merchant_id: "103893",
            merchant_external_id: "bdce5f3e-3a94-11e2-87ed-00163eeae34c",
            brand_id: "340",
            lat: "40.007679",
            lng: "-105.276216",
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
            group_ordering_on: "0"
        },
        {
            active: "Y",
            merchant_id: "1051",
            merchant_external_id: "",
            brand_id: "100",
            lat: "40.014780",
            lng: "-105.259707",
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
            group_ordering_on: "0"
        }
    ]

    stub_request(:any, "http://splickit_authentication_token:#{ auth_token }@test.splickit.com/app2/apiv2/merchants?limit=10&minimum_merchant_count=5&range=100&location=80305")
        .to_return(status: 200, body: { data: { merchants: merchants_json } }.to_json)
  end

  def stubs_for_order_cart(options = {})
    cart_id = "#{ options[:cart_id] }/" if options[:cart_id].present?
    cart_body = { user_id: "2",
                  merchant_id: "4000",
                  user_addr_id: nil,
                  group_order_token: nil,
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
                            note: "" }],
                  total_points_used: 0 }.merge(options[:cart_body] || {})

    checkout_return = {
        time_zone_string: "America/Los_Angeles",
        time_zone_offset:-8,
        user_message:nil,
        lead_times_array:[
            1415830156,1415830216,1415830276,1415830336,1415830396,1415830456,1415830516,1415830576,1415830636,
            1415830696,1415830756,1415830816,1415830876,1415830936,1415830996,1415831056,1415831356,1415831656,
            1415831956,1415832256,1415832556,1415832856,1415833156,1415833456,1415833756,1415834056,1415834356,
            1415834656,1415834956,1415835256,1415835556,1415835856,1415836756,1415837656,1415838556,1415839456,
            1415840356,1415841256,1415842156,1415843056,1415843956
        ],
        promo_amt:"0.00",
        order_amt:"$6.89",
        tip_array:[{"No Tip" => 0}, {"10%" => "0.69"}, {"15%" => "1.03"}, {"20%" => "1.38"}, {"$1.00" => 1}, {"$2.00" => 2},
                   {"$3.00" => 3}, {"$4.00" => 4}, {"$5.00" => 5}, {"$6.00" => 6}, {"$7.00" => 7}, {"$8.00" => 8},
                   {"$9.00"=>9}, {"$10.00" => 10}, {"$11.00" => 11}, {"$12.00" => 12}, {"$13.00" => 13}, {"$14.00" => 14},
                   {"$15.00" => 15}, {"$16.00" => 16},{"$17.00" => 17}, {"$18.00" => 18}, {"$19.00" => 19}, {"$20.00" => 20},
                   {"$21.00" => 21}, {"$22.00" => 22}, {"$23.00" => 23}, {"$24.00" => 24}, {"$25.00" => 25}],
        total_tax_amt:"0.41",
        convenience_fee:"0.00",
        accepted_payment_types:[{
                                    merchant_payment_type_map_id:"1008",
                                    name:"Cash",
                                    splickit_accepted_payment_type_id:"1000",
                                    billing_entity_id:nil
                                }, {
                                    merchant_payment_type_map_id:"2000",
                                    name:"Credit Card",
                                    splickit_accepted_payment_type_id:"2000",
                                    billing_entity_id:nil
                                }],
        order_summary:{
            cart_items:[{
                            item_name:"Pastrami Salad",
                            item_price:"$6.89",
                            item_quantity:"1",
                            item_description:"Pastrami, salad, pretty much that's it",
                            order_detail_id:"6082053",
                            note:""
                        }],
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
            receipt_items:[{
                               title:"Subtotal",
                               amount:"$6.89"
                           },{
                               title:"Tax",
                               amount:"$0.41"
                           },{
                               title:"Total",
                               amount:"$7.30"
                           }]
        },
        cart_ucid:"5570-01bpq-gb5qf-7609e"
    }.merge(options[:checkout_return] || {})

    auth_token = options[:auth_token] || "ASNDKASNDAS"

    stub_request(:post, "http://splickit_authentication_token:#{ auth_token }@test.splickit.com/app2/apiv2/cart/#{ cart_id }checkout")
        .with(body: cart_body.to_json).to_return(
        :status => 200,
        :body => {
            http_code:200,
            stamp:"tweb03-i-027c8323-OUO74I4",
            data: checkout_return,
            message:nil
        }.to_json
    )
  end

  def get_tip_array(options)
    tip_array = []
    order_amt = options[:order_amt].to_f || 10.0
    no_tip = options[:no_tip] || true
    percentage_array = options[:percentage] || [10, 15, 20, 25]
    int_array = options[:int] || (1..25).to_a

    tip_array << { "No Tip" => 0 } if no_tip
    percentage_array.each do |percentage|
      tip_array << { "#{ percentage }%" => "%.2f" % (order_amt * percentage / 100).to_s }
    end
    int_array.each do |int|
      tip_array << { "$#{ int }.00" => int.to_i }
    end

    tip_array
  end

  def stubs_invalid_order(message)
    body = {
        "user_id"=>"2",
        "cart_ucid" => "9705-j069h-ce8w3-425di",
        "tip" => "1.03",
        "note" => "Something with bacon, please.",
        "merchant_payment_type_map_id" => "2000",
        "requested_time" => "1415830216"
    }

    stub_request(:post, "http://splickit_authentication_token:ASNDKASNDAS@test.splickit.com/app2/apiv2/orders/9705-j069h-ce8w3-425di").
        with(:body => body.to_json ).
        to_return(
            :status => 402,
            :body => invalid_orders_response(message).to_json
        )
  end

  def stubs_delivery_address_for_redirect_to_merchants
    updated_user_address_json = "{\"user_addr_id\":\"202402\" ,\"user_id\":\"2\",\"name\":\"Gesty's Reclamation Plant\",\"business_name\":\"Geisty's Company\",\"address1\":\"1116 13th Street\",\"address2\":\"St\",\"city\":\"Geisty's Dogg House, Boulder\",\"state\":\"CO\",\"zip\":\"80305\",\"lat\":\"39.8149386187446\",\"lng\":\"-104.956209155655\",\"phone_no\":\"1234567890\",\"instructions\":\"Don't mind the sock.\"}"
    user_address_body = {
        "business_name" => "Geisty's Company",
        "address1" => "1116 13th Street",
        "address2" => "St",
        "city" => "Geisty's Dogg House, Boulder",
        "state" => "CO",
        "zip" => "80305",
        "phone_no" => "1234567890",
        "instructions" => "Don't mind the sock."
    }
    stub_request(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }/app2/phone/setuserdelivery").
        with(:body => user_address_body.to_json).
        to_return(:status => 200, :body => "#{ updated_user_address_json }")
  end

  def stubs_delivery_address_success(auth_token, user_id, addr_id)
    stub_request(:delete,
                 "http://splickit_authentication_token:#{ auth_token }@#{ API.domain }#{ API.base_path }/users/#{ user_id }/userdeliverylocation/#{ addr_id }")
        .to_return(
            status: 200,
            body: { data: { "result" => "success" } }.to_json)
  end

  def stubs_delivery_address_failure(auth_token, user_id, addr_id)
    stub_request(:delete,
                 "http://splickit_authentication_token:#{ auth_token }@#{ API.domain }#{ API.base_path }/users/#{ user_id }/userdeliverylocation/#{ addr_id }")
        .to_return(
            status: 200,
            body: "{\"error\": {\"error\": \"could not locate the user delivery record\",\"error_code\": 190 }}")
  end

  def visit_merchant_buy_and_checkout(merchant)
    visit merchant_path(merchant.merchant_id, menu_type: "pickup")
    expect(page).to have_content "PICKUP MENU"
    first('article').click
    first('button.checkout').click
  end

  def go_back_to_menu_and_checkout
    find("a#add").click

    find("a.my-order-link").click

    find("button.checkout").click
  end

  def verify_delete_conf_dialog
    within("#delivery-address") do
      expect(page.find("div[data-dialog-header] h1")).to have_content "Delete delivery address"
      expect(page.find("div[data-dialog-footer]")).to have_selector "button.btn-delete-usr-addr", count: 1
      expect(page.find("div[data-dialog-footer]")).to have_selector "a.btn-delete-usr-addr", count: 1
      expect(page.find("div[data-dialog-content]")).to have_content "Are you sure delete delivery address?"
    end
  end

  def feature_sign_out
    find("a.user").click
    find("a", text: "Sign out").click
  end

  def view_hidden_elements
    Capybara.ignore_hidden_elements = false
    yield
    Capybara.ignore_hidden_elements = true
  end

  def reset_browser_window_size width = 1000, height = 600
    page.driver.browser.manage.window.resize_to width, height
  end

  def reset_browser_cookies
    browser = Capybara.current_session.driver.browser
    if browser.respond_to?(:clear_cookies)
      # Rack::MockSession
      browser.clear_cookies
    elsif browser.respond_to?(:manage) and browser.manage.respond_to?(:delete_all_cookies)
      # Selenium::WebDriver
      browser.manage.delete_all_cookies
    else
      raise "Don't know how to clear cookies. Weird driver?"
    end
  end

  def clear_skin_cache
    Rails.cache.delete_matched("/skins/*")
  end

  def stubs_for_valid_update_payment
    stub_request(:post,
                 "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2").
        with(body: "{\"credit_card_saved_in_vault\":false,\"credit_card_token_single_use\":\"vio-token\"}").
        to_return(status: 200,
                  body: user_payment_response.to_json)
  end

  def delete_credit_card_stub(options = {})
    user_id = (options[:user_id]) || "2"
    default_return = { user_message: "Your credit card has been deleted." }
    message = options[:message] || "Your credit card has been deleted."

    auth_token = get_auth_token(options[:auth_token] || "ASNDKASNDAS")
    var_return = default_return.merge(options[:return] || {})

    stub_request(:delete, "#{ API.protocol }://#{ auth_token }#{ API.domain }#{ API.base_path }/users/#{ user_id }/credit_card")
        .to_return(status: 200, body: { data: var_return, message: message }.to_json)
  end

  def promo_code_stubs(auth_token, cart_id, promo_amt, with_message = true, valid = true)
    if valid
      message = "Congratulations!  You're geting $1.00 off your current order!" if with_message
      stub_request(:get,
                   "http://splickit_authentication_token:#{ auth_token }@test.splickit.com/app2/apiv2/cart/#{ cart_id }/checkout?promo_code=lucky").
          to_return(status: 200,
                    body: { "http_code" => 200,
                            "stamp" => "tweb03-i-027c8323-H7S6EY3",
                            "data" => {
                                "time_zone_string" => "America/Los_Angeles",
                                "time_zone_offset" => -7,
                                "user_message" => message,
                                "lead_times_array" => [1415823383,1415823443,1415823503,1415823563,1415823623,1415823683,1415823743,1415823803,1415823863,1415823923,1415823983,1415824043,1415824103,1415824163,1415824223,1415824283,1415824583,1415824883,1415825183,1415825483,1415825783,1415826083,1415826383,1415826683,1415826983,1415827283,1415827583,1415827883,1415828183,1415828483,1415828783,1415829083,1415829983,1415830883,1415831783,1415832683,1415833583,1415834483,1415835383,1415836283,1415837183],
                                "promo_amt" => promo_amt,
                                "order_amt" => "6.89",
                                "grand_total" => "6.30",
                                "tip_array" => [{ "No Tip" => 0 },
                                                { "10%" => "0.69" },
                                                { "15%" => "1.03" },
                                                { "20%" => "1.38" },
                                                { "$1.00" => 1 },
                                                { "$2.00" => 2 },
                                                { "$3.00" => 3 },
                                                { "$4.00" => 4 },
                                                { "$5.00" => 5 },
                                                { "$6.00" => 6 },
                                                { "$7.00" => 7 },
                                                { "$8.00" => 8 },
                                                { "$9.00" => 9 },
                                                { "$10.00" => 10 },
                                                { "$11.00" => 11 },
                                                { "$12.00" => 12 },
                                                { "$13.00" => 13 },
                                                { "$14.00" => 14 },
                                                { "$15.00" => 15 },
                                                { "$16.00" => 16 },
                                                { "$17.00" => 17 },
                                                { "$18.00" => 18 },
                                                { "$19.00" => 19 },
                                                { "$20.00" => 20 },
                                                { "$21.00" => 21 },
                                                { "$22.00" => 22 },
                                                { "$23.00" => 23 },
                                                { "$24.00" => 24 },
                                                { "$25.00" => 25 }],
                                "total_tax_amt" => "0.41",
                                "convenience_fee" => "0.00",
                                "discount_amt" => "1.00",
                                "order_summary" => {
                                    "cart_items" => [{
                                                         "size_name" => "Regular Pita",
                                                         "item_name" => "Awakin with Bacon",
                                                         "item_price" => "$6.89",
                                                         "item_quantity" => "1",
                                                         "item_description" => "White, Bacon, Eggs, Hashdevins, Onions, Green Peppers, Cheddar",
                                                         "order_detail_id" => "6098633",
                                                         "item_note" => ""
                                                     }],
                                    "receipt_items" => [{ "title" => "Promo Discount",
                                                          "amount" => "$-1.00" },
                                                        { "title" => "Subtotal",
                                                          "amount" => "$6.89" },
                                                        { "title" => "Tax",
                                                          "amount" => "$0.41" },
                                                        { "title" => "Tip",
                                                          "amount" => "$0.00" },
                                                        { "title" => "Total",
                                                          "amount" => "$6.30" }]
                                },
                                "accepted_payment_types" => [
                                    { "merchant_payment_type_map_id" => "1008",
                                      "name" => "Cash",
                                      "splickit_accepted_payment_type_id" => "1000",
                                      "billing_entity_id" => "1006"
                                    },
                                    { "merchant_payment_type_map_id" => "1066",
                                      "name" => "Credit Card",
                                      "splickit_accepted_payment_type_id" => "2000",
                                      "billing_entity_id" => "1000" }
                                ],
                                "cart_ucid" => "3623-6py84-7186j-m0445"
                            },
                            "message" => message
                    }.to_json)
    else
      stub_request(:get,
                   "http://splickit_authentication_token:#{ auth_token }@test.splickit.com/app2/apiv2/cart/#{ cart_id }/checkout?promo_code=invalid").
          to_return(status: 200,
                    body: ({ "http_code" => 422,
                             "error" => { "error_type" => "promo",
                                          "error" => "error_message" } }).to_json
          )
    end
  end

  def apply_promo_code(promo_code)
    find("#discount-text", text: "Add promotional code").click
    fill_in("Enter Promo Code", with: promo_code)
    click_button("Apply")
  end

  def verify_show_group_order_status_link
    within "header nav.primary" do
      expect(page).to have_css("a.group-order-status", count: 1)
    end
    click_link("Group order status")
    expect(URI.parse(current_url).request_uri).to include(group_order_path("9109-nyw5d-g8225-irawz"))

  end

end

RSpec.configure do |config|
  config.include FeatureSpecHelper

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end