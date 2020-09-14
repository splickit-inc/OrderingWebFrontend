class LineItem < BaseModel

  attr_accessor :item_id, :quantity, :note, :size_id, :points_used, :brand_points_id, :mods

  def initialize(menu_item, modifier_items = [], quantity = "1", note = "", size_id = "")
    @item_id = menu_item.item_id
    @item_name = menu_item.item_name
    @description = menu_item.description
    @quantity = quantity
    @note = note
    @size_id = size_id.empty? ? menu_item.size_prices[0]["size_id"] : size_id
    if menu_item.points.to_i > 0
      @points_used = menu_item.points
      @brand_points_id = menu_item.get_brand_points_id(@size_id)
    end

    self.mods = modifier_items
  end

  def mods= ordered_modifier_items
    ordered_modifier_items = JSON.parse(ordered_modifier_items) unless ordered_modifier_items.kind_of?(Array)

    mods = []
    ordered_modifier_items.each do |ordered_modifier_item|
      mod = OrderedItemModifier.initialize(ordered_modifier_item)
      mod_hash = {}
      mod_hash['modifier_item_id'] = mod.modifier_item["modifier_item_id"]
      mod_hash['size_id'] = mod.size_id
      mod_hash['mod_quantity'] = mod.quantity
      mods << mod_hash
    end
    @mods = mods
  end
end
