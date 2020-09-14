require 'exceptions'

class CheckoutsController < ApplicationController
  include CheckoutsHelper, CartsHelper, GroupOrdersHelper

  before_action :require_login, except: [:update, :empty_cart]
  before_action :verify_items_exist, only: [:new]
  before_action :last_order_exists?, only: [:show]
  before_action :check_cookie_order_detail, only: [:new]

  def new
    begin
      get_secure_form_data

      cart_id = session[:order][:cart_id] if order_exists?

      cart_id = group_order_token if is_checkout_grouporder?

      @cart = Cart.update(cart_id, cart_params, current_user_auth_token_hash)

      update_cart_session

      @checkout = Cart.get_checkout(@cart["ucid"], current_user_auth_token_hash)

      update_checkout_items
      update_user_data
      set_default_tip

      set_group_order_session(submit: true) if is_checkout_grouporder?
      @carMake = populateCarMake
      @carColor = populateCarColor
      @items = @checkout["order_summary"]["cart_items"]

      set_order_receipt

      if order_exists? && session[:order][:meta][:catering].present?
        @merchant = Merchant.info(params[:merchant_id], 'catering', current_user_auth_token_hash)
      else
        @merchant = Merchant.info(params[:merchant_id], delivery?, current_user_auth_token_hash)
      end

      if @checkout["lead_times_by_day_array"].present?
        @options_for_day_select = @checkout["lead_times_by_day_array"].keys
        initialize_time_data()
        @options_for_time_select = time_options_for_select(@checkout["lead_times_by_day_array"][@day_stored], @merchant.time_zone_offset.to_i, true)

        session[:lead_day_array] = @checkout["lead_times_by_day_array"];
        session[:time_zone] = @merchant.time_zone_offset.to_i;
      elsif @checkout["lead_times_array"].present?
        @options_for_time_select = time_options_for_select(@checkout["lead_times_array"], @merchant.time_zone_offset.to_i)
      end

      @options_for_tip_select = format_tips(@checkout["tip_array"])
      is_dine_option
      is_curbside_option
      assign_checkout_detail_data

      @delivery_address = user_delivery_address(delivery_address_id) if delivery?

      set_payment_options
      @gift_card_balance = get_gift_card_balance
      @last_four = get_gift_last_four

      flash.now[:notice] = @checkout["message"] if @checkout && @checkout["message"].present?
    rescue APIError => e
      if @user.group_order_organizer?(group_order_token)
        redirect_to group_order_path(group_order_token), flash: {error: e.message}
      else
        redirect_params = params.slice(*[:order_type, :group_order_token]).permit!
        redirect_params[:catering] = "1" if cart_catering_order?
        redirect_to merchant_path(params[:merchant_id], redirect_params), flash: {error: e.message}
      end
    rescue PromoError => e
      redirect_to new_checkout_path(params), flash: {error: e.message}
    rescue GroupOrderError => e
      clear_group_order_data
      reset_cart_id
      reset_items_for_new_order
      if delivery?
        redirect_to root_path, flash: {error: "Please select a valid delivery address."}
      else
        redirect_to new_checkout_path(merchant_id: params[:merchant_id], reset_dialog: "1",
                                      order_type: order_type), flash: {error: e.message}
      end
    end
  end

  def populateCarMake
    cars = ["Acura", "Alfa Romeo", "Audi", "BMW", "Buick","Cadillac", "Chevrolet", "Chrysler", "Dodge", "Fiat", "Ford", "GMC", "Genesis",
    "Honda", "Hyundai", "Infiniti", "Jaguar", "Jeep", "Kia", "Land Rover", "Lexus", "Lincoln", "Mazda", "Mercedes-Benz", "Mini",
    "Mitsubishi", "Nissan", "Porsche", "Ram", "Saab", "Smart", "Subaru", "Tesla", "Toyota", "Volkswagen", "Volvo", "Other"]
    return cars
  end

  def populateCarColor
    colors = ["Black", "White","Gray","Silver", "Blue", "Brown", "Green", "Gold", "Red"]
    return colors
  end

  def is_dine_option
    if (@checkout["allows_dine_in_orders"] && order_type.downcase == "pickup")
      @show_dine_option = true
    else
      @show_dine_option = false
    end
  end

  def is_curbside_option
    if (@checkout["allows_curbside_pickup"] && order_type.downcase == "pickup")
      @show_curbside_option = true
    else
      @show_curbside_option = false
    end
  end

  def get_times_by_day
    day_selected = params[:day]

    @options_for_time_select = time_options_for_select(session[:lead_day_array][day_selected], session[:time_zone], true)
    respond_to do |format|
      if @options_for_time_select != nil
        format.js {}
        format.json { render json: @options_for_time_select }
      else
        format.html { render action: 'index' }
        format.json { render json @options_for_time_select, status: :unprocessable_entity }
      end
    end

  end

  def apply_promo
    begin
      cart_id = session[:order][:cart_id] if order_exists?

      if cart_id
        @checkout = Cart.promo(cart_id, {user_auth_token: @user.splickit_authentication_token,
                                         promo_code: params[:promo_code]})

        @options_for_tip_select = format_tips(@checkout["tip_array"])

        set_order_receipt

        set_payment_options

        flash.now[:notice] = @checkout["message"] if @checkout && @checkout["message"].present?
      else
        flash[:error] = "We're sorry, we have a problem with the promo code. Try again"
        render js: "window.location = '#{ new_checkout_path(merchant_id: params[:merchant_id],
                                                            order_type: params[:order_type],
                                                            group_order_token: group_order_token) }'"
      end
    rescue APIError, PromoError => e
      flash.now[:error] = e.message
    end
  end

  def create
    begin
      @group_order_token = params[:order][:group_order_token]

      if order_exists? && session[:order][:meta][:catering].present?
        merchant = Merchant.info(params[:order][:merchant_id], 'catering', current_user_auth_token_hash)
      else
        merchant = Merchant.info(params[:order][:merchant_id], delivery?, current_user_auth_token_hash)
      end

      validate_order_params(merchant)

      if params[:show_curbside_option]
        validate_CarData
      end


      if is_wtjmmj?
        order_data = {user_id: current_user_id,
                      cart_ucid: params[:order][:cart_id],
                      tip: params[:tip],
                      note: params[:note],
                      merchant_payment_type_map_id: "7060",
                      requested_time: params[:time]}
      else
        order_data = {user_id: current_user_id,
                      cart_ucid: params[:order][:cart_id],
                      tip: params[:tip],
                      note: params[:note],
                      merchant_payment_type_map_id: params[:payment_type],
                      requested_time: params[:time]}
      end

      if delivery?
        order_data[:delivery_time] = formatted_delivery_time(params[:time], merchant.time_zone_offset.to_i)
      end

      if params[:show_dine_option]
        if params[:dine_in].present? && params[:dine_in].eql?('dine_in')
          order_data[:dine_in] = true
        end
      end

      if params[:show_curbside_option]
        if params[:curbside].present? && params[:curbside].eql?('curbside')
          order_data[:curbside_pickup] = true
          order_data[:car_make] = params[:make]
          order_data[:car_color] = params[:color]
        end
      end

      # TODO: make params consistent w/ API requirements; avoid mapping
      confirmation = Order.submit(order_data, current_user_auth_token_hash)

      # does not implemented catering ? check how to retrieve last order
      if order_exists? && session[:order][:meta][:catering].present?
        session[:last_order] = {order_type: order_type,
                                catering: true,
                                order: params[:order],
                                group_order: session[:group_order],
                                confirmation: confirmation}
      else
        session[:last_order] = {order_type: order_type,
                                order: params[:order],
                                group_order: session[:group_order],
                                confirmation: confirmation}
      end

      clear_order!
      delete_checkout_detail_data

      set_user_instance(true)

      redirect_to last_order_path
    rescue MissingTip, APIError => e
      red_params = is_a_group_order? ? {group_order_token: params[:order][:group_order_token]} : {}
      if session[:order].present? || is_checkout_grouporder?
        red_params.merge!(merchant_id: params[:order][:merchant_id], order_type: order_type)
        redirect_to new_checkout_path(red_params), flash: {error: e.message}
      else
        red_params.merge!(order_type: order_type)
        redirect_to merchant_path(params[:order][:merchant_id], red_params), flash: {error: e.message}
      end
    rescue MissingCarData, APIError => e
      red_params = is_a_group_order? ? {group_order_token: params[:order][:group_order_token]} : {}
      if session[:order].present? || is_checkout_grouporder?
        red_params.merge!(merchant_id: params[:order][:merchant_id], order_type: order_type)
        redirect_to new_checkout_path(red_params), flash: {error: e.message}
      else
        red_params.merge!(order_type: order_type)
        redirect_to merchant_path(params[:order][:merchant_id], red_params), flash: {error: e.message}
      end
    rescue GroupOrderError => e
      clear_group_order_data
      reset_cart_id
      reset_items_for_new_order
      if delivery?
        redirect_to root_path, flash: {error: "Please select a valid delivery address."}
      else
        redirect_to new_checkout_path(merchant_id: params[:order][:merchant_id], reset_dialog: "1",
                                      order_type: order_type), flash: {error: e.message}
      end
    end
  end

  def show
    session.delete(:current_user) if @user.is_guest?

    @order_type = session[:last_order][:order_type]
    @group_order_token = session[:last_order][:order][:group_order_token]
    @group_order = {"group_order_type" => session[:last_order][:group_order][:type],
                    "submit" => session[:last_order][:group_order][:submit]} if is_a_group_order?
    @confirmation = session[:last_order][:confirmation]

    if session[:last_order][:catering].present?
      @merchant = Merchant.info(session[:last_order][:order][:merchant_id],
                                'catering',
                                current_user_auth_token_hash)
    else
      @merchant = Merchant.info(session[:last_order][:order][:merchant_id],
                                delivery?(@order_type),
                                current_user_auth_token_hash)
    end

    if delivery?(@order_type) && @confirmation["user_delivery_address"].present?
      @delivery_address = @confirmation["user_delivery_address"]
    end

    @payment_items = @confirmation["order_summary"]["payment_items"] || []

    set_order_receipt

    @user_favorite = UserFavorite.new("order_id" => session[:last_order][:confirmation]["order_id"])
  end

  def empty_cart
    @add_more_items_href =
        if params[:merchant_id].present? && params[:order_type].present?
          redirect_params = params.slice(*[:order_type, :group_order_token]).permit!
          redirect_params[:catering] = "1" if cart_catering_order?
          merchant_path(params[:merchant_id], redirect_params)
        else
          root_path
        end
  end

  private

  def update_user_data
    return unless (@checkout["user_info"] && @checkout["user_info"]["user_has_cc"]).present?
    update_current_user(flags: "1C#{ @user.flags[2..@user.flags.length] }", last_four: @checkout["user_info"]["last_four"])
  end

  def set_payment_options
    @credit_payments = []
    @loyalty_payments = []
    @cash_payments = []
    @other_payments = []
    @gift_payments = []

    # TODO: move business logic to model!
    if @checkout["accepted_payment_types"]
      @checkout["accepted_payment_types"].each do |type|
        case type["splickit_accepted_payment_type_id"]
        when "1000" then
          @cash_payments << type
        when "2000" then
          @credit_payments << type
        when "3000", "7000", "8000", "8001", "9000" then
          @loyalty_payments << type
        when "12000" then
          @gift_payments << type
        else
          @other_payments << type
        end if type.present?
      end
    end
  end

  def has_gift_card?
    (@checkout["user_info"] && @checkout["user_info"]["stored_value_card_number"] && @checkout["user_info"]["stored_value_card_balance"]).present?
  end

  def get_gift_card_balance
    return @checkout["user_info"]["stored_value_card_balance"] if has_gift_card?
  end

  def get_gift_last_four
    if has_gift_card?
      card_number = @checkout["user_info"]["stored_value_card_number"]
      return card_number.chars.last(4).join
    end
  end

  def update_cart_session
    set_cart_id(@cart["ucid"])
    if @cart["order_summary"].present? && @cart["order_summary"]["order_data_as_ids_for_cart_update"].present?
      items = @cart["order_summary"]["order_data_as_ids_for_cart_update"]["items"]
      saved_item_ids =
          items.map do |item|
            update_item({"uuid" => item["external_detail_id"]}, {"status" => item["status"], "order_detail_id" => item["order_detail_id"]})
            item["order_detail_id"].to_s
          end

      session[:order][:items].each do |item|
        session[:order][:items].delete(item) unless saved_item_ids.include?(item["order_detail_id"].to_s)
      end if order_exists?
    end
  end

  def update_checkout_items
    if (@checkout["order_summary"] && @checkout["order_summary"]["cart_items"]).present? && !is_checkout_grouporder?
      @checkout["order_summary"]["cart_items"].each do |item|
        found_item = find_item("order_detail_id" => item["order_detail_id"]) if item["order_detail_id"].present?
        item["uuid"] = found_item["uuid"] if found_item.present?
      end
    end
  end

  def set_order_receipt
    data = @checkout || @confirmation
    @total = data["order_summary"]["receipt_items"].find {|item| item["title"].downcase == "total"}
    @order_receipt = data["order_summary"]["receipt_items"].reject {|item| item["title"].downcase == "total"}
  end

  def last_order_exists?
    redirect_to(root_path, flash: {error: "That cart is no longer active."}) if session[:last_order].blank?
  end

  def delivery_address_id
    if cookies[:userPrefs]
      JSON.parse(cookies[:userPrefs])["preferredAddressId"]
    elsif @checkout.present? && @checkout["user_delivery_location_id"].present?
      delivery_id = @checkout.present? && @checkout["user_delivery_location_id"]
      cookies[:userPrefs] = {preferredAddressId: delivery_id.to_s}.to_json
      delivery_id
    end
  end

  def user_delivery_address(id)
    @user.delivery_locations.select {|delivery_location| delivery_location["user_addr_id"] == id}.first
  end

  def order_delivery_address_id
    delivery_address_id if delivery?
  end

  def clear_order!
    if is_a_group_order?
      Rails.logger.info "We have a group order"
      set_current_group_order_token(nil) if organizer_pay? && is_checkout_grouporder?
      session.delete(:group_order)
    end

    reset_cart!
  end

  def formatted_delivery_time(time, offset)
    time_val = Time.at(Integer(time))

    date_format = time_val.yday == Time.now.in_time_zone(offset).yday ? "%l:%M %p" : "%a %m-%d %I:%M %p"

    (Time.at(time_val).utc + offset.hours).strftime(date_format)
  rescue
    time
  end

  def cart_params
    item_params = {user_id: current_user_id,
                   merchant_id: params[:merchant_id],
                   submitted_order_type: order_type,
                   group_order_token: params[:group_order_token],
                   user_addr_id: order_delivery_address_id}

    total_points_used = 0

    item_params[:items] = session[:order][:items].map do |item|
      total_points_used += item["points_used"].to_i if item["status"] == "new"
      {item_id: item["item_id"],
       external_detail_id: item["uuid"],
       quantity: item["quantity"],
       mods: item["mods"],
       size_id: item["size_id"],
       status: item["status"],
       order_detail_id: item["order_detail_id"],
       points_used: item["points_used"],
       brand_points_id: item["brand_points_id"],
       note: item["note"]}
    end if order_exists?

    item_params[:total_points_used] = total_points_used
    item_params
  end

  def build_order_receipt(receipt_items)
    receipt_items.map {|k|
      Hash[k["title"].downcase.gsub(' ', '_').to_sym, k["amount"].gsub('$', '')]
    }.reduce({}, :merge)
  end

  def require_login
    redirect_to sign_in_path(continue: request.fullpath) unless signed_in?
  end

  def verify_items_exist
    redirect_to empty_cart_path(cleanup_params_for_redirect) if (session[:order].blank? || get_items.blank?) && !is_checkout_grouporder?
  end

  def format_currency(amt)
    "%.2f" % amt.to_f
  end

  def validate_order_params(merchant)
    unless cash_order? || !merchant.show_tip || (is_a_group_order? && organizer_pay? && !session[:group_order][:submit])
      raise MissingTip.new("Please select a tip amount") if params[:tip].blank?
    end
  end
  def validate_CarData()
    if params[:curbside].present? && params[:curbside].eql?('curbside')
      raise MissingCarData.new("Please select a Car Make and Color") if params[:color].blank? || params[:make].blank?
    end
  end

  def cash_order?
    payment_types = JSON.parse(params["payment_types_map"])
    payment = payment_types.find {|type| type["merchant_payment_type_map_id"] == params[:payment_type]}
    payment["splickit_accepted_payment_type_id"] == "1000" || payment["splickit_accepted_payment_type_id"] == "9000" if payment.present?
  end

  def initialize_time_data
      @day_stored = @options_for_day_select[0]
      @day_stored = @day_value if @options_for_day_select.include?(@day_value)
  end

  def assign_checkout_detail_data


    if @options_for_time_select.present?
      text_flag = false
      time_selected = @options_for_time_select.find do |option|
        Time.at(@time_value.to_i) rescue text_flag = true
        Time.at(option.last.to_i) >= Time.at(@time_value.to_i) rescue option.first.to_i == @time_value.to_i
      end

      time_selected = @options_for_time_select.last if time_selected.blank? && !text_flag

      @time = time_selected[1] if time_selected.present?
    end

    tip_selected = @options_for_tip_select.find {|option| option.first == @tip} if @options_for_tip_select.present?
    @tip = tip_selected.last if tip_selected.present?
  end

  def check_cookie_order_detail
    cookie = cookies[:orderDetail] if cookies[:orderDetail].present?
    if cookie
      cookie_data = JSON.parse(cookie)
      @tip = cookie_data['tip'] if cookie_data['tip'].present?
      @day_value = cookie_data['day'] if cookie_data['day'].present?
      @time_value = cookie_data['time'] if cookie_data['time'].present?
      @note = cookie_data['note'] if cookie_data['note'].present?
      @dine_in_checked = cookie_data['dine_in'] if cookie_data['dine_in'].present?
      @curbside_checked = cookie_data['curbside'] if cookie_data['curbside'].present?
      @make = cookie_data['make'] if cookie_data['make'].present?
      @color = cookie_data['color'] if cookie_data['color'].present?
      @payment = cookie_data['payment'] if cookie_data['payment'].present?
    end
  end

  def set_default_tip
    if @checkout['pre_selected_tip_value'].present? && @checkout['pre_selected_tip_value'] != '%'
      @tip = @checkout['pre_selected_tip_value'] unless @tip.present?
    end
  end

  def set_cookie_order_detail(params = {})
    cookie_data = cookies[:orderDetail] ? JSON.parse(cookies[:orderDetail]) : {}
    cookie_data.merge!(params)
    cookies[:orderDetail] = cookie_data.to_json
  end

  def cleanup_params_for_redirect
    params.permit(:merchant_id, :order_type, :group_order_token)
  end
end