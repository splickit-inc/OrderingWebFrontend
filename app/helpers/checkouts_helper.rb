module CheckoutsHelper
  def default_payment?(payment)
    if @payment.present?
      payment["merchant_payment_type_map_id"] == @payment
    else
      default_payment = [@credit_payments, @cash_payments, @loyalty_payments, @gift_payments, @other_payments].flatten.compact.first
      default_payment["merchant_payment_type_map_id"] == payment["merchant_payment_type_map_id"]
    end
  end

  def time_options_for_select times, offset = 0, hour_format=false
    time_now = Time.now.utc + offset.hours

    end_of_day =  Time.new(time_now.year, time_now.month, time_now.day, 23, 59, 59, "+00:00").utc

    values_for_next_day = times.count { |t| Time.at(t.to_i).utc + offset.hours > end_of_day}

    times.map do |time|
      begin
        current_time = Time.at(Integer(time)).utc + offset.hours


        date_format = "%l:%M %p"
        if !hour_format
          if values_for_next_day > 0
            date_format << if current_time <= end_of_day
                             " Today"
                           else
                             " %A"
                           end
          end
        end

        [(current_time).strftime(date_format), time]
      rescue
        [time, time]
      end
    end
  end

  def format_time time, order_type = "pickup", offset = 0
    date_format = "%l:%M %p"
    time_now = Time.now.utc + offset.hours
    current_time = Time.at(time.to_i).utc + offset.hours

    if order_type == "delivery"
      end_of_day =  Time.new(time_now.year, time_now.month, time_now.day, 23, 59, 59, "+00:00").utc
      date_format << if current_time <= end_of_day
                       " Today"
                     else
                       " %A"
                     end

    end
    current_time.strftime(date_format)
  end

  def format_tips(tip_array)
    return [] if tip_array.blank?
    tip_array.map { |t| t.flatten }
  end

  def generate_total(order_receipt)
    case
      when order_receipt[:total].present? && order_receipt[:points_used].present?
        self.evaluate_total_and_points(order_receipt[:total].to_f, order_receipt[:points_used].to_i)
      when order_receipt[:total].present? && order_receipt[:total].to_f >= 0
        number_to_currency(order_receipt[:total])
      when order_receipt[:points_used].present? && order_receipt[:points_used].to_i >= 0
        "#{ order_receipt[:points_used] } pts"
      else
        '0.00'
    end
  end

  def evaluate_total_and_points(total, points_used)
    case
      when total > 0 && points_used > 0
        "#{ number_to_currency(total) } + #{ points_used } pts"
      when total >= 0 && (points_used <= 0)
        number_to_currency(total)
      when points_used > 0 && (total <= 0)
        "#{ points_used } pts"
      else
        '0.00'
    end
  end

  def checkout_title
    title = "Review your"
    title << " group" if is_a_group_order?
    title << " order" if !is_wtjmmj?
    title << " Reservation" if is_wtjmmj?
    title << " - Delivery" if @order_type == "delivery"
    title
  end

  def select_time_label
    "#{ @order_type == "delivery" ? "Delivery" : "Pickup" } at"
  end

  def item_name(item)
    item["name"] || item["item_name"]
  end

  def item_description(item)
    if item["item_description"]
      item["item_description"]
    else
      if item["mods"]
        if item["mods"].kind_of?(Array)
          mods = item["mods"].map do |mod|
            mod_text = mod["name"]
            if mod["mod_quantity"].to_i > 1
              mod_text = mod_text + "(#{mod["mod_quantity"]}x)"
            end
            mod_text
          end
        else
          mods = item["mods"].values.map do |mod|
            mod_text = mod["name"]
            if mod["mod_quantity"].to_i > 1
              mod_text = mod_text + "(#{mod["mod_quantity"]}x)"
            end
            mod_text
          end
        end
        mods.join(", ")
      else
        ""
      end
    end
  end

  def item_price(item)
    item["price_string"] || item["item_price"]
  end

  def item_note(item)
    item["notes"] || item["item_note"]
  end

  def item_name_string(cart_items)
    cart_items.collect {|n| n["item_name"] }.join(";")
  end

  def rewards_class(title)
   "rewards" if title.downcase.include?("reward")
  end

  def loyalty_message_present?
    loyalty_balance_present? || loyalty_earned_present?
  end

  def loyalty_balance_present?
    @confirmation["loyalty_balance_label"].present? && @confirmation["loyalty_balance_message"].present?
  end

  def loyalty_earned_present?
    @confirmation["loyalty_earned_label"].present? && @confirmation["loyalty_earned_message"].present?
  end

  def last_order_title
    if is_a_group_order?
      "Your order has been submited to the Group Order!"
    elsif is_wtjmmj?
      "Thanks! Your reservation has been placed."
    else
      "Thanks! Your order has been placed."
    end
  end

  def place_order_label
    if is_a_group_order?
      "Submit to Group Order"
    elsif is_wtjmmj?
      "Place Reservation"
    else
      "Place order (#{ @total["amount"] })"
    end
  end

  def cc_payment_name(payment)
    if (@checkout["user_info"] && @checkout["user_info"]["last_four"]).present?
      "••••#{ @checkout["user_info"]["last_four"] }"
    else
      payment["name"]
    end
  end

  def promo_applied?
    @checkout && @checkout["promo_amt"].to_f != 0  && @checkout["promo_code"].length > 1 && !@checkout["promo_code"].include?('X_')
  end

  def gift_card_replace_valid?
     @response_gift && @response_gift["id"].present? && @response_gift["user_id"].present? && @response_gift["card_number"].present? && @response_gift["balance"].present?
  end

  def reset_cart_dialog?
    params[:reset_dialog] == "1"
  end

  def data_points(item)
    "data-total-points='#{ item["amount"] }'" if item["title"].downcase == "points used"
  end

  def merchant_redirect_path
    redirect_params = params.slice(*[:order_type, :group_order_token])
    redirect_params[:catering] = "1" if cart_catering_order?
    merchant_path(@merchant.merchant_id,redirect_params)
  end

  def merchant_redirect_path_optional
    params_dict = Hash.new
    params_dict[:id] = @merchant.merchant_id
    params_dict[:order_type] = @order_type
    if cart_catering_order?
      params_dict[:catering] = "1"
    end
    if group_order_token.present?
      params_dict[:group_order_token] = @group_order_token
    end
    merchant_path(params_dict)

  end
end
