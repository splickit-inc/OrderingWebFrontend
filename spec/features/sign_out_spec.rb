require 'support/feature_spec_helper'

describe 'sign out', :js=>true do

  it 'sign out flow' do
    stub_signed_in_merchants_for_zip("80305")

    visit root_path

    feature_sign_in

    expect(page).not_to have_content 'SIGN UP'
    expect(page).not_to have_content 'SIGN IN'

    # get data to test redirect
    fill_in 'location', with: "80305"
    click_button "Search"

    expect(page).to have_content "Illegal Pete's, The Hill--Boulder"

    page.find('a', text: "BOB").click
    page.find('a', text: "Sign out").click

    expect(page).not_to have_content "BOB ROBERTS"
    expect(page).to have_content 'SIGN UP'
    expect(page).to have_content 'SIGN IN'

    expect(page).not_to have_content "Illegal Pete's, The Hill--Boulder"
  end
end
