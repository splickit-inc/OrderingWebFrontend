module GroupOrdersHelper
  def format_modifiers(modifiers)
    modifiers.map {|m| m["name"].capitalize}.join(", ")
  end

  def has_group_order?
    (session[:current_user] && session[:current_user]["group_order_token"]).present?
  end

  def is_a_group_order?
    (params[:group_order_token] || @group_order_token).present?
  end

  def empty_group_order?
    @group_order["total_submitted_orders"].to_i == 0
  end

  def share_link
    request.protocol + request.host_with_port +
      "/merchants/" + @merchant.merchant_id +
      "?group_order_token=" + @group_order["group_order_token"] +
      "&order_type=" + @group_order["merchant_menu_type"]
  end

  def delivery_business_name
    if @group_order["delivery_address"].present? && @group_order["delivery_address"]["business_name"].present?
      "#{ @group_order["delivery_address"]["business_name"] },"
    else
      ""
    end
  end

  def delivery_street_address
    address = ""
    if !@group_order["delivery_address"].blank?
      address = @group_order["delivery_address"]["address1"]
      address = address + ", #{ @group_order["delivery_address"]["address2"] }" unless @group_order["delivery_address"]["address2"].blank?
    end

    address
  end

  def delivery_city_state_zip
    city_state_zip = ""
    if !@group_order["delivery_address"].blank?
      city_state_zip = "#{ @group_order["delivery_address"]["city"] }, #{ @group_order["delivery_address"]["state"] } #{ @group_order["delivery_address"]["zip"] }"
    end
    city_state_zip
  end

  def group_order_expire_at
    time = Time.at(@group_order["expires_at"].to_i).utc + @merchant.time_zone_offset.hours
    time.strftime("%l:%M %p").strip
  end

  def invite_pay?
    GroupOrder::INVITE_PAY == (@group_order.present? && @group_order["group_order_type"].to_i || session[:group_order].present? && session[:group_order][:type].to_i)
  end

  def organizer_pay?
    !invite_pay?
  end

  def submitted?
    @group_order["status"].upcase == "SUBMITTED" if @group_order["status"].present?
  end

  def place_order_link
    if invite_pay?
      label = "Place Order Now!"
      path = submit_group_order_path(@group_order["group_order_token"])
      method = :post
    else
      label = "Checkout"
      path = new_checkout_path(merchant_id: @group_order["merchant_id"],
                               group_order_token: @group_order["group_order_token"],
                               order_type: @group_order["merchant_menu_type"],
                               submit: true)
    end

    link_to label, path, method: method, class: ["button", "primary"], id: "checkout", disabled: empty_group_order? || submitted?
  end

  def group_order_token
    (params[:group_order_token] || @group_order_token) if is_a_group_order?
  end

  def is_checkout_grouporder?
    session_submit = session[:group_order].present? && session[:group_order][:submit]
    group_submit = @group_order.present? && @group_order["submit"]

    @user.group_order_organizer?(group_order_token) && (params[:submit] || session_submit || group_submit)
  end

  def set_group_order_session(params = {})
    if session[:group_order].blank?
      session[:group_order] = params
    else
      session[:group_order].merge!(params)
    end
  end

  def clear_group_order_data
    session[:order][:meta].delete(:group_order_token) if session[:order] && session[:order][:meta]
    session.delete(:group_order)
  end
end
