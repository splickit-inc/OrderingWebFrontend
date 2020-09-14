class ModifierItem < BaseModel

  attr_accessor :modifier_item_id, :modifier_item_name, :nested_items,
                :modifier_prices_by_item_size_id, :modifier_item_max,
                :modifier_item_min, :modifier_item_pre_selected, :exclusive,
                :quantity, :modifier_item_calories
  
  def self.initialize(data={}, exclusive=false)
    modifier_item = ModifierItem.new

    if data["modifier_item_id"].present?
      modifier_item.modifier_item_id = data["modifier_item_id"].to_i
    else
      modifier_item.modifier_item_id = Time.now.nsec
    end

    if modifier_item.modifier_item_id > 9999999 && !data["nested_items"].present?
      Rails.logger.error "We have an invalid modifier item id of #{modifier_item.modifier_item_id}."
      Rails.logger.error "Initial data was #{data.inspect}"
    end

    modifier_item.modifier_item_name = data["modifier_item_name"]
    modifier_item.modifier_prices_by_item_size_id = data["modifier_prices_by_item_size_id"]
    modifier_item.modifier_item_max = data["modifier_item_max"].to_i
    modifier_item.modifier_item_min = data["modifier_item_min"].to_i
    modifier_item.modifier_item_pre_selected = parse_preselected(data["modifier_item_pre_selected"])
    modifier_item.quantity = parse_quantity(data["quantity"], modifier_item.modifier_item_pre_selected)
    modifier_item.modifier_item_calories = data["modifier_item_calories"]

    if data["nested_items"].present?
      modifier_item.nested_items = data["nested_items"].collect do |p|
        ModifierItem.initialize(p, exclusive)
      end
    end

    modifier_item.exclusive = exclusive
    modifier_item
  end

  private

  def self.parse_preselected(preselected)
    preselected == 'yes' ? true : false
  end

  def self.parse_quantity(quantity, preselected)
    if quantity.present?
      quantity
    elsif preselected
      1
    else
      0
    end
  end
end
