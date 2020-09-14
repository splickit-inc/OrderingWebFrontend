require 'exceptions'

class User < BaseModel
  include ActiveModel::Model

  attr_accessor :user_id, :first_name, :last_name, :email, :contact_no, :last_four, :delivery_locations,
                :brand_loyalty, :flags, :balance, :group_order_token, :marketing_email_opt_in, :zipcode,
                :birthday, :privileges, :is_guest, :splickit_authentication_token, :orders

  validates_presence_of :user_id, message: "User could not be created."
  validates_presence_of :email, message: "Email address can't be blank."

  def self.initialize(params = {})
    user = User.new
    user.user_id = params["user_id"]
    user.first_name = params["first_name"]
    user.last_name = params["last_name"]
    user.email = params["email"]
    user.contact_no = params["contact_no"]
    user.last_four = params["last_four"]
    user.delivery_locations = params["delivery_locations"] || []
    user.brand_loyalty = params["brand_loyalty"]
    user.flags = params["flags"]
    user.balance = params["balance"]
    user.group_order_token = params["group_order_token"]
    user.marketing_email_opt_in = params["marketing_email_opt_in"]
    user.zipcode = params["zipcode"]
    user.birthday = params["birthday"]
    user.privileges = params["privileges"]
    user.splickit_authentication_token = params["splickit_authentication_token"]
    user
  end

  def to_param
    user_id
  end

  def loyal?
    !@brand_loyalty.nil?
  end

  def has_points?
    @brand_loyalty && @brand_loyalty["points"].to_i > 0
  end

  def has_cc?
    @flags && @flags.index("1C") == 0
  end

  def is_guest?
    @flags && @flags[8] == "2"
  end

  def see_inactive_merchants?
    if privileges.present? && privileges["see_inactive_merchants"].present?
      privileges["see_inactive_merchants"]
    else
      false
    end
  end

  def full_name
    if first_name.blank? && last_name.blank?
      email
    else
      [first_name, last_name].compact.join ' '
    end
  end

  def self.authenticate(params_hash)
    begin
      if params_hash["remember"].present?
        user = User.initialize(parse_response(response = API.get("/usersession?remember_me=1", params_hash)))
      else
        user = User.initialize(parse_response(response = API.get("/usersession", params_hash)))
      end

      if user.splickit_authentication_token.present?
        user
      else
        error = APIError.new("Something went wrong, please try again.")
        parsed_response = JSON.parse(response.body)
        Airbrake.notify_sync(error, error_message: "Auth Token Missing! STAMP: #{ parsed_response["stamp"] } - USER ID: #{ parsed_response["data"]["user_id"] }")
        raise error
      end
    rescue JSON::JSONError => error
      Rails.logger.error "Error parsing response on user authentication with params #{ params_hash.inspect }"
      Rails.logger.error error.message.inspect
      Rails.logger.error error.backtrace.inspect
      Airbrake.notify_sync(error, error_message: "Error parsing response on user authentication",
                           parameters: {params: params_hash.inspect})
      raise APIError.new("Something went wrong, please try again.")
    end
  end

  #Makes an API call to users/:id/orders_history to retrieve user's orders limited by page
  def orders(auth_token, page)
    orders_response = User.orders(user_id, {user_auth_token: auth_token, page: page})
    if orders_response["orders"].present? && orders_response["orders"].is_a?(Array)
      orders_response["orders"].each do |order|
        order["merchant"] = Merchant.new(order["merchant"])
      end
      {orders: orders_response["orders"], count: orders_response["totalOrders"]}
    else
      {orders: [], count: 0}
    end
  end

  def add_gift_card(card_number,credentials)
    data = {'card_number' => card_number}
    response = API.post("/users/"+user_id+"/stored_value/12000/add", data.to_json, credentials)
    JSON.parse(response.body)
  end

  def self.add_gift_card(card_number, user_id, credentials)
    data = {'card_number' => card_number}
    parse_response(API.post("/users/"+user_id+"/stored_value/12000/add", data.to_json, credentials))
  end

  def group_order_organizer?(token)
    group_order_token == token if token.present?
  end

  def group_order_invitee?(token)
    group_order_token != token if token.present?
  end

  def self.create(attributes)
    raise APIError.new("Phone number can't be blank.") if attributes.stringify_keys["contact_no"].blank?
    unless attributes['birthday'].blank?
      birthday = check_valid_birthday(attributes.stringify_keys['birthday']).strftime("%m/%d/%Y")
      attributes['birthday'] = birthday
    end
    User.initialize(parse_response(API.post("/users", attributes.to_json, {use_admin: true})))
  end

  def self.check_valid_birthday(birthday)
    begin
      format_str = "%m/%d/" + (birthday =~ /\d{4}/ ? "%Y" : "%y")
      birthday = Date.parse(birthday) rescue Date.strptime(birthday, format_str)
    rescue
      raise APIError.new("Please enter a valid birthday format as MM/DD/YYYY.")
    end
    begin
      years_old = years_between_dates birthday, DateTime.now.to_date
      if years_old < 13
        raise
      end
    rescue
      raise APIError.new("Sorry, you must be at least 13 years old to use this site.")
    end
    return birthday
  end

  def self.years_between_dates(date_from, date_to)
    ((date_to.to_time - date_from.to_time) / 1.year.seconds).floor
  end

  def self.find(id, auth_token)
    begin
      User.initialize(parse_response(API.get("/users/#{ id }", {user_auth_token: auth_token})))
    rescue APIError => e
      if e.data[:status] == 401
        return nil
      else
        raise e
      end
    end
  end

  def self.store_address(address_data, user_data)
    response = API.post("/setuserdelivery",
                        {
                            :business_name => address_data[:business_name],
                            :address1 => address_data[:address1],
                            :address2 => address_data[:address2],
                            :city => address_data[:city],
                            :state => address_data[:state],
                            :zip => address_data[:zip],
                            :phone_no => address_data[:phone_no],
                            :instructions => address_data[:instructions]
                        }.to_json,
                        {
                            :base_path => "/app2/phone", # this is API V1
                            :user_auth_token => user_data[:user_auth_token]
                        }
    )

    parsed_response = JSON.parse(response.body)

    if parsed_response['ERROR']
      raise APIError.new parsed_response['ERROR']
    else
      parsed_response
    end
    # API V2
    # parse_response(API.post("/users/#{ id }/userdeliverylocation", address_data.to_json, auth_token))
  end

  def self.delete_address (id, user_addr_id, auth_token)
    parse_response(API.delete("/users/#{ id }/userdeliverylocation/#{ user_addr_id }", {user_auth_token: auth_token}))
  end

  def self.delete_credit_card (user_id, auth_token)
    parse_response(API.delete("/users/#{ user_id }/credit_card", auth_token))
  end

  def self.update(attributes, id, auth_token)
    if attributes[:password].present? && (attributes[:password] != attributes[:password_confirmation])
      raise PasswordMismatch.new "Password confirmation does not match."
    else
      User.initialize(parse_response(API.post "/users/#{ id }", remove_blank_password(attributes).to_json, {user_auth_token: auth_token}))
    end
  end

  def self.transaction_history(id, auth_token)
    parse_response(API.get("/users/#{ id }/loyalty_history?format=v2", {user_auth_token: auth_token}))
  end

  private

  def self.remove_blank_password params
    params.delete(:password) if params[:password].blank?
    params.delete(:password_confirmation) if params[:password_confirmation].blank?
    params
  end

  def self.orders(user_id, attributes = {})
    parse_response(API.get("/users/#{ user_id }/orderhistory?page=#{ attributes[:page] }", attributes))
  end
end
