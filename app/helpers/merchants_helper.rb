module MerchantsHelper
  def merchant_map_url
    "https://maps.google.com/?q=#{ URI.encode(@merchant.full_address) }"
  end

  def item_price_string(price, points)
    price_str = "$#{price}"
    price_str << " or #{points}pts" if points.present?
    price_str
  end

  def active_merchant_id
    session[:order][:meta][:merchant_id] if session[:order] && session[:order][:meta]
  end

  def active_merchant_name
    session[:order][:meta][:merchant_name] if session[:order] && session[:order][:meta]
  end

  def store_hours_pickup
    @merchant.readable_hours["pickup"].values if (@merchant && @merchant.readable_hours && @merchant.readable_hours["pickup"]).present?
  end

  def store_hours_delivery
    @merchant.readable_hours["delivery"].values if (@merchant && @merchant.readable_hours && @merchant.readable_hours["delivery"]).present?
  end

  def store_hours
    days = @merchant.readable_hours["pickup"].keys | @merchant.readable_hours["delivery"].keys
    days.map do |day|
      pickup = @merchant.readable_hours["pickup"][day].values.first if (@merchant.readable_hours["pickup"] && @merchant.readable_hours["pickup"][day]).present?
      delivery = @merchant.readable_hours["delivery"][day].values.first if (@merchant.readable_hours["delivery"] && @merchant.readable_hours["delivery"][day]).present?
      { @merchant.readable_hours["pickup"][day].keys.first => { "pickup" => pickup, "delivery" => delivery } }
    end
  end

  def hour_week_time_format(value, format)
    Time.at(value.to_i).in_time_zone(@merchant.time_zone_offset.to_i).strftime(format)
  end
end
