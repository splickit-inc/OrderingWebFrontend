require 'support/feature_spec_helper'

describe 'feedback', js: true do

  it 'should show user fields if user is not signed in' do
    stub_merchants_for_zip("80305")

    visit feedback_path

    expect(page).to have_content("NAME")
    expect(page).to have_css("#feedback_name")
    expect(page).to have_content("EMAIL")
    expect(page).to have_css("#feedback_email")
    expect(page).to have_content("SUBJECT")
    expect(page).to have_css("#feedback_topic")
    expect(page).to have_content("MESSAGE")
    expect(page).to have_css("#feedback_body")
  end

  it 'should not show user fields if user is signed in' do
    stub_merchants_for_zip("80305")

    visit root_path

    feature_sign_in

    visit feedback_path

    expect(page).not_to have_content("NAME")
    expect(page).not_to have_css("#feedback_name")
    expect(page).not_to have_content("EMAIL")
    expect(page).not_to have_css("#feedback_email")
    expect(page).to have_content("SUBJECT")
    expect(page).to have_css("#feedback_topic")
    expect(page).to have_content("MESSAGE")
    expect(page).to have_css("#feedback_body")
  end
end
