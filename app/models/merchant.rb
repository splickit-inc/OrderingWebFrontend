class Merchant < BaseModel
  attr_accessor :merchant_id, :brand_id, :brand, :moved_to_merchant_id, :lat, :lng, :name, :display_name, :address1,
                :address2, :city, :state, :zip, :phone_no, :delivery, :distance, :description, :menu, :modifier_groups,
                :trans_fee_rate, :delivery_cost, :accepts_credit, :accepts_cash, :time_zone_offset, :group_ordering_on,
                :show_tip, :menu_key, :user_message, :user_favorites, :message, :group_order_available_lead_times,
                :readable_hours, :nutrition_flag, :nutrition_message, :has_catering, :show_pickup_button, :show_delivery_button,
                :force_catering, :catering_info,
                :favorite_img, :favorite_img_small, :last_order_img,
                :last_order_img_small,
                :catering_info

  private

  attr_accessor :user_favorites_param, :menu_param, :user_last_orders_param, :time_zone_string

  public
  class Integer
    def to_b?
      !self.zero?
    end
  end

  def initialize(params = {})
    self.merchant_id = params["merchant_id"]
    self.brand_id = params["brand_id"]
    self.brand = params["brand"]
    self.moved_to_merchant_id = params["moved_to_merchant_id"]
    self.lat = params["lat"]
    self.lng = params["lng"]
    self.name = params["name"]
    self.display_name = params["display_name"]
    self.address1 = params["address1"]
    self.address2 = params["address2"]
    self.city = params["city"]
    self.state = params["state"]
    self.zip = params["zip"]
    self.phone_no = format_phone(params["phone_no"])
    self.delivery = params["delivery"]
    self.readable_hours = params["readable_hours"]
    self.distance = params["distance"]
    self.description = params["description"]
    self.menu_param = params["menu"]
    self.modifier_groups = params["modifier_groups"]
    self.trans_fee_rate = params["trans_fee_rate"]
    self.delivery_cost = params["delivery_cost"]
    self.time_zone_string = params["time_zone_string"]
    self.time_zone_offset = params["time_zone_offset"] || 0
    self.group_ordering_on = params["group_ordering_on"].to_s == "1"
    self.has_catering = params["has_catering"].to_s == "1" || params["has_catering"].to_s == "true"
    self.force_catering = params["force_catering"].to_s == "1" || params["has_catering"].to_s == "true"
    self.show_tip = set_show_tip(params["show_tip"])
    self.menu_key = params["menu_key"]
    self.user_message = params["user_message"]
    self.user_favorites_param = params["user_favorites"]
    self.user_last_orders_param = params["user_last_orders"]
    self.message = params["message"]
    self.nutrition_flag = params["nutrition_flag"]
    self.nutrition_message = params["nutrition_message"]
    self.show_delivery_button = params["show_delivery_button"].to_b
    self.show_pickup_button = params["show_pickup_button"].to_b
    if (params["has_catering"].to_s == "1" || params["has_catering"].to_s == "true") && params["catering_info"].present?
      self.catering_info = params["catering_info"];
    end

    if params["payment_types"]
      self.accepts_credit = params["payment_types"].include?("creditcard")
      self.accepts_cash = params["payment_types"].include?("cash")
    end
    self.favorite_img = params["favorite_img_2x"]
    self.favorite_img_small = params["favorite_img_small_2x"]
    self.last_order_img = params["last_order_img_2x"]
    self.last_order_img_small = params["last_order_img_small_2x"]
  end

  def self.find(id, delivery = false, credentials = {})
    Merchant.new(fetch_and_cache(id, delivery, credentials))
  end

  def self.info(id, delivery = false, credentials = {})
    Merchant.new(fetch_with_api_call(id, delivery, credentials))
  end

  def self.where(params_hash = {}, credentials)
    params_hash.merge!(limit: 10, minimum_merchant_count: 5, range: 100)

    response = parse_response(API.get("/merchants?#{ params_hash.to_param }", credentials))
    merchants = response['merchants']
    merchants.collect {|merchant| Merchant.new(merchant)}
  end

  def group_order_available_times(group_order_type_selected, order_type = "pickup", credentials = {})
    self.group_order_available_lead_times =
        if group_order_type_selected == GroupOrder::INVITE_PAY
          Merchant.parse_response(API.get("/merchants/#{ self.merchant_id }/grouporderavailabletimes/#{ order_type}", credentials))["submit_times_array"]
        else
          []
        end
  end

  def catering_data(order_type = "pickup", credentials = {})
    Merchant.parse_response(API.get("/merchants/#{ merchant_id }/cateringorderavailabletimes/#{ order_type }", credentials))
  end

  def self.catering_data(merchant_id, order_type = "pickup", credentials = {})
    Merchant.parse_response(API.get("/merchants/#{ merchant_id }/cateringorderavailabletimes/#{ order_type }", credentials))
  end

  def to_param
    merchant_id
  end

  def delivery_fee
    BigDecimal.new(delivery_cost.to_s) if delivery_cost.to_f > 0.00
  end

  def transaction_fee
    BigDecimal.new(trans_fee_rate.to_s) if trans_fee_rate.to_f > 0.00
  end

  def full_name
    if name == display_name
      name
    else
      "#{ name }, #{ display_name }"
    end
  end

  def full_address
    [street_address, city_state_zip].join ', '
  end

  def street_address
    [address1, address2].reject {|part| part.blank?}.join ', '
  end

  def city_state_zip
    [city, "#{ state } #{ zip }"].reject {|part| part.blank?}.join(', ').strip
  end

  def delivers?
    delivery.upcase == "Y"
  end

  def has_pickup?
    show_pickup_button
  end

  def has_delivery?
    show_delivery_button
  end

  def time_zone
    time_zone_string.gsub(/(\(GMT[^(]*\))/, "").strip if time_zone_string.present?
  end

  def menu
    @menu = Menu.initialize(menu_param) if @menu.nil?
    @menu
  end

  def user_favorites
    if @user_favorites.nil?
      @user_favorites =
          if user_favorites_param
            user_favorites_param.collect do |favorite|
              unless favorite.is_a?(String)
                UserFavorite.new(favorite.merge!("menu_items" => self.menu.menu_items))
              end
            end
          else
            []
          end
    end
    @user_favorites
  end

  def user_last_orders
    if @user_last_orders.nil?
      if @user_last_orders_param
        @user_last_orders = @user_last_orders_param.collect do |o|
          unless p.is_a?(String)
            UserLastOrder.new(o.merge({"menu_items" => self.menu.menu_items}))
          end
        end
      else
        @user_last_orders = []
      end
    end
    @user_last_orders
  end

  # TODO: move to service?
  def self.in_delivery_area?(merchant_id, user_addr_id, is_catering, credentials = {})
    if is_catering
      parse_response(API.get("/merchants/#{ merchant_id }/isindeliveryarea/#{ user_addr_id }/catering", credentials))["is_in_delivery_range"]
    else
      parse_response(API.get("/merchants/#{ merchant_id }/isindeliveryarea/#{ user_addr_id }", credentials))["is_in_delivery_range"]
    end
  end

  def as_json options
    self.menu
    self.user_favorites
    super
  end

  private

  def format_phone(phone)
    if phone
      phone = phone.gsub(/\D/, "")
    else
      return ""
    end

    case
    when phone.length == 7
      phone = "#{phone[0..2]}-#{phone[3..phone.length]}"
    when phone.length == 10
      phone = "(#{phone[0..2]}) #{phone[3..5]}-#{phone[6..phone.length]}"
    when phone.length == 11
      phone = "#{phone[0]} (#{phone[1..3]}) #{phone[4..6]}-#{phone[7..phone.length]}"
    end
    phone
  end

  def set_show_tip(show_tip)
    show_tip == "Y" || show_tip == true
  end

  def self.api_endpoint(id, delivery)
    endpoint = "/merchants/#{ id }"
    endpoint = "#{ endpoint }/delivery" if delivery == true
    endpoint = "#{ endpoint }/catering" if delivery == "catering"
    endpoint
  end

  def self.fetch_with_api_call(merchant_id, delivery, credentials)
    merchant = Rails.cache.fetch(api_endpoint(merchant_id, delivery))
    merchant = fetch_and_cache(merchant_id, delivery, credentials) if merchant.nil?
    merchant
  end

  def self.fetch_and_cache(merchant_id, delivery, credentials)
    merchant = parse_response(API.get(api_endpoint(merchant_id, delivery), credentials))
    cached_merchant = merchant.except("menu", "message", "user_favorites", "user_last_orders", "user_message")
    Rails.cache.write(api_endpoint(merchant_id, delivery), cached_merchant, expires_in: 1.hour)
    merchant
  end
end
