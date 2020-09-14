class Order < BaseModel
  def self.submit(params, credentials)
    parse_response(API.post("/orders/#{ params[:cart_ucid] }", params.to_json, credentials))
  end

  ORDER_STATUS = HashWithIndifferentAccess.new(O: "In Process",
                                               E: "Completed",
                                               N: "Cancelled")
end
