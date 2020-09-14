require "rails_helper"

describe LineItem do
  describe "#initialize" do
    it "should allow construction from a MenuItem and a list of ModifierItems" do
      menu_item = create_menu_item()
      modifier_item = create_modifier_item({"modifier_item_id" => "11"})
      modifier_items = [get_ordered_item_modifier_data.merge({"modifier_item" => modifier_item, "size_id" => "56375"})].to_json
      ordered_item = LineItem.new(menu_item, modifier_items, "2", "bigelow green tea", "1")

      expect(ordered_item.item_id).to eq(menu_item.item_id)
      expect(ordered_item.quantity).to eq("2")
      expect(ordered_item.note).to eq("bigelow green tea")
      expect(ordered_item.size_id).to eq("1")
      expect(ordered_item.points_used).to eq("340")      
      expect(ordered_item.brand_points_id).to eq("888")
      expect(ordered_item.mods.length).to eq(1)

      expect(ordered_item.mods[0]).to eq({"modifier_item_id" => 11, "size_id"=>"56375", "mod_quantity"=>"1"})
    end
  end
end
