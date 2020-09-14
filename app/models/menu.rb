class Menu < BaseModel
  attr_accessor :menu_id, :name, :menu_types, :menu_key,
                :charge_modifiers_loyalty_purchase, :upsell_item_ids, :upsell_items,
                :menu_type_upsells

  def self.initialize(params = {})
    if params.present?
      menu = Menu.new
      menu.menu_id = params["menu_id"]
      menu.name = params["name"]
      menu.menu_types = params["menu_types"].collect { |p| MenuType.initialize(p) }
      menu.charge_modifiers_loyalty_purchase = params["charge_modifiers_loyalty_purchase"] == "1"
      menu.upsell_item_ids = params["upsell_item_ids"]
      menu.upsell_items = menu.get_upsell_items.compact if menu.get_upsell_items.present?
      menu.menu_type_upsells = menu.get_menu_type_upsell_items if menu.get_menu_type_upsell_items.present?
      menu
    end
  end

  def menu_items
    menu_types.collect { |menu_type| menu_type.menu_items }.flatten
  end

  def find_menu_item(menu_item_id)
    self.menu_types.each do |menu_type|
      menu_item = menu_type.find_menu_item(menu_item_id)
      return menu_item if menu_item
    end
    nil
  end

  def get_upsell_items
    upsell_item_ids.map{ |item_id| find_menu_item(item_id) } if upsell_item_ids.present?
  end

  def get_menu_type_upsell_items
    upsells = []
    i = 0
    self.menu_types.each do |menu_type|
      if menu_type.upsell_item_ids.present?
        menu_type_upsells = menu_type.upsell_item_ids.map{ |item_id| find_menu_item(item_id) }
        upsells[i] = {menu_type_id: menu_type.menu_type_id, upsells: menu_type_upsells}
        i+=1
      end
    end
    return upsells unless upsells.empty?
  end
end
