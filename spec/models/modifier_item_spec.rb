require "rails_helper"

describe ModifierItem do
  describe ".initialize" do
    let(:nested_item) {
      {
          "modifier_item_name" => "No Flavor",
          "modifier_item_priority" => "9995",
          "modifier_item_id" => "2300698",
          "modifier_item_max" => "1",
          "modifier_item_min" => 0,
          "modifier_item_pre_selected" => "yes",
          "modifier_prices_by_item_size_id" => [
              {
                  "size_id" => "0",
                  "modifier_price" => "0.00"
              }
          ]
      }
    }

    subject {
      ModifierItem.initialize({
        "modifier_item_id" => "1234",
        "modifier_item_name" => "snowy cats",
        "modifier_prices_by_item_size_id" => [{"size_id" => "5"}],
        "modifier_item_max" => "2",
        "modifier_item_min" => "0",
        "modifier_item_pre_selected" => "yes",
        "nested_items" => [
          nested_item
        ]
      }, true)
    }

    it { is_expected.to respond_to(:modifier_item_id) }
    it { is_expected.to respond_to(:modifier_item_name) }
    it { is_expected.to respond_to(:modifier_prices_by_item_size_id) }
    it { is_expected.to respond_to(:modifier_item_max) }
    it { is_expected.to respond_to(:modifier_item_min) }
    it { is_expected.to respond_to(:modifier_item_pre_selected) }
    it { is_expected.to respond_to(:exclusive) }
    it { is_expected.to respond_to(:nested_items) }
    it { is_expected.to respond_to(:quantity) }

    it { expect(subject.modifier_item_id).to eq(1234) }
    it { expect(subject.modifier_item_name).to eq("snowy cats") }
    it { expect(subject.modifier_prices_by_item_size_id).to eq([{"size_id" => "5"}]) }
    it { expect(subject.modifier_item_max).to eq(2) }
    it { expect(subject.modifier_item_min).to eq(0) }
    it { expect(subject.modifier_item_pre_selected).to be_truthy }
    it { expect(subject.exclusive).to eq(true) }

    it { expect(subject.nested_items.first.modifier_item_name).to eq("No Flavor") }
    it { expect(subject.nested_items.first.modifier_item_id).to eq(2300698) }
    it { expect(subject.nested_items.first.modifier_item_max).to eq(1) }
    it { expect(subject.nested_items.first.modifier_item_min).to eq(0) }
    it { expect(subject.nested_items.first.modifier_item_pre_selected).to be_truthy }
    it { expect(subject.nested_items.first.modifier_prices_by_item_size_id).to eq([{"size_id" => "0", "modifier_price" => "0.00"}]) }
    it { expect(subject.nested_items.first.exclusive).to eq(true) }

    describe ".modifier_item_pre_selected" do
      context "preselected" do
        it { expect(ModifierItem.initialize({'modifier_item_pre_selected' => 'yes'}).modifier_item_pre_selected).to be_truthy }
      end

      context "not preselected" do
        it { expect(ModifierItem.initialize({'modifier_item_pre_selected' => 'no'}).modifier_item_pre_selected).to be_falsey }
      end
    end

    describe ".quantity" do
      context "quantity present" do
        it { expect(ModifierItem.initialize({'quantity' => 0}).quantity).to eq(0) }
        it { expect(ModifierItem.initialize({'quantity' => 1}).quantity).to eq(1) }
        it { expect(ModifierItem.initialize({'quantity' => 5}).quantity).to eq(5) }
      end

      context "quantity not present; modifier item preselected" do
        it { expect(ModifierItem.initialize({'modifier_item_pre_selected' => 'yes'}).quantity).to eq(1) }
      end

      context "quantity not present" do
        it { expect(ModifierItem.initialize.quantity).to eq(0) }
      end
    end
  end
end
