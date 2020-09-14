class MenuType < BaseModel
  attr_accessor :menu_type_id, :menu_type_name, :menu_type_description,
    :start_time, :end_time, :menu_items, :upsell_item_ids, :visible, :image_url

  def self.initialize(params={})
    menu_type = MenuType.new
    menu_type.menu_type_id = params["menu_type_id"]
    menu_type.menu_type_name = params["menu_type_name"]
    menu_type.menu_type_description = params["menu_type_description"]
    menu_type.start_time = params["start_time"]
    menu_type.end_time = params["end_time"]
    menu_type.image_url = params["image_url"]
    menu_type.menu_items = params["menu_items"].collect { |p| MenuItem.initialize(p) }
    menu_type.upsell_item_ids = params["upsell_item_ids"]
    menu_type.visible = params["visible"]
    menu_type
  end

  def find_menu_item(menu_item_id)
    menu_items.detect{ |menu_item| menu_item.item_id.to_i == menu_item_id.to_i }
  end

end
