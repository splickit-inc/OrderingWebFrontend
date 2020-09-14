require 'active_model'
require 'api'
require 'exceptions'

class BaseModel
  include ActiveModel::Model

  ERRORS = { ordering_down: 590, promo: "promo", group_order: "group_order" }

  def self.parse_response(response)
    if response.present? && response.body.present?
      body = JSON.parse(response.body)

      if response.status == ERRORS[:ordering_down]
        raise OrderingDown.new(body["error"]["error"], { status: response.status })
      elsif response.status == 200 && body["error"].blank?
        body['data']['message'] = body['message'] if body['message'].present?
        body["data"]
      else
        if body && body["error"].present?
          Airbrake.notify_sync(Exception.new("Received a 200 status on error response. Error was #{ body["error"] }"),
                               error_message: "Non 200 Status Error. Error was '#{ body["error"] }'") if response.status == 200

          case (body["error"]["error_type"] || "").downcase
            when ERRORS[:promo]
              raise PromoError.new(body["error"]["error"], { status: response.status })
            when ERRORS[:group_order]
              raise GroupOrderError.new(body["error"]["error"], { status: response.status })
            else
              raise APIError.new(body["error"]["error"], { status: response.status })
          end
        else
          Rails.logger.error "Response --- #{ response.inspect }"
          Rails.logger.error "Parsed body --- #{ body.inspect }"
          Airbrake.notify_sync(Exception.new("Received error response with no error.  Response is #{ response.inspect }"),
                               error_message: "No error field on a non 200 status")
          raise APIError.new("Sorry, there has been an error.")
        end
      end
    else
      Airbrake.notify_sync(Exception.new("Received response with no body.  Response is #{ response.inspect }"),
                           error_message: "No body on response")
      Rails.logger.error("The API response is blank.")
    end
  end
end
