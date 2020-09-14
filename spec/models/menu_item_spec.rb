require "rails_helper"

describe MenuItem do
  let(:params) { get_menu_item_data }

  describe "#modifier_groups=" do
    let(:modifier_group3) { get_modifier_group_data.merge({"modifier_group_display_name" => "Kendall"}) }
    let(:modifier_group4) { get_modifier_group_data.merge({"modifier_group_display_name" => "Justin"}) }
    let(:modifier_group5) { get_modifier_group_data.merge({"modifier_group_display_name" => "Adam"}) }
    let(:new_groups) { [ModifierGroup.initialize(modifier_group3), ModifierGroup.initialize(modifier_group4), ModifierGroup.initialize(modifier_group5)] }

    it 'should replace any existing modifier groups with the new list' do
      menu_item = MenuItem.initialize(params)
      menu_item.modifier_groups = new_groups
      expect(menu_item.modifier_groups.length).to eq(3)
      expect(menu_item.modifier_groups[0].modifier_group_display_name).to eq("Kendall")
    end

    it 'should parse the array of modifier groups' do
      menu_item = MenuItem.initialize(params)
      expect(menu_item.modifier_groups.length).to eq(1)
      expect(menu_item.modifier_groups[0]).to be_a_kind_of(ModifierGroup)
      expect(menu_item.modifier_groups[0].modifier_group_display_name).to eq("options")
    end
  end

  describe ".note" do
    context "note present" do
      let(:menu_item) { MenuItem.new({"note" => "Extra chocolate syrup."}) }
      it { expect(menu_item.note).to eq("Extra chocolate syrup.") }
    end

    context "note not present" do
      let(:menu_item) { MenuItem.new }
      it { expect(menu_item.note).to eq(nil) }
    end
  end

  describe "#size_prices" do
    it "returns the prices in the correct order" do
      menu_item = MenuItem.initialize(params)
      expect(menu_item.size_prices[2]["price"]).to eq("8.24")
      expect(menu_item.size_prices[1]["price"]).to eq("9.24")
      expect(menu_item.size_prices[0]["price"]).to eq("10.24")
    end
  end

  describe "#price_range" do
    it "returns a string with the price range for an item" do
      menu_item = MenuItem.initialize(params)
      expect(menu_item.price_range).to eq(["10.24", "9.24", "8.24"])
    end
  end

  describe "#point_range" do
    it "returns a string with the point range for an item" do
      menu_item = MenuItem.initialize(params)
      expect(menu_item.point_range).to eq(["88"])
    end
  end

  describe "#get_brand_points_id" do
    it 'should return the brand_points_id for the size' do
      menu_item = MenuItem.initialize(params)
      expect(menu_item.get_brand_points_id("1"))
    end
  end

  describe "#large_image" do
    it 'should return an image over or equal to 420x640' do
      menu_item = MenuItem.initialize(params)
      expect(menu_item.large_image).to eq("https://www.placehold.it/1x/640x420")
    end

    it 'should return nil if no image exists' do
      menu_item = MenuItem.initialize(get_menu_item_data.merge("photos" => []))
      expect(menu_item.large_image).to be_nil
    end
  end

  describe "#small_image" do
    it 'should return an image less than or equal to 158x158' do
      menu_item = MenuItem.initialize(params)
      expect(menu_item.small_image).to eq("https://www.placehold.it/2x/158x158")
    end

    it 'should return nil if no image exists' do
      menu_item = MenuItem.initialize(get_menu_item_data.merge("photos" => []))
      expect(menu_item.small_image).to be_nil
    end
  end
end
