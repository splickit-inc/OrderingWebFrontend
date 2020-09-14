require 'support/feature_spec_helper'

describe 'sign in', js: true do
  before :each do
    # hard coding server for facebook login
    Capybara.app_host = 'http://lvh.me:22932'
    Capybara.server_port = '22932'
  end

  it 'should allow a user to sign in with Facebook Login' do
    visit root_path
    click_link("Sign in")
    expect(page).to have_content("Sign in with Facebook")

    find('a.facebook-btn').click
    expect(page.driver.browser.window_handles.size).to eq(2)
    expect(page.driver.find_window("https://www.facebook.com/login.php")).not_to be_nil

    page.windows.last.close
  end

  it 'should allow a user to sign in with correct credentials' do
    visit root_path
    expect(page).not_to have_content("BOB")
    expect(page).to have_content("SIGN UP")
    expect(page).to have_content("SIGN IN")

    feature_sign_in

    expect(page).to have_content "BOB"
    expect(page).not_to have_content "SIGN UP"
    expect(page).not_to have_content "SIGN IN"
  end

  it "should sign in a long password" do
    visit root_path

    feature_sign_in(email: "bob.bob.bob.bob.bob@splickit.com",
                    password: "1234567rewqerw")

    expect(page).to have_content "BOB"
    expect(page).not_to have_content "SIGN UP"
    expect(page).not_to have_content "SIGN IN"
  end

  it 'should continue back to page user started at' do

    stub_merchants_for_zip("80305")

    merchant = create_merchant("merchant_id" => "1106", "name" => "Illegal Pete's")
    stub_request(:get, "#{ API.protocol }://#{ API.domain }#{ API.base_path }/merchants/1106").
      to_return(
      :status => 200,
      :body => "{\"data\": #{merchant.to_json}}",
      :headers => {}
    )

    visit root_path

    fill_in 'location', with: "80305"
    click_button "Search"

    page.first('.pickup.button').click

    expect(URI.parse(current_url).request_uri).to eq(merchant_path(merchant.merchant_id, order_type: "pickup"))

    feature_sign_in

    expect(URI.parse(current_url).request_uri).to eq(merchant_path(merchant.merchant_id, order_type: "pickup"))
  end

  it "should not allow a user to sign in with incorrect credentials" do
    user_authenticate_stub(error: { error: "Could not authenticate user" })

    visit root_path
    expect(page).to have_content 'Find a nearby location'
    expect(page).to have_content 'SIGN UP'
    expect(page).to have_content 'SIGN IN'
    expect(page).to have_selector 'a.logo[href="/"]'
    expect(page).to have_no_selector("#sign-in")
    expect(page).to have_no_selector("#sign-up")

    # sign in
    click_link "Sign in"

    expect(page).to have_selector("#sign-in")
    within("#sign-in") do
      fill_in 'user_email', :with => "bob@roberts.com"
      fill_in 'user_password', :with => "password"
      click_button "Sign In"
    end

    expect(page).to have_selector 'a.logo[href="/"]'
    expect(page).to have_content "SIGN UP"
    expect(page).to have_content "SIGN IN"
    expect(page).to have_content "Could not authenticate user"

  end

  it 'should allow a user to request an email if they forgot their password' do
    stub_request(:get, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users/forgotpassword?email=tyrion@lannist.er").
      to_return(:status => 200, :body => {:http_code => 200, :stamp => "tweb03-i-027c8323-41B72KC", :data => "{\"user_message\":\"We have processed your request. Please check your email for reset instructions.\"}, \"token\":\"3012-0g6e2-76y9d-nw4c4-w3l83-riow0-qn2r3\"}", :message => "We have processed your request. Please check your email for reset instructions."}.to_json, :headers => {})

    visit root_path

    click_link "Sign in"

    within('#sign-in') do
      expect(page).to have_link("Forgot your password?", :href => request_email_path)
      click_link 'Forgot your password?'
    end

    expect(URI.parse(current_url).request_uri).to eq(request_email_path)
    expect(page).to have_selector "input[type='submit']"
    expect(page).to have_selector 'input#email'

    fill_in 'email', :with => "tyrion@lannist.er"
    click_button 'Send Instructions'

    expect(URI.parse(current_url).path).to eq(request_token_path)
    expect(page).to have_content("Password reset instructions have been sent to tyrion@lannist.er")
  end

  it 'should allow a user to sign in with remember_me option' do
    visit root_path
    expect(page).not_to have_content("BOB")
    expect(page).to have_content("SIGN UP")
    expect(page).to have_content("SIGN IN")

    feature_sign_in(remember_me: true)

    expect(page).to have_content "BOB"

    page.windows.last.close
  end

  context "punchh token" do
    before do
      user_authenticate_stub(punch_header: "test_token",
                             return: { email: "test_email@mail.com" })
      visit(merchants_path(security_token: "test_token"))
    end

    it "should sign in when punch token is present and the user is not logged in" do
      expect(page).to have_content "BOB"
      expect(page).not_to have_content "SIGN UP"
      expect(page).not_to have_content "SIGN IN"
      expect(WebMock).to have_requested(:get, "http://test.splickit.com/app2/apiv2/usersession")
                           .with("headers" => { "Punch-Authentication-Token" => "test_token" })
    end

    it "should not sign in when punch token is present and the user is logged in" do
      # 2nd visit with punch token
      visit(merchants_path(security_token: "test_token"))
      expect(a_request(:get, "http://test.splickit.com/app2/apiv2/usersession")
               .with("headers" => { "Punch-Authentication-Token" => "test_token" })).to have_been_made.times(1)
    end
  end
end
