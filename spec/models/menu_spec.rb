require "rails_helper"

describe Menu do
  let(:menu_item1){get_menu_item_data.merge({"item_id" => "3456", "item_name" => "Toast", "price" => "1.00"})}
  let(:menu_item2){get_menu_item_data.merge({"item_id" => "7890", "item_name" => "Egg", "price" => "2.00"})}
  let(:menu_item3){get_menu_item_data.merge({"item_id" => "4789", "item_name" => "Meat", "price" => "10.00"})}
  let(:menu_item4){get_menu_item_data.merge({"item_id" => "6543", "item_name" => "Fish", "price" => "12.00"})}

  let(:modifier_group1){{modifier_group_id: "1111", modifier_group_name: "bob"}}
  let(:modifier_group2){{modifier_group_id: "2222", modifier_group_name: "jim"}}
  let(:menu_type1){{"menu_type_id" => "0987", "menu_type_name" => "Breakfast", "start_time" => "00:00:00", "end_time" => "23:59:59", "menu_items" => [menu_item1, menu_item2]}}
  let(:menu_type2){{"menu_type_id" => "0987", "menu_type_name" => "Lunch", "start_time" => "00:00:00", "end_time" => "23:59:59", "menu_items" => [menu_item3, menu_item4]}}
  let(:params) { {"menu_id" => "4567", "name" => "2014 Menu", "menu_types" => [menu_type1, menu_type2], :modifier_groups => [modifier_group1, modifier_group2]} }


  describe "#menu_types=" do
    let(:menu_type3){{"menu_type_id" => "3456", "menu_type_name" => "Dinner", "start_time" => "00:00:00", "end_time" => "23:59:59", "menu_items" => [menu_item1, menu_item2]}}
    let(:menu_type4){{"menu_type_id" => "6543", "menu_type_name" => "Brunch", "start_time" => "00:00:00", "end_time" => "23:59:59", "menu_items" => [menu_item3, menu_item4]}}
    let(:new_types){[menu_type3, menu_type4]}

    it 'should parse the array of menu types' do
      menu = Menu.initialize(params)
      expect(menu.menu_types.length).to eq(2)

      expect(menu.menu_types[0]).to be_a_kind_of(MenuType)
      expect(menu.menu_types[0].menu_type_name).to eq("Breakfast")

      expect(menu.menu_types[1]).to be_a_kind_of(MenuType)
      expect(menu.menu_types[1].menu_type_name).to eq("Lunch")
    end
  end

  describe '.charge_modifiers_loyalty_purchase' do
    context 'enabled' do
      it do
        expect(Menu.initialize({
          'menu_types' => [menu_type1],
          'charge_modifiers_loyalty_purchase' => '1'
        }).charge_modifiers_loyalty_purchase).to be_truthy
      end
    end

    context 'disabled' do
      it do
        expect(Menu.initialize({
          'menu_types' => [menu_type1],
          'charge_modifiers_loyalty_purchase' => '0'
        }).charge_modifiers_loyalty_purchase).to be_falsey
      end
    end
  end

  describe "find_menu_item" do
    it "should return nil when there isn't the item" do
      menu = Menu.initialize(params)
      expect(menu.find_menu_item("10000")).to be_nil
    end

    it "should return the item when it belongs to menu" do
      menu = Menu.initialize(params)
      menu_item = menu.find_menu_item("3456")
      expect(menu_item).to be_kind_of(MenuItem)
      expect(menu_item.item_id).to eq(menu_item1["item_id"])
      expect(menu_item.item_name).to eq(menu_item1["item_name"])
    end
  end

  describe "get_upsell_items" do
    let(:menu) { Menu.initialize(params.merge("upsell_item_ids" => ["3456", "7890"])) }

    it "should return nil when there isn't any upsell item ids" do
      menu.upsell_item_ids = nil
      expect(menu.get_upsell_items).to be_nil
    end

    it "should return an array with all upsell items" do
      upsell_items = menu.get_upsell_items
      expect(upsell_items).to be_kind_of(Array)
      expect(upsell_items.length).to eq(2)
      expect(upsell_items.first).to be_kind_of(MenuItem)
      expect(upsell_items.first.item_id).to eq(menu_item1["item_id"])
      expect(upsell_items.first.item_name).to eq(menu_item1["item_name"])
      expect(upsell_items.last).to be_kind_of(MenuItem)
      expect(upsell_items.last.item_id).to eq(menu_item2["item_id"])
      expect(upsell_items.last.item_name).to eq(menu_item2["item_name"])
    end
  end
end
