require 'support/feature_spec_helper'

describe 'sign up', js: true do

  it 'should allow a user to sign up with first name, last name, email, phone number, birthday, and password' do
    stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users")
        .with(:body => "{\"first_name\":\"Tony\",\"last_name\":\"Stark\",\"email\":\"tony@starkindustries.com\",\"contact_no\":\"5555555555\",\"birthday\":\"08/25/1985\",\"password\":\"iamironman\"}")
        .to_return(
            :body => get_signup_user_json,
            :status => 200
        )

    stub_request(:get,
                 "#{ API.protocol }://splickit_authentication_token:TONYTONY@#{ API.domain }#{ API.base_path }/users/3")
        .to_return(status: 200, body: get_signup_user_json)

    stub_request(:get, "http://splickit_authentication_token:TONYTONY@test.splickit.com/app2/apiv2/merchants?lat=40.049599&limit=10&lng=-105.276901&minimum_merchant_count=5&range=100").
        to_return(status: 200, body: { http_code: 200,
                                       stamp: "tweb03-i-027c8323-3GWCQII",
                                       data: { merchants: [] } }.to_json)

    visit root_path

    click_link 'Sign up'

    expect(page).to have_selector("#sign-up")

    within("#sign-up") do
      fill_in 'First name', :with => "Tony"
      fill_in 'Last name', :with => "Stark"
      fill_in 'Email', :with => "tony@starkindustries.com"
      fill_in 'Phone number', :with => "5555555555"
      fill_in 'user_birthday_user', :with => "25/08/1985"
      fill_in 'user_password', :with => "iamironman"

      click_button "Sign Up"
    end

    expect(page).to have_content("TONY")
  end

  it 'should allow a user to sign up with first name, last name, email, phone number, and password' do
    stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users")
    .with(:body => "{\"first_name\":\"Tony\",\"last_name\":\"Stark\",\"email\":\"tony@starkindustries.com\",\"contact_no\":\"5555555555\",\"birthday\":\"\",\"password\":\"iamironman\"}")
    .to_return(
      :body => get_signup_user_json,
      :status => 200
    )

    stub_request(:get,
                 "#{ API.protocol }://splickit_authentication_token:TONYTONY@#{ API.domain }#{ API.base_path }/users/3")
      .to_return(status: 200, body: get_signup_user_json)

    stub_request(:get, "http://splickit_authentication_token:TONYTONY@test.splickit.com/app2/apiv2/merchants?lat=40.049599&limit=10&lng=-105.276901&minimum_merchant_count=5&range=100").
      to_return(status: 200, body: { http_code: 200,
                                     stamp: "tweb03-i-027c8323-3GWCQII",
                                     data: { merchants: [] } }.to_json)

    visit root_path

    click_link 'Sign up'

    expect(page).to have_selector("#sign-up")

    within("#sign-up") do
      fill_in 'First name', :with => "Tony"
      fill_in 'Last name', :with => "Stark"
      fill_in 'Email', :with => "tony@starkindustries.com"
      fill_in 'Phone number', :with => "5555555555"
      fill_in 'Password', :with => "iamironman"

      click_button "Sign Up"
    end

    expect(page).to have_content("TONY")
  end

  describe "email marketing" do
    before do
      user_find_stub(auth_token: "TONYTONY", return: get_signup_user)

      merchant_where_stub(auth_token: "TONYTONY", params: { lat: "40.049599", lng: "-105.276901" }, return: { merchants: [] })
    end

    context "moes" do
      before do
        skin_where_stub(return: { skin_name: "Moes",
                                  brand_fields: [{ field_name: "birthday",
                                                   field_type: "date",
                                                   field_label: "BIRTHDAY (REQUIRED)" },
                                                 { field_name: "zipcode",
                                                   field_type: "text",
                                                   field_label: "ZIPCODE (REQUIRED)" },
                                                 { field_name: "marketing_email_opt_in",
                                                   field_type: "boolean",
                                                   field_label: "Enroll in Moe's E-world and get a free gift on your birthday." }] })

        stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users")
          .with(body: "{\"first_name\":\"Tony\",\"last_name\":\"Stark\",\"email\":\"tony@starkindustries.com\",\"contact_no\":\"5555555555\",\"marketing_email_opt_in\":\"1\",\"zipcode\":\"80210\",\"birthday\":\"12/25/1969\",\"password\":\"iamironman\"}")
          .to_return(body: get_signup_user_json, status: 200)

        visit root_path(override_skin: "Moes")

        click_link "Sign up"
      end

      it "shows the correct sign up view when viewing a Moe's merchant" do
        expect(page).to have_selector("#sign-up")

        within("#sign-up") do
          fill_in "First name", with: "Tony"
          fill_in "Last name", with: "Stark"
          fill_in "Email", with: "tony@starkindustries.com"
          fill_in "Phone number", with: "5555555555"
          fill_in "Password", with: "iamironman"

          expect(page).to have_content("Enroll in Moe's E-world and get a free gift on your birthday.")

          find("label.selector-override").click

          fill_in "BIRTHDAY (REQUIRED)", with: "12/25/1969"
          fill_in "ZIPCODE (REQUIRED)", with: "80210"
          click_button "Sign Up"
        end

        expect(page).to have_content("TONY")
      end
    end

    context "goodcents" do
      before do
        skin_where_stub(return: { skin_name: "Goodcents Subs",
                                  brand_fields: [{ field_name: "birthday",
                                                   field_type: "date",
                                                   field_label: "Birthday (we want to surprise you)",
                                                   field_placeholder: "mm/dd/YYYY" },
                                                 { field_name: "marketing_email_opt_in",
                                                   field_type: "boolean",
                                                   field_label: "Yes, send me special offers & news from Goodcents Deli Fresh Subs" }] })

        stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users")
          .with(body: "{\"first_name\":\"Tony\",\"last_name\":\"Stark\",\"email\":\"tony@starkindustries.com\",\"contact_no\":\"5555555555\",\"marketing_email_opt_in\":\"1\",\"birthday\":\"12/25/1969\",\"password\":\"iamironman\"}")
          .to_return(body: get_signup_user_json, status: 200)

        visit root_path(override_skin: "goodcentssubs")

        click_link "Sign up"
      end

      it "shows the correct sign up view when viewing a Goodcent's merchant" do
        expect(page).to have_selector("#sign-up")

        within("#sign-up") do
          expect(page).to have_content("Yes, send me special offers & news from Goodcents Deli Fresh Subs")

          fill_in "First name", with: "Tony"
          fill_in "Last name", with: "Stark"
          fill_in "Email", with: "tony@starkindustries.com"
          fill_in "Phone number", with: "5555555555"
          fill_in "Password", with: "iamironman"

          find("label.selector-override").click

          fill_in "Birthday (we want to surprise you)", with: "12/25/1969"

          click_button "Sign Up"
        end

        expect(page).to have_content("TONY")
      end

      context "API error" do
        before do
          stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users")
            .with(body: "{\"first_name\":\"Tony\",\"last_name\":\"Stark\",\"email\":\"tony@starkindustries.com\",\"contact_no\":\"5555555555\",\"marketing_email_opt_in\":\"1\",\"birthday\":\"12/25/1969\",\"password\":\"iamironman\"}")
            .to_return(body: { error: { error: "Could not create user" } }.to_json, status: 500)

          within("#sign-up") do
            fill_in "First name", with: "Tony"
            fill_in "Last name", with: "Stark"
            fill_in "Email", with: "tony@starkindustries.com"
            fill_in "Phone number", with: "5555555555"
            fill_in "Password", with: "iamironman"

            find("label.selector-override").click

            fill_in "Birthday (we want to surprise you)", with: "12/25/1969"

            click_button "Sign Up"
          end
        end

        it "should show sign up elements after error" do
          expect(page).to have_content("JOIN NOW")

          within("div.sign-up") do
            expect(find("input[type=checkbox]", visible: false)["checked"]).to be_truthy
            expect(page).to have_css("input[name='user[birthday]']")

            find("label.selector-override").click

            expect(find("input[type=checkbox]", visible: false)["checked"]).to be_falsey
            expect(page).to have_css("input[name='user[birthday]']", visible: false)
          end
        end
      end
    end
  end

  it 'should take the user to the stand alone signup page if there is an error' do
    stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users")
      .with(body: "{\"first_name\":\"Tony\",\"last_name\":\"Stark\",\"email\":\"tony@starkindustries.com\",\"contact_no\":\"5555555555\",\"birthday\":\"\",\"password\":\"iamironman\"}")
      .to_return(body: "{\"error\": {\"error\":\"Could not create user\"}}", status: 500)

    visit root_path

    click_link 'Sign up'

    expect(page).to have_selector("#sign-up")
    expect(page).to have_css "a[href='https://d38o1hjtj2mzwt.cloudfront.net/Policies/Order140_TermsAndConditions.html']", text: "our terms"

    within("#sign-up") do
      fill_in 'First name', :with => "Tony"
      fill_in 'Last name', :with => "Stark"
      fill_in 'Email', :with => "tony@starkindustries.com"
      fill_in 'Phone number', :with => "5555555555"
      fill_in 'Password', :with => "iamironman"

      click_button "Sign Up"
    end

    expect(page).to have_content ("JOIN NOW")

    within(".errors") do
      expect(page).to have_content "Could not create user"
    end
  end

  it 'should show error with invalid date in birthday' do
    stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users")
        .with(body: "{\"first_name\":\"Tony\",\"last_name\":\"Stark\",\"email\":\"tony@starkindustries.com\",\"contact_no\":\"5555555555\",\"birthday\":\"invalid_date\",\"password\":\"iamironman\"}")
        .to_return(body: "{\"error\": {\"error\":\"Could not create user\"}}", status: 500)

    visit root_path

    click_link 'Sign up'

    expect(page).to have_selector("#sign-up")
    expect(page).to have_css "a[href='https://d38o1hjtj2mzwt.cloudfront.net/Policies/Order140_TermsAndConditions.html']", text: "our terms"

    within("#sign-up") do
      fill_in 'First name', :with => "Tony"
      fill_in 'Last name', :with => "Stark"
      fill_in 'Email', :with => "tony@starkindustries.com"
      fill_in 'Phone number', :with => "5555555555"
      fill_in 'user_birthday_user', :with => "invalid_date"
      fill_in 'user_password', :with => "iamironman"

      click_button "Sign Up"
    end

    expect(page).to have_content ("JOIN NOW")

    within(".errors") do
      expect(page).to have_content "Please enter a valid birthday format as MM/DD/YYYY."
    end
  end

  it 'should show error with invalid age' do
    stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users")
        .with(body: "{\"first_name\":\"Tony\",\"last_name\":\"Stark\",\"email\":\"tony@starkindustries.com\",\"contact_no\":\"5555555555\",\"birthday\":\"12/21/2010\",\"password\":\"iamironman\"}")
        .to_return(body: "{\"error\": {\"error\":\"Could not create user\"}}", status: 500)

    visit root_path

    click_link 'Sign up'

    expect(page).to have_selector("#sign-up")
    expect(page).to have_css "a[href='https://d38o1hjtj2mzwt.cloudfront.net/Policies/Order140_TermsAndConditions.html']", text: "our terms"

    within("#sign-up") do
      fill_in 'First name', :with => "Tony"
      fill_in 'Last name', :with => "Stark"
      fill_in 'Email', :with => "tony@starkindustries.com"
      fill_in 'Phone number', :with => "5555555555"
      fill_in 'user_birthday_user', :with => "12/21/2010"
      fill_in 'user_password', :with => "iamironman"

      click_button "Sign Up"
    end

    expect(page).to have_content ("JOIN NOW")

    within(".errors") do
      expect(page).to have_content "Sorry, you must be at least 13 years old to use this site."
    end
  end

  it 'should continue the user back to where they started from' do
    stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users")
    .with(body: "{\"first_name\":\"Tony\",\"last_name\":\"Stark\",\"email\":\"tony@starkindustries.com\",\"contact_no\":\"5555555555\",\"birthday\":\"\",\"password\":\"iamironman\"}")
    .to_return(body: get_signup_user_json, status: 200)

    stub_merchants_for_zip("80305")

    @merchant = create_merchant("merchant_id" => "1106", "name" => "Illegal Pete's",
                                "readable_hours" => default_readable_hours)

    merchant_find_stub(merchant_id: "1106", return: @merchant.as_json(false))

    visit root_path

    stub_request(:get,
                 "#{ API.protocol }://splickit_authentication_token:TONYTONY@#{ API.domain }#{ API.base_path }/users/3")
      .to_return(status: 200, body: get_signup_user_json)

    fill_in 'location', with: "80305"
    click_button "Search"

    page.first('.pickup.button').click

    expect(URI.parse(current_url).request_uri).to eq(merchant_path(@merchant.merchant_id, order_type: "pickup"))

    click_link "Sign up"

    stub_signed_in_merchants_for_zip("80305", "TONYTONY")

    within("#sign-up") do
      fill_in 'First name', :with => "Tony"
      fill_in 'Last name', :with => "Stark"
      fill_in 'Email', :with => "tony@starkindustries.com"
      fill_in 'Phone number', :with => "5555555555"
      fill_in 'Password', :with => "iamironman"

      click_button "Sign Up"
    end

    expect(URI.parse(current_url).request_uri).to eq(merchant_path(@merchant.merchant_id, order_type: "pickup"))
  end
end
