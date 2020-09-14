class Skin < BaseModel

  LOYALTY_PROGRAMS = { remote: "remote", earn: "splickit_earn", cliff: "splickit_cliff" }

  attr_accessor :skin_id, :skin_name, :skin_description, :brand_id, :mobile_app_type,
                :external_identifier, :custom_skin_message, :welcome_letter_file, :in_production,
                :web_ordering_active, :donation_active, :donation_organization,
                :facebook_thumbnail_url, :android_marketplace_link, :twitter_handle,
                :iphone_certificate_file_name, :current_iphone_version, :current_android_version,
                :facebook_app_id, :facebook_app_secret, :rules_info, :supports_history,
                :supports_join, :supports_link_card, :lat, :lng, :zip, :loyalty_features,
                :merchants_with_delivery, :iphone_app_link, :http_code, :support_email,
                :support_email_categories, :brand_fields, :rewardr_active, :feedback_url,
                :loyalty_tnc_url, :show_notes_fields, :loyalty_support_phone_number,
                :loyalty_card_management_link, :event_merchant, :map_url

  def self.initialize(params={})
    skin = Skin.new
    skin.skin_id = params["skin_id"]
    skin.skin_name = params["skin_name"]
    skin.skin_description = params["skin_description"]
    skin.brand_id = params["brand_id"]
    skin.mobile_app_type = params["mobile_app_type"]
    skin.external_identifier = params["external_identifier"]
    skin.custom_skin_message = params["custom_skin_message"]
    skin.welcome_letter_file = params["welcome_letter_file"]
    skin.in_production = params["in_production"]
    skin.web_ordering_active = params["web_ordering_active"]
    skin.donation_active = params["donation_active"]
    skin.donation_organization = params["donation_organization"]
    skin.facebook_thumbnail_url = params["facebook_thumbnail_url"]
    skin.android_marketplace_link = params["android_marketplace_link"]
    skin.twitter_handle = params["twitter_handle"]
    skin.iphone_certificate_file_name = params["iphone_certificate_file_name"]
    skin.current_iphone_version = params["current_iphone_version"]
    skin.current_android_version = params["current_android_version"]
    skin.facebook_app_id = params["facebook_app_id"]
    skin.facebook_app_secret = params["facebook_app_secret"]
    skin.rules_info = params["rules_info"]
    skin.supports_history = params["supports_history"]
    skin.supports_join = params["supports_join"]
    skin.supports_link_card = params["supports_link_card"]
    skin.lat = params["lat"]
    skin.lng = params["lng"]
    skin.zip = params["zip"]
    skin.loyalty_features = params["loyalty_features"] || {}
    skin.merchants_with_delivery = params["merchants_with_delivery"]
    skin.iphone_app_link = params["iphone_app_link"]
    skin.http_code = params["http_code"]
    skin.support_email = params["support_email"]
    skin.support_email_categories = params["support_email_categories"]
    skin.brand_fields = params["brand_fields"]
    skin.rewardr_active = params["rewardr_active"]
    skin.feedback_url = params["feedback_url"]
    skin.loyalty_tnc_url = params["loyalty_tnc_url"]
    skin.loyalty_support_phone_number = params["loyalty_support_phone_number"]
    skin.show_notes_fields = params["show_notes_fields"].nil? ? true : params["show_notes_fields"]
    skin.loyalty_card_management_link = params["loyalty_card_management_link"] || "http://www.mypitapitcard.com"
    skin.event_merchant = params["event_merchant"].to_s == "1"
    skin.map_url = params["map_url"]
    skin
  end

  def self.where(params_hash)
    begin
      skin_params = fetch_with_api_call(params_hash[:skin_identifier])
    rescue APIError => e
      Rails.logger.error("Skin APIError #{e.message}")
    end

    if skin_params.present? && skin_params.is_a?(Hash)
      Skin.initialize(skin_params)
    else
      Skin.new
    end
  end

  def self.current_name
    RequestStore.store[:skin_name]
  end

  def self.current_name= skin
    RequestStore.store[:skin_name] = skin
  end

  def apple_store_id
    if self.iphone_app_link.present?
      link = self.iphone_app_link.match(/\d{2,}/)
      link[0] if link
    end
  end

  def android_marketplace_id
    if self.android_marketplace_link.present?
      link = self.android_marketplace_link.match(/com.splickit(.)+$/)
      link[0] if link
    end
  end

  def brand_custom_fields
    brand_fields.reject { |field| field["field_name"] == "marketing_email_opt_in" } if brand_fields.present?
  end

  def email_marketing_field
    brand_fields.find { |field| field["field_name"] == "marketing_email_opt_in" } if brand_fields.present?
  end

  def loyalty_type_labels
    return [{ "label" => "Points balance", "type" => "points" }] unless loyalty_features["loyalty_labels"]
    loyalty_features["loyalty_labels"]
  end

  def loyalty_supports_pin?
    unless self.loyalty_features["supports_pin"].nil?
      self.loyalty_features["supports_pin"]
    else
      true
    end
  end

  def loyalty_supports_phone_number?
    self.loyalty_features["supports_phone_number"] == true
  end

  def loyalty_supports_join?
    unless self.loyalty_features["supports_join"].nil?
      self.loyalty_features["supports_join"]
    else
      true
    end
  end

  def third_party_loyalty?
    (loyalty_features["loyalty_type"] || "").downcase == LOYALTY_PROGRAMS[:remote]
  end

  def splickit_loyalty?
    !third_party_loyalty?
  end

  def earn_loyalty?
    (loyalty_features["loyalty_type"] || "").downcase == LOYALTY_PROGRAMS[:earn]
  end

  def is_moes?
    (skin_name || "").downcase == "moes"
  end

  def is_goodcents?
    (skin_name || "").downcase == "goodcents subs"
  end

  def is_hollywoodbowl?
    (skin_name || "").downcase == "hollywood bowl"
  end

  def script_for_google_tag_manager
    case self.skin_name
      when "Goodcents Subs" then "goodcentssubs"
      else "splickitinc"
    end
  end

  private

  def self.fetch_with_api_call(skin_identifier)
    skin_path = "/skins/com.splickit.#{skin_identifier}"
    skin = Rails.cache.fetch(skin_path)
    if skin.nil?
      skin = parse_response(API.get(skin_path))
      Rails.cache.write(skin_path, skin, expires_in: 20.minutes)
    end
    skin
  end

  def self.skin_cache_key(skin_identifier)
    "get_skin_#{skin_identifier}"
  end
end
