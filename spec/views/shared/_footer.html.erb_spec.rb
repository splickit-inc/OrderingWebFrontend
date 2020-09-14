require "rails_helper"

describe "shared/_footer.html.erb" do
  before(:each) do
    @skin = Skin.initialize
    render
  end

  subject { rendered }

  it { is_expected.to have_css "span.logo.logo-app" }
  # it { is_expected.to have_css "p", text: "Order from your mobile device." }
  # it { is_expected.to have_css "p", text: "Download the app!" }
  it { is_expected.to have_css "a[href='mailto:support@order140.com']", text: "Support" }
  it { is_expected.to have_css "a[href='https://d38o1hjtj2mzwt.cloudfront.net/Policies/Order140_TermsAndConditions.html']", text: "Terms and conditions" }
  it { is_expected.to have_css "a[target='_blank']", text: "Terms and conditions" }
  it { is_expected.to have_css "a[href='https://d38o1hjtj2mzwt.cloudfront.net/Policies/Order140_ PrivacyPolicy.htm']", text: "Privacy policy" }
  it { is_expected.to have_css "a[target='_blank']", text: "Privacy policy" }

  context "w/ iPhone URL" do
    before(:each) do
      @skin = {"iphone_url" => "http://www.iphone.com"}
      render
    end

    subject { rendered }

    skip "this API endpoint needs to be updated #87564216"

    xit { is_expected.to have_css "a[href='http://www.iphone.com']", text: "iTunes App Store" }
    xit { is_expected.not_to have_css "a[href='http://www.android.com']", text: "Google Play Store" }
    xit { is_expected.to have_content "Visit the iTunes App Store." }
  end

  context "w/ Android URL" do
    before(:each) do
      @skin = {"android_url" => "http://www.android.com"}
      render
    end

    subject { rendered }

    skip "this API endpoint needs to be updated #87564216"

    xit { is_expected.to have_css "a[href='http://www.android.com']", text: "Google Play Store" }
    xit { is_expected.not_to have_css "a[href='http://www.iphone.com']", text: "iTunes App Store" }
    xit { is_expected.to have_content "Visit the Google Play Store." }
  end

  context "w/ iPhone and Android URL" do
    before(:each) do
      @skin = {"iphone_url" => "http://www.iphone.com", "android_url" => "http://www.android.com"}
      render
    end

    skip "this API endpoint needs to be updated #87564216"

    subject { rendered }

    xit { is_expected.to have_css "a[href='http://www.android.com']", text: "Google Play Store" }
    xit { is_expected.to have_css "a[href='http://www.iphone.com']", text: "iTunes App Store" }
    xit { is_expected.to have_content "Visit the iTunes App Store or Google Play Store." }
  end
end
