require "rails_helper"

describe "GroupOrdersHelper" do
  describe "#format_modifiers" do
    let(:modifiers) { [{"name" => "nails"}, {"name" => "hammers"}] }

    it { expect(helper.format_modifiers(modifiers)).to eq("Nails, Hammers") }
  end

  describe "#has_group_order?" do
    context "with group order" do
      before(:each) do
        sign_in(get_user_data.merge("email" =>"bacon@king.com", "group_order_token" => "BAKON"))
      end

      it { expect(helper.has_group_order?).to eq(true) }
    end

    context "without group order" do
      it { expect(helper.has_group_order?).to eq(false) }
    end
  end

  describe "#empty_group_order?" do
    context "items in order" do
      before(:each) do
        @group_order = { "total_submitted_orders" => "0"}
      end

      it { expect(helper.empty_group_order?).to eq(true) }
    end

    context "no items in order" do
      before(:each) do
        @group_order = {}
        @group_order["order_summary"] = nil
      end

      it { expect(helper.empty_group_order?).to eq(true) }
    end
  end

  describe "#share_link" do

    let(:merchant) {
      Merchant.new({
        "merchant_id" => "12345",
        "name" => "Hammersmith Folly",
        "address1" => "Something St.",
        "address2" => "#105",
        "city" => "Denver",
        "state" => "CO",
        "zip" => "50505",
      })
    }

    context "pickup" do

      let(:group_order) {
        {
          "group_order_id" => "1910",
          "group_order_token" => "5424-b6zqu-24j7y-d7po5",
          "merchant_id" => "102237",
          "sent_ts" => "0000-00-00 00:00:00",
          "notes" => "",
          "participant_emails" => "",
          "merchant_menu_type" => "pickup",
          "expires_at" => "1415468887",
          "order_summary" => {
            "cart_items" => [
              {
                "item_name" => "Blu Bayou",
                "item_price" => "4.29",
                "item_quantity" => "1",
                "item_description" => "Chips, Mayo",
                "order_detail_id" => "6081076",
                "item_note" => "really tasty Ham S."
              },
              {
                "item_name" => "Vitamin Water Energy",
                "item_price" => "2.29",
                "item_quantity" => "1",
                "item_description" => "Bacon, Ham",
                "order_detail_id" => "6081079",
                "item_note" => "really not tasty Ham S. "
              }
            ],
            "receipt_items" => [
              {
                "title" => "Subtotal",
                "amount" => "$13.16"
              },
              {
                "title" => "Tax",
                "amount" => "$0.79"
              },
              {
                "title" => "Total",
                "amount" => "$13.95"
              }
            ]
          }
        }
      }

      before(:each) do
        assign(:group_order, group_order)
        assign(:merchant, merchant)
      end

      it "returns the correct group order link" do
        expect(helper.share_link).to eq("http://test.host/merchants/12345?group_order_token=5424-b6zqu-24j7y-d7po5&order_type=pickup")
      end
    end

    context "delivery" do

      let(:group_order) {
        {
          "group_order_id" => "1910",
          "group_order_token" => "5424-b6zqu-24j7y-d7po5",
          "merchant_id" => "102237",
          "sent_ts" => "0000-00-00 00:00:00",
          "notes" => "",
          "participant_emails" => "",
          "merchant_menu_type" => "delivery",
          "expires_at" => "1415468887",
          "order_summary" => {
            "cart_items" => [
              {
                "item_name" => "Blu Bayou",
                "item_price" => "4.29",
                "item_quantity" => "1",
                "item_description" => "Chips, Mayo",
                "order_detail_id" => "6081076",
                "item_note" => "really tasty Ham S."
              },
              {
                "item_name" => "Vitamin Water Energy",
                "item_price" => "2.29",
                "item_quantity" => "1",
                "item_description" => "Bacon, Ham",
                "order_detail_id" => "6081079",
                "item_note" => "really not tasty Ham S. "
              }
            ],
            "receipt_items" => [
              {
                "title" => "Subtotal",
                "amount" => "$13.16"
              },
              {
                "title" => "Tax",
                "amount" => "$0.79"
              },
              {
                "title" => "Total",
                "amount" => "$13.95"
              }
            ]
          }
        }
      }

      before(:each) do
        assign(:group_order, group_order)
        assign(:merchant, merchant)
      end

      it "returns the correct group order link" do
        expect(helper.share_link).to eq("http://test.host/merchants/12345?group_order_token=5424-b6zqu-24j7y-d7po5&order_type=delivery")
      end
    end
  end

  describe "#delivery_street_address" do
    before do
      assign(:group_order, {"delivery_address" => {"address1"=>"819 Sherman Ave", "address2"=>"", "city"=>"Coeur d'Alene", "state"=>"ID", "zip"=>"83814"}})
    end

    it 'should return a formatted address' do
      expect(helper.delivery_street_address).to eq("819 Sherman Ave")
    end

    it 'should return a include address2 if provided' do
      assign(:group_order, {"delivery_address" => {"address1"=>"819 Sherman Ave", "address2"=>"Apt C", "city"=>"Coeur d'Alene", "state"=>"ID", "zip"=>"83814"}})
      expect(helper.delivery_street_address).to eq("819 Sherman Ave, Apt C")
    end
  end

  describe "#delivery_city_state_zip" do
    before do
      assign(:group_order, {"delivery_address" => {"address1"=>"819 Sherman Ave", "address2"=>"", "city"=>"Coeur d'Alene", "state"=>"ID", "zip"=>"83814"}})
    end

    it 'should return a formatted address' do
      expect(helper.delivery_city_state_zip).to eq("Coeur d'Alene, ID 83814")
    end
  end

  describe "#group_order_expire_at" do
    it "should change time to merchant's time" do
      time = DateTime.now.change({ hour: 8, min: 0, sec: 0, offset: 0 })
      assign(:group_order, { "expires_at" => time.to_i })
      assign(:merchant, Merchant.new({ "time_zone_offset" => -2 }))
      expect(helper.group_order_expire_at).to eq("6:00 AM")

      time = DateTime.now.change({ hour: 8, min: 0, sec: 0, offset: 0 })
      assign(:group_order, { "expires_at" => time.to_i })
      assign(:merchant, Merchant.new({ "time_zone_offset" => -3 }))
      expect(helper.group_order_expire_at).to eq("5:00 AM")
    end
  end

  describe "#invite_pay?" do
    it "should return true" do
      assign(:group_order, { "group_order_type" => "2" })
      expect(helper.invite_pay?).to be_truthy
    end

    it "should return false" do
      assign(:group_order, { "group_order_type" => "1" })
      expect(helper.invite_pay?).to be_falsey
    end
  end

  describe "#organizer_pay?" do
    it "should return true" do
      assign(:group_order, { "group_order_type" => "1" })
      expect(helper.organizer_pay?).to be_truthy
    end

    it "should return false" do
      assign(:group_order, { "group_order_type" => "2" })
      expect(helper.organizer_pay?).to be_falsey
    end
  end
end
