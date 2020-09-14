require "rails_helper"

describe LoyaltiesHelper, type: :helper do
  describe '#loyalty_balance' do
    before(:each) do
      @user = {}
      @merchant = Merchant.new
      allow(@merchant).to receive(:merchant_id) { "2" }
      @order_type = "pickup"
    end

    context "with loyalty" do
      before(:each) do
        @user = User.initialize({"brand_loyalty" => {"bacon" => 100}})
      end

      it { expect(helper.loyalty_balance("bacon")).to eq(100) }
    end

    context "user has no points" do
      before(:each) do
        @user = User.initialize({"brand_loyalty" => {}})
      end

      it { expect(helper.loyalty_balance("points")).to eq(0) }
    end

    context "without loyalty of specified type" do
      before(:each) do
        @user = User.initialize({"brand_loyalty" => {"points" => 100}})
      end

      it { expect(helper.loyalty_balance("usd")).to eq(nil) }
    end

    context "order contains items" do
      before(:each) do
        @user = User.initialize({"brand_loyalty" => {"points" => 200}})
        session[:order] = {}
        session[:order][:items] = [{"points_used" => "10"}, {"points_used" => "15"}]
      end

      it "subtracts cost of items in cart from user point balance" do
        expect(helper.loyalty_balance("points")).to eq(175)
      end
    end

    context "empty order" do
      before(:each) do
        @user = User.initialize({"brand_loyalty" => {"points" => 200}})
        session[:order] = {}
        session[:order][:items] = []
      end

      it "returns the available balance" do
        expect(helper.loyalty_balance("points")).to eq(200)
      end
    end
  end

  describe '#loyalty_time' do
    let(:now) { Time.now }

    let(:date_components) do
      date = helper.loyalty_time
      date.split('/')
    end

    context "Card balance as of date" do
      it "should have 3 parts m/d/Y" do
        expect(date_components.length).to eq(3)
      end

      it "month should match" do
        m = date_components[0]
        expect(m).to eq(now.strftime("%-m"))
      end

      it "day should match" do
        d = date_components[1]
        expect(d).to eq(now.strftime("%-d"))
      end

      it "year should match" do
        y = date_components[2]
        expect(y).to eq(now.strftime("%Y"))
      end
    end
  end
end
