require "rails_helper"

describe ModifierGroup do
  let(:modifier_item1) { {"modifier_item_id" => "1", "modifier_item_name" => "ice cream", "modifier_item_max" => "1"} }
  let(:modifier_item2) { {"modifier_item_id" => "2", "modifier_item_name" => "sauerkraut", "modifier_item_max" => "1"} }
  let(:modifier_params) { {"modifier_group_id" => "1111", "modifier_group_name" => "bob", "modifier_items" => [modifier_item1, modifier_item2]} }

  describe "attributes" do
    it "should respond to modifier_group_type" do
      expect(subject).to respond_to(:modifier_group_type)
    end
  end

  describe ".initialize" do
    let(:modifier_item3) { {"modifier_item_id" => "3", "modifier_item_name" => "butterscotch", "modifier_item_max" => "1"} }
    let(:modifier_item4) { {"modifier_item_id" => "4", "modifier_item_name" => "caramel", "modifier_item_max" => "1"} }
    let(:modifier_item5) { {"modifier_item_id" => "5", "modifier_item_name" => "vinegar", "modifier_item_max" => "1"} }
    let(:new_items) { [ModifierItem.initialize(modifier_item3), ModifierItem.initialize(modifier_item4), ModifierItem.initialize(modifier_item5)] }

    it 'should parse modifier items' do
      mg = ModifierGroup.initialize(modifier_params)
      expect(mg.modifier_items.length).to eq(2)
      expect(mg.modifier_items[0]).to be_a_kind_of(ModifierItem)
      expect(mg.modifier_items[0].modifier_item_id).to eq(1)
    end

    it 'should replace any existing modifier items with the new list' do
      mg = ModifierGroup.initialize(modifier_params)
      mg.modifier_items = new_items
      expect(mg.modifier_items.length).to eq(3)
      expect(mg.modifier_items[0].modifier_item_name).to eq("butterscotch")
    end

    it "should set modifier_group_type" do
      mg = ModifierGroup.initialize(modifier_params)
      expect(mg.modifier_group_type).to be_nil

      mg = ModifierGroup.initialize(modifier_params.merge("modifier_group_type" => "I2"))
      expect(mg.modifier_group_type).to eq("I2")


    end
  end

  describe ".is_exclusive?" do
    it { expect(ModifierGroup.is_exclusive?(1, 1)).to eq(true) }
    it { expect(ModifierGroup.is_exclusive?(2, 1)).to eq(false) }
    it { expect(ModifierGroup.is_exclusive?(1, 0)).to eq(false) }
  end
end
