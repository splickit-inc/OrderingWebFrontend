require "rails_helper"

describe "OrdersHelper" do
  describe "#default_payment?" do
    let(:cash_payment) { { "merchant_payment_type_map_id" => 1000 } }
    let(:credit_payment) { { "merchant_payment_type_map_id" => 2000 } }
    let(:loyalty_payment) { { "merchant_payment_type_map_id" => 3000 } }
    let(:other_loyalty_payment) { { "merchant_payment_type_map_id" => 7000 } }

    context "all available" do
      before(:each) do
        assign(:cash_payments, [cash_payment])
        assign(:credit_payments, [credit_payment])
        assign(:loyalty_payments, [loyalty_payment])
      end

      it { expect(helper.default_payment?(cash_payment)).to eq(false) }
      it { expect(helper.default_payment?(credit_payment)).to eq(true) }
      it { expect(helper.default_payment?(loyalty_payment)).to eq(false) }
    end

    context "credit as default" do
      before(:each) do
        assign(:cash_payments, [])
        assign(:credit_payments, [credit_payment])
        assign(:loyalty_payments, [loyalty_payment])
      end

      it { expect(helper.default_payment?(cash_payment)).to eq(false) }
      it { expect(helper.default_payment?(credit_payment)).to eq(true) }
      it { expect(helper.default_payment?(loyalty_payment)).to eq(false) }
    end

    context "cash as default" do
      before(:each) do
        assign(:cash_payments, [cash_payment])
        assign(:loyalty_payments, [loyalty_payment])
      end

      it { expect(helper.default_payment?(cash_payment)).to eq(true) }
      it { expect(helper.default_payment?(credit_payment)).to eq(false) }
      it { expect(helper.default_payment?(loyalty_payment)).to eq(false) }
    end

    context "loyalty as default" do
      before(:each) do
        assign(:loyalty_payments, [loyalty_payment])
      end

      it { expect(helper.default_payment?(cash_payment)).to eq(false) }
      it { expect(helper.default_payment?(credit_payment)).to eq(false) }
      it { expect(helper.default_payment?(loyalty_payment)).to eq(true) }
    end

    context "loyalty array of two or more items" do
      before(:each) do
        assign(:loyalty_payments, [loyalty_payment, other_loyalty_payment])
      end

      it { expect(helper.default_payment?(cash_payment)).to eq(false) }
      it { expect(helper.default_payment?(credit_payment)).to eq(false) }
      it { expect(helper.default_payment?(loyalty_payment)).to eq(true) }
      it { expect(helper.default_payment?(other_loyalty_payment)).to eq(false) }
    end
  end

  describe "#time_options_for_select" do

    it 'should return k/v pairs for an array of sys times' do
      options = helper.time_options_for_select(['1413571480', '1413571540'], -6)
      expect(options).to eq([['12:44 PM', '1413571480'], ['12:45 PM', '1413571540']])

    end

    it 'should return k/v pairs with days names for an array of sys times' do

      offset = -6
      today = Time.now
      times = [today.to_i.to_s]

      2.times do |t|
        times << (today + ( t + 1 ).day).to_i.to_s
      end
      expect_times = [[(today.utc + offset.hours).strftime("%l:%M %p Today"), today.to_i.to_s]]

      2.times do |t|
        expect_times << [((today.utc + offset.hours) + (t + 1).day).strftime("%l:%M %p %A"), (today + (t + 1).day).to_i.to_s]
      end

      options = helper.time_options_for_select(times, offset)
      expect(options).to eq(expect_times)

    end

    it 'should return k/v pairs for an array of sys times with ASAP option' do
      offset = -6
      today = Time.now
      times = ["As soon as possible", today.to_i.to_s]

      2.times do |t|
        times << (today + ( t + 1 ).day).to_i.to_s
      end

      expect_times = [["As soon as possible", "As soon as possible"]].concat([[(today.utc + offset.hours).strftime("%l:%M %p Today"), today.to_i.to_s]])

      2.times do |t|
        expect_times << [((today.utc + offset.hours) + (t + 1).day).strftime("%l:%M %p %A"), (today + (t + 1).day).to_i.to_s]
      end

      options = helper.time_options_for_select(times, offset)
      expect(options).to eq(expect_times)

    end

  end

  describe "format the time for pickup/deliver" do
    it "format for pickup" do
      expect(helper.format_time(1448033556)).to eq(" 3:32 PM")
      expect(helper.format_time(1448037156, "pickup", -6)).to eq("10:32 AM")
      #next day
      expect(helper.format_time(1448119956, "pickup", -6)).to eq(" 9:32 AM")
    end

    it "format for delivery" do
      offset = -6
      expect(helper.format_time(1448033556, "delivery")).to eq(" 3:32 PM Today")
      expect(helper.format_time(1448037156, "delivery", offset)).to eq("10:32 AM Today")
      #next day
      today = Time.now.to_i + 1.days
      expect(helper.format_time(today, "delivery", offset)).to eq((Time.at(today).utc + offset.hours).strftime("%l:%M %p %A"))
    end
  end

  describe "#format_tips" do
    let(:tip_array) { [{"10%" => "0.20"}, {"15%" => "0.30"}] }

    it "formats the tips correctly" do
      expect(helper.format_tips(tip_array)).to eq([%w[10% 0.20], %w[15% 0.30]])
    end
  end

  describe "#generate_total" do
    context "receipt dollar and points" do
      let(:order_receipt_dollars) {{ total: "5.99", points_used: "0" }}
      let(:order_receipt_points) {{ total: "0.00", points_used: "90" }}
      let(:order_receipt_dollars_points) {{ total: "5.99", points_used: "90" }}
      it 'should list usd total if dollars > 0 and points = 0' do
        expect(helper.generate_total(order_receipt_dollars)).to eq("$5.99")
      end

      it 'should list points total if points > 0 and dollars = 0.00' do
        expect(helper.generate_total(order_receipt_points)).to eq("90 pts")
      end

      it 'should list dollars and points total if points > 0 and dollars > 0.00' do
        expect(helper.generate_total(order_receipt_dollars_points)).to eq("$5.99 + 90 pts")
      end
    end

    context "receipt dollar" do
      let(:order_receipt_dollars_valid) {{ total: "5.49" }}
      let(:order_receipt_dollars_zero) {{ total: "0" }}
      let(:order_receipt_dollars_invalid) {{ total: "-5.49" }}

      it 'should list usd total $5.49' do
        expect(helper.generate_total(order_receipt_dollars_valid)).to eq("$5.49")
      end

      it 'should list 0.00' do
        expect(helper.generate_total(order_receipt_dollars_zero)).to eq("$0.00")
      end

      it 'should list 0.00' do
        expect(helper.generate_total(order_receipt_dollars_invalid)).to eq("0.00")
      end
    end

    context "receipt points" do
      let(:order_receipt_points_valid) {{ points_used: "90" }}
      let(:order_receipt_points_zero) {{ points_used: "0" }}
      let(:order_receipt_dollars_invalid) {{total: "-1"}}

      it 'should list points total 90 pts' do
        expect(helper.generate_total(order_receipt_points_valid)).to eq("90 pts")
      end

      it 'should list points total 0.00 pts' do
        expect(helper.generate_total(order_receipt_dollars_invalid)).to eq("0.00")
      end
    end
  end

  describe "#checkout_title" do
    context "delivery group order" do
      before do
        assign(:order_type, "delivery")
        assign(:group_order_token, "123")
      end

      it { expect(helper.checkout_title).to eq("Place group order - Delivery") }
    end

    context "delivery order" do
      before do
        assign(:order_type, "delivery")
      end

      it { expect(helper.checkout_title).to eq("Place order - Delivery") }
    end

    context "pickup group order" do
      before do
        assign(:order_type, "pickup")
        assign(:group_order_token, "123")
      end

      it { expect(helper.checkout_title).to eq("Place group order") }
    end

    context "pickup order" do
      before( :each) do
        assign(:order_type, "pickup")
      end

      it { expect(helper.checkout_title).to eq("Place order") }

    end
  end

  describe "#select_time_label" do
    context "delivery" do
      before { assign(:order_type, "delivery") }

      it { expect(helper.select_time_label).to eq("Select a delivery time") }

    end

    context "pickup" do
      before { assign(:order_type, "pickup") }

      it { expect(helper.select_time_label).to eq("Select a pickup time") }

    end
  end

  describe "item_name" do
    context "standard order" do
      it { expect(helper.item_name({"name" => "Eggs"})).to eq("Eggs") }
    end

    context "group order" do
      it { expect(helper.item_name({"item_name" => "Bacon"})).to eq("Bacon") }
    end
  end

  describe "item_description" do
    context "standard order" do
      it 'should use modifiers if item description does not exist' do
        expect(helper.item_description({"mods" => [{"name" => "Cheesy", "mod_quantity" => "1"}, {"name" => "Creamy", "mod_quantity" => "2"}]})).to eq("Cheesy, Creamy(2x)")
      end

      it 'should not have a description if the item does not have modifiers or items description' do
        expect(helper.item_description({"name"=>"Coke, just a bag of coke"})).to eq("")
      end
    end

    context "group order" do
      it { expect(helper.item_description({"item_description" => "Salty"})).to eq("Salty") }
    end
  end

  describe "item_price" do
    context "standard order" do
      it { expect(helper.item_price({"price_string" => "$5.50"})).to eq("$5.50") }
    end

    context "group order" do
      it { expect(helper.item_price({"item_price" => "$6.50"})).to eq("$6.50") }
    end
  end

  describe "item_note" do
    context "standard order" do
      it { expect(helper.item_note({"notes" => "Hold the mayo."})).to eq("Hold the mayo.") }
    end

    context "group order" do
      it { expect(helper.item_note({"item_note" => "Tom P."})).to eq("Tom P.") }
    end
  end

  describe "#item_name_string" do
    it "returns a string with all item names" do
      expect(helper.item_name_string([
        {"item_name" => "foo"},
        {"item_name" => "bar"}
      ])).to eq("foo;bar")
    end
  end

  describe "#rewards_class" do
    it "should return nil if title does not include rewards" do
      expect(helper.rewards_class("123")).to be_nil
    end

    it "should return rewards if title includes rewards" do
      expect(helper.rewards_class("123rewards")).to eq("rewards")
    end
  end
end
