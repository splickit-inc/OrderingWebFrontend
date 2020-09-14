module CartsHelper
  STATUS = { new: "new", updated: "updated", deleted: "deleted" }

  def get_items
    session[:order][:items].select { |item| item["status"] != STATUS[:deleted] }
  end

  def item_count
    session[:order] ? get_items.length : 0
  end

  def reset_items_for_new_order
    session[:order][:items].each do |item|
      if item["status"] == STATUS[:deleted]
        session[:order][:items].delete(item)
      else
        item["status"] = STATUS[:new]
        item.delete("order_detail_id")
      end
    end if order_exists?
  end

  def find_item(params = {})
    session[:order][:items].find do |item|
      params.inject(true) { |m, (key, value)| m && item[key].to_s == value.to_s }
    end if order_exists?
  end

  def update_item(criteria, params)
    item = find_item(criteria)
    item.merge!(params) if item.present?
  end

  def delete_item(criteria)
    item = find_item(criteria)
    session[:order][:items].delete(item)
  end

  def reset_cart!
    session.delete(:lead_day_array)
    session.delete(:time_zone)
    session.delete(:show_dine_option)
    session.delete(:order)
  end

  def initialize_order
    create_new_order unless order_exists?
  end

  def order_exists?
    session[:order] && session[:order][:items] && session[:order][:meta]
  end

  def set_cart_id(cart_id)
    session[:order][:cart_id] = cart_id if order_exists?
  end

  def reset_cart_id
    session[:order].delete(:cart_id) if session[:order]
  end

  def set_cart_order_type(order_type)
    session[:order][:meta][:order_type] = order_type if order_exists?
  end

  def cart_merchant_id
    session[:order][:meta][:merchant_id] if order_exists?
  end

  def cart_catering_order?
    (session[:order][:meta][:catering] if order_exists?) || false
  end

  def create_new_order
    session[:order] = {}
    session[:order][:items] = []
    session[:order][:meta] = {}
  end
end