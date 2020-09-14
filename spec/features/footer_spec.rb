require 'support/feature_spec_helper'

describe "Footer" do

  it "displays a link to the terms and conditions" do
    visit root_path
    within 'footer' do
      link = find_link "Terms and conditions"
      expect(link['href']).to eq "https://d38o1hjtj2mzwt.cloudfront.net/Policies/Order140_TermsAndConditions.html"
    end
  end

  it "displays a link to the privacy policy" do
    visit root_path
    within 'footer' do
      link = find_link "Privacy policy"
      expect(link['href']).to eq "https://d38o1hjtj2mzwt.cloudfront.net/Policies/Order140_ PrivacyPolicy.htm"
    end
  end

  it "displays patent numbers" do
    visit root_path
    within 'footer' do
      expect(page).to have_content "6,384,850"
      expect(page).to have_content "6,871,325"
      expect(page).to have_content "6,982,733"
      expect(page).to have_content "8,146,077"
    end
  end

end
