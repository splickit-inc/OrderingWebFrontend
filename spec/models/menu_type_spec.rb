require "rails_helper"

describe MenuType do
  let(:menu_item1) { { "item_id" => "3456", "item_name" => "Toast", "price" => "1.00" } }
  let(:menu_item2) { { "item_id" => "7890", "item_name" => "Egg", "price" => "2.00" } }
  let(:params) { { "menu_type_id" => "0987",
                   "menu_type_name" => "Breakfast",
                   "start_time" => "00:00:00",
                   "end_time" => "23:59:59",
                   "menu_items" => [menu_item1, menu_item2] } }

  it 'should parse out the array of menu items' do
    menu_type = MenuType.initialize(params)
    expect(menu_type.menu_items.length).to eq(2)
    expect(menu_type.menu_items[0].item_name).to eq("Toast")
  end

  describe "find_menu_item" do
    it "should return expected menu item" do
      menu_type = MenuType.initialize(params)
      menu_item = menu_type.find_menu_item("3456")
      expect(menu_item).to be_kind_of(MenuItem)
      expect(menu_item.item_id).to eq(menu_item1["item_id"])
      expect(menu_item.item_name).to eq(menu_item1["item_name"])
    end

    it "should return nil when there isn't any compared item in menu" do
      menu_type = MenuType.initialize(params)
      expect(menu_type.find_menu_item("10000")).to be_nil
    end
  end
end
