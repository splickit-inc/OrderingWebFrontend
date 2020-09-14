require "rails_helper"

describe Order do
  describe "#submit" do
    let(:valid_params) { { cart_ucid: "1234" } }
    let(:valid_user) { { email: "tom@bom.com", password: "welcome" } }

    context "success" do
      before(:each) do
        allow(API).to receive_message_chain(:post, :body) { { data: { bacon: "chicken" } }.to_json }
        allow(API).to receive_message_chain(:post, :status) { 200 }
      end

      it "calls API.post with the correct params" do
        expect(API).to receive("post").with("/orders/1234", valid_params.to_json, valid_user)
        Order.submit(valid_params, valid_user)
      end

      it "parses the response" do
        expect(Order.submit(valid_params, valid_user)).to eq("bacon" => "chicken")
      end
    end

    context "failure" do
      before(:each) do
        allow(API).to receive_message_chain(:post, :body) { {error: {error: "burgers"}}.to_json }
        allow(API).to receive_message_chain(:post, :status) { 402 }
      end

      it "raises an APIError" do
        expect { Order.submit(valid_params, valid_user) }.to raise_exception(APIError, "burgers")
      end
    end
  end
end
