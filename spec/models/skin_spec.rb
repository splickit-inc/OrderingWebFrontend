require "rails_helper"

describe Skin do
  subject { Skin.initialize }

  it { is_expected.to respond_to(:skin_id) }
  it { is_expected.to respond_to(:skin_name) }
  it { is_expected.to respond_to(:skin_description) }
  it { is_expected.to respond_to(:brand_id) }
  it { is_expected.to respond_to(:mobile_app_type) }
  it { is_expected.to respond_to(:external_identifier) }
  it { is_expected.to respond_to(:custom_skin_message) }
  it { is_expected.to respond_to(:welcome_letter_file) }
  it { is_expected.to respond_to(:in_production) }
  it { is_expected.to respond_to(:web_ordering_active) }
  it { is_expected.to respond_to(:donation_active) }
  it { is_expected.to respond_to(:donation_organization) }
  it { is_expected.to respond_to(:facebook_thumbnail_url) }
  it { is_expected.to respond_to(:android_marketplace_link) }
  it { is_expected.to respond_to(:twitter_handle) }
  it { is_expected.to respond_to(:iphone_certificate_file_name) }
  it { is_expected.to respond_to(:current_iphone_version) }
  it { is_expected.to respond_to(:current_android_version) }
  it { is_expected.to respond_to(:facebook_app_id) }
  it { is_expected.to respond_to(:facebook_app_secret) }
  it { is_expected.to respond_to(:rules_info) }
  it { is_expected.to respond_to(:supports_history) }
  it { is_expected.to respond_to(:supports_join) }
  it { is_expected.to respond_to(:supports_link_card) }
  it { is_expected.to respond_to(:lat) }
  it { is_expected.to respond_to(:lng) }
  it { is_expected.to respond_to(:zip) }
  it { is_expected.to respond_to(:loyalty_features) }
  it { is_expected.to respond_to(:merchants_with_delivery) }
  it { is_expected.to respond_to(:iphone_app_link) }
  it { is_expected.to respond_to(:http_code) }
  it { is_expected.to respond_to(:support_email) }
  it { is_expected.to respond_to(:support_email_categories) }
  it { is_expected.to respond_to(:brand_fields) }
  it { is_expected.to respond_to(:feedback_url) }
  it { is_expected.to respond_to(:loyalty_tnc_url) }
  it { is_expected.to respond_to(:show_notes_fields) }
  it { is_expected.to respond_to(:loyalty_support_phone_number) }
  it { is_expected.to respond_to(:loyalty_card_management_link) }
  it { is_expected.to respond_to(:event_merchant) }
  it { is_expected.to respond_to(:map_url) }

  describe "#where" do
    context "skin from API" do
      before(:each) do
        allow(API).to receive_message_chain(:get, :body)   { {"data" => {"skin_name" => "hotsauce", "fake" => "param"}}.to_json }
        allow(API).to receive_message_chain(:get, :status) { 200 }
      end

      it "doesn't blow up with unknown attributes" do
        expect { Skin.where(skin_identifier: "hotsauce") }.not_to raise_error
      end

      it "returns a new Skin" do
        expect(Skin.where(skin_identifier: "hotsauce")).to be_a(Skin)
      end

      it "makes the correct API call" do
        expect(API).to receive("get").with("/skins/com.splickit.hotsauce")
        Skin.where(skin_identifier: "hotsauce")
      end
    end

    context "no skin" do
      it "returns default skin" do
        expect(Skin.where(thing: "bad")).to be_a(Skin)
      end
    end

    context "skin returned as non-hash" do
      before(:each) do
        allow(API).to receive_message_chain(:get, :body)   { {"data" => true}.to_json }
        allow(API).to receive_message_chain(:get, :status) { 200 }
      end

      it { expect{Skin.where(skin_identifier: "good")}.not_to raise_error }
      it { expect(Skin.where(skin_identifier: "good")).to be_a(Skin) }
    end

    context "caching" do
      before(:each) do
        allow(API).to receive_message_chain(:get, :body)   { {"data" => {"skin_name" => "peanutsauce", "skin_id" => "1", "fake" => "param"}}.to_json }
        allow(API).to receive_message_chain(:get, :status) { 200 }
      end

      it 'should store the skin call return in the cache' do
        expect(Rails.cache).to receive("write").with("/skins/com.splickit.peanutsauce", {"skin_name" => "peanutsauce", "skin_id" => "1", "fake" => "param"}, expires_in: 20.minutes)
        Skin.where(skin_identifier: "peanutsauce")
      end

      it 'should return the cached skin rather than making a new call' do
        expect(Rails.cache).to receive("fetch").with("/skins/com.splickit.peanutsauce").and_return({"skin_name" => "cachesauce", "skin_id" => "2", "fake" => "param"})
        skin = Skin.where(skin_identifier: "peanutsauce")
        expect(skin.skin_name).to eq("cachesauce")
        expect(skin.skin_id).to eq("2")
      end
    end
  end

  describe "#current_name" do
    it "sets the correct skin name" do
      Skin.current_name = "BIRDMAN"
      expect(Skin.current_name).to eq("BIRDMAN")
    end
  end

  describe "#apple_store_id" do
    context "iPhone app link exists" do
      before(:each) do
        @skin = Skin.initialize("iphone_app_link" => "http://itunes.mapple.com/us/app/pita-pit/id461735388?mt=8")
      end

      it "returns the apple store ID" do
        expect(@skin.apple_store_id).to eq("461735388")
      end
    end

    context "iPhone app link doesn't exists" do
      before(:each) do
        @skin = Skin.initialize
      end

      it "returns nil" do
        expect(@skin.apple_store_id).to be_nil
      end
    end

    context "iPhone app link is an empty string" do
      before(:each) do
        @skin = Skin.initialize(iphone_app_link: "")
      end

      it "returns nil" do
        expect(@skin.apple_store_id).to be_nil
      end
    end
  end

  describe "#android_marketplace_id" do
    context "android app link exists" do
      before(:each) do
        @skin = Skin.initialize("android_marketplace_link" => "https =>//play.google.com/store/apps/details?id=com.splickit.pitapit&hl=en")
      end

      it "returns the android store ID" do
        expect(@skin.android_marketplace_id).to eq("com.splickit.pitapit&hl=en")
      end
    end

    context "Android app link doesn't exist" do
      before(:each) do
        @skin = Skin.initialize
      end

      it "returns nil" do
        expect(@skin.android_marketplace_link).to be_nil
      end
    end

    context "Android app link is blank" do
      before(:each) do
        @skin = Skin.initialize(iphone_app_link: "")
      end

      it "returns nil" do
        expect(@skin.apple_store_id).to be_nil
      end
    end
  end

  describe "#loyalty_supports_pin?" do
    context "show pin field exists" do
      before(:each) do
        @skin = Skin.initialize({"loyalty_features" => {"supports_pin" => false}})
      end

      it { expect(@skin.loyalty_supports_pin?).to eq(false) }
    end

    context "show pin doesn't exist" do
      before(:each) do
        @skin = Skin.initialize({"loyalty_features" => {}})
      end

      it { expect(@skin.loyalty_supports_pin?).to eq(true) }
    end
  end

  describe "#loyalty_join?" do
    context "supports_join is false" do
      before(:each) do
        @skin = Skin.initialize({"loyalty_features" => {"supports_join" => false}})
      end

      it { expect(@skin.loyalty_supports_join?).to eq(false) }
    end

    context "supports_join is not set" do
      before(:each) do
        @skin = Skin.initialize({"loyalty_features" => {}})
      end

      it { expect(@skin.loyalty_supports_join?).to eq(true) }
    end
  end

  describe "#loyalty_supports_phone_number?" do
    context "supports phone number field exists" do
      before(:each) do
        @skin = Skin.initialize({"loyalty_features" => {"supports_phone_number" => true}})
      end

      it { expect(@skin.loyalty_supports_phone_number?).to eq(true) }
    end

    context "supports phone number field doesn't exist" do
      before(:each) do
        @skin = Skin.initialize({"loyalty_features" => {}})
      end

      it { expect(@skin.loyalty_supports_phone_number?).to eq(false) }
    end
  end

  describe "#is_moes?" do
    context "moes skin" do
      before do
        @skin = Skin.initialize({"skin_name" => "Moes"})
      end

      it { expect(@skin.is_moes?).to eq(true) }
    end

    context "non-moes skin" do
      before do
        @skin = Skin.initialize({"skin_name" => "masterpiece"})
      end

      it { expect(@skin.is_moes?).to eq(false) }
    end
  end

  describe "#third_party_loyalty?" do
    it "should return true when loyalty_type is 3rd" do
      skin =  Skin.initialize("loyalty_features" => { "loyalty_type" => "remote" })
      expect(skin.third_party_loyalty?).to be_truthy
    end

    it "should return true when loyalty_type is not 3rd" do
      skin =  Skin.initialize("loyalty_features" => { "loyalty_type" => "splickit_earn" })
      expect(skin.third_party_loyalty?).to be_falsey
    end
  end

  describe "#third_party_loyalty?" do
    it "should return true when loyalty_type is 2nd" do
      skin =  Skin.initialize("loyalty_features" => { "loyalty_type" => "splickit_earn" })
      expect(skin.splickit_loyalty?).to be_truthy
    end

    it "should return true when loyalty_type is not 2nd" do
      skin =  Skin.initialize("loyalty_features" => { "loyalty_type" => "remote" })
      expect(skin.splickit_loyalty?).to be_falsey
    end
  end
end
