require "rails_helper"

describe "users/loyalty/manage.html.erb" do
  before(:each) do
    @user = User.initialize({"brand_loyalty" => {"usd" => 333, "points" => 666}})
    @skin = Skin.initialize({"loyalty_card_management_link" => "http://www.mypitapitcard.com", 'loyalty_features' => {'supports_history' => true, 'supports_link_card' => true}})
    render
  end

  subject { rendered }

  it { is_expected.to have_css "h3", text: "Manage your card" }
  it { is_expected.to have_css "a[href='http://www.mypitapitcard.com']", text: "http://www.mypitapitcard.com" }
  it { is_expected.to have_css "a[target='_blank']", text: "www.mypitapitcard.com" }

  it { is_expected.to have_css "a[href='http://www.mypitapitcard.com']", text: "Manage card" }
  it { is_expected.to have_css "a[target='_blank']", text: "Manage card" }
end
