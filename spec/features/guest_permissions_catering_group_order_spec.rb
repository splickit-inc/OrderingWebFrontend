require "support/feature_spec_helper"


def make_path_for(button_name = "Sign In", order_type = "Delivery",message_content = "", catering = false, toggle_sign_in = false)

  if catering
    first("a.catering.button").click
  else
    find(:xpath, "//input[@class='checkbox-group-order'][@value='105061']/..").click
  end

  click_link(order_type)
  page.should have_content("Do you have an account?")

  #page.should have_content(message_content)

  encoded_url_continue = ""
  if button_name == "Sign In"
    encoded_url_continue = page.find('button#sign-in-button.sign-in.button')['data-continuelink']
  end

  if button_name == "Join Now"
    encoded_url_continue = page.find('button#sign-up-button.sign-up.button')['data-continuelink']
  end

  decoded_url_continue = URI.unescape(encoded_url_continue)

  click_button(button_name)

  if button_name == "Sign In"
    visit root_path(with_login: true, continue_url: decoded_url_continue)
    page.should have_css('div#sign-in')
    page.should have_current_path("/?continue_url="+encoded_url_continue+"&with_login=true")
    if toggle_sign_in
      click_link("JOIN NOW")
      click_link("SIGN IN")

      encoded_sign_in_button = page.find(:xpath, "//*[@id='sign-in']/div[2]/form")['action']
      u = URI.parse(encoded_sign_in_button)
      p = CGI.parse(u.query)
      expect(!!p['with_login']).to be true
      URI.unescape(p['continue'][0]).should == decoded_url_continue
    end
  end

  if button_name == "Join Now"
    visit root_path(with_signup: true, continue_url: decoded_url_continue)
    page.should have_button('Sign Up')
    page.should have_current_path("/?continue_url="+encoded_url_continue+"&with_signup=true")
    if toggle_sign_in
      click_link("SIGN IN")
      click_link("JOIN NOW")

      encoded_sign_up_button = page.find(:xpath, "//*[@id='sign-up']/div[2]/form")['action']
      u = URI.parse(encoded_sign_up_button)
      p = CGI.parse(u.query)
      expect(!!p['with_signup']).to be true
      URI.unescape(p['continue'][0]).should == decoded_url_continue
    end
  end

  visit root_path
  decoded_url_continue
end


describe "guest permissions", js: true do
  let!(:user_data) {get_user_data}

  let(:menu_data) {get_default_menu}
  let(:menu) {menu_data[:menu]}
  let(:modifier_item_1) {menu_data[:modifier_item_1]}

  let(:merchant){{
      "merchants": [
          {
              "merchant_id": "105061",
              "merchant_external_id": "US-195",
              "brand_id": "282",
              "lat": "26.120149",
              "lng": "-80.144280",
              "name": "Pita Pit",
              "display_name": "Fort Lauderdale",
              "active": "Y",
              "address1": "200 SW First Avenue Suite 106",
              "description": "Y",
              "city": "Fort Lauderdale",
              "state": "FL",
              "zip": "33301",
              "phone_no": "9546177482",
              "delivery": "Y",
              "group_ordering_on": "1",
              "has_catering": "1",
              "brand": "Pita Pit",
              "brand_name": "Pita Pit",
              "promo_count": "NA"
          }
      ],
      "promos": [

      ]
  }}
  let(:merchantLogin) do
    merchant = Merchant.new
    merchant.merchant_id = "105061"
    merchant.name = "Pita Pit"
    merchant.display_name = "Fort Lauderdale"
    merchant.address1 = "200 SW First Avenue Suite 106"
    merchant.city = "Fort Lauderdale"
    merchant.state = "FL"
    merchant.delivery = "Y"
    merchant.has_catering = "1"
    merchant.show_tip = true
    merchant.menu = menu

    merchant
  end

  let(:checkout_group_order_items_body) {
    { group_order_token: "9109-nyw5d-g8225-irawz",
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
  }

  before do
    visit merchants_path
    click_link("Sign in")
    click_link("Continue as Guest")
    # should render all Guest sign up page
    within "div.sign-up" do
      fill_in "First name", with: "Tony"
      fill_in "Email", with: "tony@starkindustries.com"
      fill_in "Phone number", with: "5555555555"

      page.should have_css("input[type='submit']")
      expect(find("input[type='submit']").value).to eq("Continue as Guest")
    end

    user_create_stub(body: { first_name: "Tony",
                             email: "tony@starkindustries.com",
                             contact_no: "5555555555",
                             is_guest: "true" },
                     return: get_user_data.merge("flags" => "1C21000021"))

    user_find_stub(auth_token: "ASNDKASNDAS", return: get_user_data.merge("flags" => "1C21000021"))

    click_button "Continue as Guest"
  end

=begin
  it "should continue guest flow" do
    page.should have_css("a.home.guest")
  end
=end

  context "Delivery" do
    before do
      page.should have_css("a.home.guest")
      stub_request(:get, "http://test.splickit.com/app2/apiv2/merchants?limit=10&location=3301&minimum_merchant_count=5&range=100")
          .to_return(status: 200, body: { data: merchant, message: "" }.to_json)
      stub_request(:get,"http://splickit_authentication_token:ASNDKASNDAS@test.splickit.com/app2/apiv2/merchants?limit=10&location=3301&minimum_merchant_count=5&range=100")
          .to_return(status: 200, body: { data: merchant, message: "" }.to_json)
      visit merchants_path
      fill_in "location", with: "3301"
      click_button("Search")

      merchants = get_default_merchant_list
      merchants.first.merge!(has_catering: "1", delivery: "Y")
      merchants[1].merge!(has_catering: "1", group_ordering_on: "1", force_catering: "1")

      merchant_where_stub(params: {location: "83814"},
                          auth_token: user_data["splickit_authentication_token"],
                          return: {merchants: [merchantLogin.as_json(root: false)].concat(merchants),
                                   promos: []})

      merchant_find_stub(merchant_id: merchantLogin.merchant_id,
                         catering: true,
                         auth_token: user_data["splickit_authentication_token"],
                         return: merchantLogin.as_json(root: false))

      merchant_find_stub(merchant_id: merchantLogin.merchant_id,
                         auth_token: user_data["splickit_authentication_token"],
                         return: merchantLogin.as_json(root: false))
    end

    it "should have the same path when the user change the last login modal between sign in to join now many times" do
      make_path_for("Sign In","Delivery","Sorry, you must be logged in to place a group order.",false,true)
    end

    it "should have the same path when the user change the last login modal between join now to login many times" do
      make_path_for("Join Now","Delivery","Sorry, you must be logged in to place a group order.",false,true)
    end

    it "login with group order is selected" do

      decoded_url_continue = make_path_for("Sign In","Delivery","Sorry, you must be logged in to place a group order.")

      feature_sign_in(email: "mr@bean.com", password: "password", user_return: user_data)
      visit new_group_orders_path(merchant_id:"105061",order_type:"delivery")
      page.should have_current_path(decoded_url_continue)
    end

    it "join now with group order is selected" do
      decoded_url_continue = make_path_for("Join Now","Delivery","Sorry, you must be logged in to place a group order.")

      stub_request(:post, "http://admin:welcome@test.splickit.com/app2/apiv2/users")
          .to_return(status: 200, body:{data:user_data,message:""}.to_json)
      user_authenticate_stub(auth_token: { email: "mr@bean.com", password: "password" },
                             return: user_data)
      user_find_stub(auth_token: "ASNDKASNDAS", return: user_data)

      click_link "Sign up"
      within("#sign-up") do
        fill_in 'First name', :with => "Tony"
        fill_in 'Last name', :with => "Stark"
        fill_in 'Email', :with => "mr@bean.com"
        fill_in 'Phone number', :with => "5555555555"
        fill_in 'Password', :with => "iamironman"

        click_button "Sign Up"
      end

      visit new_group_orders_path(merchant_id:"105061",order_type:"delivery")
      page.should have_current_path(decoded_url_continue)
    end
  end

  context "pickup" do
    before do
      page.should have_css("a.home.guest")
      stub_request(:get, "http://test.splickit.com/app2/apiv2/merchants?limit=10&location=3301&minimum_merchant_count=5&range=100")
          .to_return(status: 200, body: { data: merchant, message: "" }.to_json)
      stub_request(:get,"http://splickit_authentication_token:ASNDKASNDAS@test.splickit.com/app2/apiv2/merchants?limit=10&location=3301&minimum_merchant_count=5&range=100")
          .to_return(status: 200, body: { data: merchant, message: "" }.to_json)
      visit merchants_path
      fill_in "location", with: "3301"
      click_button("Search")

      merchants = get_default_merchant_list
      merchants.first.merge!(has_catering: "1", delivery: "Y")
      merchants[1].merge!(has_catering: "1", group_ordering_on: "1", force_catering: "1")

      merchant_where_stub(params: {location: "83814"},
                          auth_token: user_data["splickit_authentication_token"],
                          return: {merchants: [merchantLogin.as_json(root: false)].concat(merchants),
                                   promos: []})

      merchant_find_stub(merchant_id: merchantLogin.merchant_id,
                         catering: true,
                         auth_token: user_data["splickit_authentication_token"],
                         return: merchantLogin.as_json(root: false))

      merchant_find_stub(merchant_id: merchantLogin.merchant_id,
                         auth_token: user_data["splickit_authentication_token"],
                         return: merchantLogin.as_json(root: false))
    end

    it "should have the same path when the user change the last login modal between sign in to join now many times" do
      make_path_for("Sign In","Pickup","Sorry, you must be logged in to place a group order.",false,true)
    end

    it "should have the same path when the user change the last login modal between join now to login many times" do
      make_path_for("Join Now","Pickup","Sorry, you must be logged in to place a group order.",false,true)
    end

    it "join now with group order is selected" do
      decoded_url_continue = make_path_for("Join Now","Pickup","Sorry, you must be logged in to place a group order.")

      stub_request(:post, "http://admin:welcome@test.splickit.com/app2/apiv2/users")
          .to_return(status: 200, body:{data:user_data,message:""}.to_json)
      user_authenticate_stub(auth_token: { email: "mr@bean.com", password: "password" },
                             return: user_data)
      user_find_stub(auth_token: "ASNDKASNDAS", return: user_data)

      click_link "Sign up"
      within("#sign-up") do
        fill_in 'First name', :with => "Tony"
        fill_in 'Last name', :with => "Stark"
        fill_in 'Email', :with => "mr@bean.com"
        fill_in 'Phone number', :with => "5555555555"
        fill_in 'Password', :with => "iamironman"

        click_button "Sign Up"
      end

      visit new_group_orders_path(merchant_id:"105061",order_type:"pickup")

      page.should have_content("START YOUR GROUP ORDER")
      page.should have_current_path(decoded_url_continue)
    end


    it "login with group order is selected" do

      decoded_url_continue = make_path_for("Sign In","Pickup","Sorry, you must be logged in to place a group order.")

      feature_sign_in(email: "mr@bean.com", password: "password", user_return: user_data)
      visit new_group_orders_path(merchant_id:"105061",order_type:"pickup")

      page.should have_content("START YOUR GROUP ORDER")
      page.should have_current_path(decoded_url_continue)
    end
  end
end