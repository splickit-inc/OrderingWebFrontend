class GroupOrder < BaseModel
  attr_accessor :participant_emails, :notes, :merchant_menu_type, :merchant_id, :items, :status, :user_addr_id,
                :group_order_type, :submit_at_ts

  ORGANIZER_PAY = 1
  INVITE_PAY = 2

  def self.save(params, credentials)
    participant_emails = params["participant_emails"].split(",")

    participant_emails.each do |email|
      if !ValidateEmail.valid?(email.strip)
        raise InvalidGroupOrder.new("The list of participants includes invalid emails")
      end
    end
    parse_response(API.post("/grouporders", params.to_json, credentials))
  end

  def self.find(params, credentials)
    parse_response(API.get("/grouporders/#{ params[:id] }", credentials))
  end

  def self.add_items(group_order_token, params, credentials)
    parse_response(API.post("/grouporders/#{ group_order_token }", params.to_json, credentials))
  end

  def self.remove_item(params, credentials)
    parse_response(API.delete("/cart/#{ params[:group_order_token] }/cartitem/#{ params[:item_id] }", credentials))
  end

  def self.destroy(params, credentials)
    parse_response(API.delete("/grouporders/#{ params[:id] }", credentials))
  end

  def self.submit(group_order_token, credentials)
    parse_response(API.post("/grouporders/#{ group_order_token }/submit", "", credentials))
  end

  def self.increment(group_order_token, time, credentials)
    parse_response(API.post("/grouporders/#{ group_order_token }/increment/#{ time }", "", credentials))
  end
end
