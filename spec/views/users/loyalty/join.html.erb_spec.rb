require "rails_helper"

describe "users/loyalty/join.html.erb" do
  context "supports pin and email" do
    before(:each) do
      @skin = Skin.initialize({
        "loyalty_tnc_url" => "https://www.mypitapitcard.com/terms",
        "loyalty_features" => {}
      })

      render
    end

    subject { rendered }

    it { is_expected.to have_css ".loyalty-item h3", text: "Link your existing loyalty account" }
    it { is_expected.to have_css "#loyalty-card h3", text: "Join Our Rewards Program" }
    it { is_expected.to have_css "p", text: "Enter your loyalty number below." }

    it { is_expected.to have_css "input#brand_loyalty_loyalty_number[type='text']" }
    it { is_expected.to have_css "input#brand_loyalty_loyalty_number[placeholder='Loyalty number']" }
    it { is_expected.to have_css "input#brand_loyalty_pin[type='text']" }
    it { is_expected.to have_css "input#brand_loyalty_pin[placeholder='PIN']" }
    it { is_expected.to have_css "input[value='Go']" }

    it { is_expected.to have_css ".join h3", text: "Join Our Rewards Program" }
    it { is_expected.not_to have_css "input#brand_phone_number[type='text']" }
    it { is_expected.not_to have_css "input#brand_phone_number[placeholder='Phone number']" }
    it { is_expected.to have_css "a[href='https://www.mypitapitcard.com/terms']", text: "terms and conditions" }

    # is expected syntax fails looking hidden fields
    it "should render hidden fields" do
      expect(have_css("input#brand_loyalty_create_loyalty_account[value='true']"))
    end

    it { is_expected.to have_css "input[value='Create loyalty account']" }
  end

  context "doesn't support pin" do
    before(:each) do
      @skin = Skin.initialize({
        "loyalty_tnc_url" => "https://www.mypitapitcard.com/terms",
        "loyalty_features" => {
          "supports_pin" => false
        }
      })
      render
    end

    subject { rendered }

    it { is_expected.not_to have_css "input#brand_loyalty_pin[type='text']" }
    it { is_expected.not_to have_css "input#brand_loyalty_pin[placeholder='4 digit PIN']" }
  end

  context "supports phone number" do
    before(:each) do
      @skin = Skin.initialize({
        "loyalty_tnc_url" => "https://www.mypitapitcard.com/terms",
        "loyalty_features" => {
          "supports_phone_number" => true
        }
      })
      render
    end

    subject { rendered }

    it { is_expected.to have_css "input#brand_loyalty_phone_number[type='text']" }
    it { is_expected.to have_css "input#brand_loyalty_phone_number[placeholder='Phone number']" }
  end
end
