class ModifierGroup < BaseModel
  attr_accessor :modifier_group_display_name, :modifier_group_credit,
                :modifier_group_max_price, :modifier_group_max_modifier_count,
                :modifier_group_min_modifier_count, :modifier_group_type, :modifier_items,
                :modifier_group_credit_by_size

  def self.initialize(params={})
    modifier_group = ModifierGroup.new
    modifier_group.modifier_group_display_name = params["modifier_group_display_name"]
    modifier_group.modifier_group_credit = params["modifier_group_credit"]
    modifier_group.modifier_group_max_price = params["modifier_group_max_price"]
    modifier_group.modifier_group_max_modifier_count = params["modifier_group_max_modifier_count"]
    modifier_group.modifier_group_min_modifier_count = params["modifier_group_min_modifier_count"]
    modifier_group.modifier_group_type = params["modifier_group_type"]
    modifier_group.modifier_group_credit_by_size = params["modifier_group_credit_by_size"]
    modifier_group.modifier_items = params["modifier_items"].collect do |p|
      ModifierItem.initialize(p, self.is_exclusive?(modifier_group.modifier_group_max_modifier_count, modifier_group.modifier_group_min_modifier_count))
    end
    modifier_group
  end

  def find_modifier_item(modifier_item_id)
    modifier_items.find{ |modifier_item| modifier_item.modifier_item_id.to_i == modifier_item_id.to_i }
  end

  private

  def self.is_exclusive?(modifier_group_max, modifier_group_min)
    modifier_group_max.to_s == "1" && modifier_group_min.to_s == "1"
  end
end

