require "rails_helper"

describe Catering do
  describe "#create" do
    it "should call post api response" do
      expect(API).to receive("post")
                       .with("/catering", "{}", { user_auth_token: "test" }).and_return(nil)
      Catering.create({},{ user_auth_token: "test"})
    end

    it "should parse api response" do
      catering_create_stub(auth_token: "test")
      catering = Catering.create({ number_of_people: "1",
                                   merchant_id: "106004",
                                   timestamp_of_event: "1484169890",
                                   contact_name: "Jose",
                                   contact_phone: "555-555-5555",
                                   notes: "1" } ,
                                 { user_auth_token: "test"})
      expect(catering).to eq("id" => "1001", "number_of_people" => "1", "event" => "",
                             "order_type" => "delivery", "order_id" => "12208606",
                             "user_delivery_location_id" => nil,
                             "date_tm_of_event" => "2017-01-11 14:24:50",
                             "timestamp_of_event" => "1484169890", "contact_info" => "Jose 555-555-5555",
                             "notes" => nil, "status" => "In Progress", "insert_id" => 1001,
                             "ucid" => "4076-1de8d-57dbc-lar86")
    end
  end
end