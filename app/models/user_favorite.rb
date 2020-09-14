class UserFavorite < BaseModel
  require "deep_clone"

  attr_accessor :favorite_id, :favorite_name, :items, :order_note, :tip, :order_id

  def initialize(params = {})
    self.favorite_id = params["favorite_id"].to_i
    self.order_id = params["order_id"]
    self.favorite_name = params["favorite_name"]
    self.order_note = params["note"]

    if params["favorite_order"].present? && params["menu_items"].present?
      self.items = initialize_favorites(params["favorite_order"]["items"], params["menu_items"])
    end
  end

  def self.create(params, credentials)
    parse_response(API.post("/favorites", params.to_json, credentials))
  end

  def self.destroy(id, credentials)
    parse_response(API.delete("/favorites/#{ id }", credentials))
  end

  private

  def initialize_favorites(favorite_items, menu_items)
    favorite_items.collect { |favorite_item| initialize_favorite(favorite_item, menu_items) }
  end

  def initialize_favorite(favorite_item, menu_items)
    menu_item = find_menu_item(menu_items, favorite_item["item_id"])
    set_modifier_quantities!(favorite_item, menu_item)

    menu_item.enable_size_price(favorite_item["size_id"])

    menu_item.note = favorite_item["note"]
    menu_item
  end

  def set_modifier_quantities!(item, menu_item)
    if menu_item.modifier_groups.present?
      menu_item.modifier_groups.each do |modifier_group|
        modifier_group.modifier_items.each do |modifier_item|
          if modifier_item.nested_items.present?
            modifier_item.nested_items.each do |nested_item|
              favorite_modifier = find_favorite_modifier(item, nested_item.modifier_item_id)
              nested_item.quantity = favorite_modifier ? favorite_modifier["quantity"] : 0
            end
          else
            favorite_modifier = find_favorite_modifier(item, modifier_item.modifier_item_id)
            modifier_item.quantity = favorite_modifier ? favorite_modifier["quantity"] : 0
          end
        end
      end
    end
  end

  def find_favorite_modifier(item, target)
    item["mods"].find { |m| m["modifier_item_id"].to_s == target.to_s } if item["mods"].present?
  end

  def find_menu_item(menu_items, target)
    DeepClone.clone(menu_items.select { |mi| mi.item_id.to_i == target.to_i }.first)
  end
end
