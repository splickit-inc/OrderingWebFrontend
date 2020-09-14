class MenuItem < BaseModel
  attr_accessor :item_id, :item_name, :menu_type_id, :size_prices, :description,
                :modifier_groups, :points, :photos, :brand_points_id, :calories,
                :large_image, :small_image, :point_range, :price_range, :note

  def self.initialize(params = {})
    menu_item = MenuItem.new
    menu_item.item_id = params["item_id"]
    menu_item.menu_type_id = params["menu_type_id"]
    menu_item.item_name = params["item_name"]
    menu_item.size_prices = self.enabled_active_size_price(params["size_prices"])
    menu_item.description = params["description"]
    menu_item.modifier_groups = params["modifier_groups"].collect { |p| ModifierGroup.initialize(p) } if params["modifier_groups"]
    menu_item.points = params["points"]
    menu_item.photos = params["photos"]
    menu_item.brand_points_id = params["brand_points_id"]
    menu_item.calories = params["calories"]
    menu_item.large_image = self.large_image_url(menu_item.photos)
    menu_item.small_image = self.small_image_url(menu_item.photos, 2)
    menu_item.price_range = self.format_price_range(menu_item.size_prices)
    menu_item.point_range = self.format_point_range(menu_item.size_prices)
    menu_item
  end

  def description
    @description.gsub(/[\n\r]*/, "")
  end

  def get_brand_points_id(size_id)
    size_prices.each do |size_price|
      return size_price["brand_points_id"] if size_price["size_id"] == size_id
    end
    nil
  end

  def sort_size_prices
    size_prices.sort_by! { |size_price| size_price["priority"].to_i }.reverse! if size_prices
  end

  def enable_size_price(size_id = nil)
    if size_prices
      if size_id && size_prices.any? { |size_price| size_price["size_id"].to_s == size_id.to_s }
        size_prices.each { |size_price| size_price["enabled"] = size_price["size_id"].to_s == size_id.to_s }
      else
        size_prices.first["enabled"] = true
      end
    end
  end

  private

  def self.large_image_url(photos)
    if photos
      photo = photos.find { |photo| photo["height"].to_i >= 420 && photo["width"].to_i >= 640 }

      photo["url"] if photo
    end
  end

  def self.small_image_url(photos, scale = 1)
    if photos
      photo = photos.find { |photo|
        photo["height"].to_i <= 158 && photo["width"].to_i <= 158 && photo["url"].include?("/#{ scale }x/")
      }

      photo["url"] if photo
    end
  end

  def self.format_point_range(size_prices)
    size_prices.map { |size| size["points"] }.compact if size_prices.present?
  end

  def self.format_price_range(size_prices)
    size_prices.map { |size| size["price"] }.compact if size_prices.present?
  end

  def self.enabled_active_size_price(size_prices)
    if size_prices.present?
      sps = size_prices.sort_by { |size_price| size_price["priority"].to_i }.reverse
      sps.each_with_index { |size_price, i| size_price["enabled"] = i == 0 }
    end
  end

  def self.nutrition_information(item_id, size_id,credentials)
    parse_response(API.get("/items/#{ item_id }?size_id=#{ size_id }", credentials))
  end
end
