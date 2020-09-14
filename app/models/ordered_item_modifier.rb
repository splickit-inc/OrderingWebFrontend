class OrderedItemModifier < BaseModel
  attr_accessor :quantity, :size_id, :modifier_item

  def self.initialize(params={})
    ordered_item_modifier = OrderedItemModifier.new
    ordered_item_modifier.quantity = params["quantity"]
    ordered_item_modifier.size_id = params["size_id"]
    ordered_item_modifier.modifier_item = params["modifier_item"]
    ordered_item_modifier
  end
end
