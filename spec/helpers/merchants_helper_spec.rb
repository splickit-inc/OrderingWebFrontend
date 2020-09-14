require "rails_helper"

describe MerchantsHelper, type: :helper do
  describe "#merchant_map_url" do
    it "returns an encoded URL" do
      @merchant = Merchant.new
      allow(@merchant).to receive(:full_address) { "1234 Bacon Ln. Denver, CO 8000" }
      expect(helper.merchant_map_url).to eq("https://maps.google.com/?q=1234%20Bacon%20Ln.%20Denver,%20CO%208000")
    end
  end

  describe "#item_price_string" do
    context "with price" do
      let(:item) {
        MenuItem.initialize({
          "size_prices" => [
            {
              "price" => "20"
            },
            {
              "price" => "50"
            }
          ]
        })
      }
      it { expect(helper.item_price_string(item.price_range.first, item.point_range.first)).to eq("$50") }
    end

    context "with price and points" do
      let(:item) {
        MenuItem.initialize({
          "size_prices" => [
            {
              "price" => "55",
              "points" => "30"
            },
            {
              "price" => "50",
              "points" => "55"
            }
          ]
        })
      }
      it { expect(helper.item_price_string(item.price_range.first, item.point_range.first)).to eq("$50 or 55pts") }
    end
  end

  describe "#active_merchant_id" do
    context "order exists" do
      before(:each) do
        session[:order] = {}
        session[:order][:meta] = {merchant_id: "2134"}
      end

      it { expect(helper.active_merchant_id).to eq("2134") }
    end

    context "order doesn't exist" do
      it { expect(helper.active_merchant_id).to eq(nil) }
    end
  end

  describe "#active_merchant_name" do
    context "order exists" do
      before(:each) do
        session[:order] = {}
        session[:order][:meta] = {merchant_name: "Bob Barker"}
      end

      it { expect(helper.active_merchant_name).to eq("Bob Barker") }
    end

    context "order doesn't exist" do
      it { expect(helper.active_merchant_name).to eq(nil) }
    end
  end
end
