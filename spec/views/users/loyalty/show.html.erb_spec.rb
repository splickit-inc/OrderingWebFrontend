require "rails_helper"

describe "users/loyalty/_navigation.html.erb" do
  context "history" do
    before(:each) do
      assign(:skin, Skin.initialize({'loyalty_features' => {'supports_history' => true, 'supports_link_card' => true}}))
      allow(view).to receive(:route) { 'loyalties/history' }
      render
    end

    it { expect(rendered).to have_css "nav.secondary .current", text: "History" }
    it { expect(rendered).not_to have_css "nav.secondary .current", text: "Rules" }
    it { expect(rendered).not_to have_css "nav.secondary .current", text: "My Card" }

    it { expect(rendered).to have_css("a[href='/user/loyalty/history']", text: "History") }
  end

  context "rules" do
    before(:each) do
      assign(:skin, Skin.initialize({'loyalty_features' => {'supports_history' => true, 'supports_link_card' => true}}))
      allow(view).to receive(:route) { 'loyalties/rules' }
      render
    end

    it { expect(rendered).to_not have_css "nav.secondary .current", text: "History" }
    it { expect(rendered).to have_css "nav.secondary .current", text: "Rules" }
    it { expect(rendered).to_not have_css "nav.secondary .current", text: "My Card" }

    it { expect(rendered).to have_css("a[href='/user/loyalty/rules']", text: "Rules") }
  end

  context "manage" do
    before(:each) do
      assign(:skin, Skin.initialize({'loyalty_features' => {'supports_history' => true, 'supports_link_card' => true}}))
      allow(view).to receive(:route) { 'loyalties/manage' }
      render
    end

    it { expect(rendered).to_not have_css "nav.secondary .current", text: "History" }
    it { expect(rendered).to_not have_css "nav.secondary .current", text: "Rules" }
    it { expect(rendered).to have_css "nav.secondary .current", text: "My Card" }

    it { expect(rendered).to have_css("a[href='/user/loyalty/manage']", text: "My Card") }
  end

  context "not showing history or manage tabs" do
    before(:each) do
      assign(:skin, Skin.initialize({'loyalty_features' => {'supports_history' => false, 'supports_link_card' => false}}))
      allow(view).to receive(:route) { 'loyalties/rules' }
      render
    end

    it { expect(rendered).to_not have_css "nav.secondary", text: "History" }
    it { expect(rendered).to have_css "nav.secondary .current", text: "Rules" }
    it { expect(rendered).to_not have_css "nav.secondary", text: "My Card" }

    it { expect(rendered).to have_css("a[href='/user/loyalty/rules']", text: "Rules") }
  end
end
