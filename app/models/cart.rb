class Cart < BaseModel
  attr_accessor :cash_pid, :credit_pid, :loyalty_pid

  def self.create(params, credentials)
    parse_response(API.post("/cart", params.to_json, credentials))
  end

  def self.update(id, params, credentials)
    parse_response(API.post("/cart/#{id}", params.to_json, credentials))
  end

  def self.find(id, credentials)
    parse_response(API.get("/cart/#{id}", credentials))
  end

  def self.get_checkout(id, params)
    parse_response(API.get("/cart/#{ id }/checkout", params))
  end

  def self.promo(id, params)
    parse_response(API.get("/cart/#{ id }/checkout?promo_code=#{ params[:promo_code] }", params))
  end

  def self.checkout(id, params, credentials)
    if id.present?
      parse_response(API.post("/cart/#{ id }/checkout", params.to_json, credentials))
    else
      parse_response(API.post("/cart/checkout", params.to_json, credentials))
    end
  end
end
