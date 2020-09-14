require "rails_helper"

describe BaseModel do
  describe "#parse_response" do
    context "with blank response" do
      it "returns true" do
        expect(BaseModel.parse_response(nil)).to eq(true)
      end

      it "logs the correct message" do
        expect(Rails.logger).to receive(:error).with("The API response is blank.")
        BaseModel.parse_response(nil)
      end

      it "logs the correct Airbrake message" do
        expect(Airbrake).to receive(:notify_sync) { Exception.new("Received error response with no error.  Response is nil") }
        BaseModel.parse_response(nil)
      end

      context "with body blank" do
        let(:response) { double("Response", body: "") }

        it "returns true" do
          expect(BaseModel.parse_response(response)).to eq(true)
        end

        it "logs the correct message" do
          expect(Rails.logger).to receive(:error).with("The API response is blank.")
          BaseModel.parse_response(response)
        end

        it "logs the correct Airbrake message" do
          expect(Airbrake).to receive(:notify_sync) { Exception.new("Received error response with no error.  Response is nil") }
          BaseModel.parse_response(response)
        end
      end
    end

    context "with promo error" do
      let(:response) { double("Response", body: {"data" => "error", "error" => {"error_type" => "promo" } }.to_json, status: "error") }

      it "should raise Promo Error" do
        expect{ BaseModel.parse_response(response) }.to raise_error(PromoError)
      end
    end

    context "with GO error" do
      let(:response) { double("Response", body: { "data" => "error", "error" => { "error_type" => "group_order" } }.to_json,
                              status: "error") }

      it "should raise Promo Error" do
        expect{ BaseModel.parse_response(response) }.to raise_error(GroupOrderError)
      end
    end

    context "with response present" do
      context "with status == 200" do
        let(:response) { double(Faraday::Response) }

        before do
          allow(response).to receive(:body) { {"data" => "success"}.to_json }
          allow(response).to receive(:status) { 200 }
        end

        it "returns parsed data" do
          expect(BaseModel.parse_response(response)).to eq("success")
        end

        it "returns parsed data with message" do
          allow(response).to receive(:body) { {"data" => {"success"=> true }, "message" => "\"System message\""}.to_json }
          allow(response).to receive(:status) { 200 }
          expect(BaseModel.parse_response(response)).to eq({"success" => true, "message" => "\"System message\""})
        end
      end
    end
  end
end
