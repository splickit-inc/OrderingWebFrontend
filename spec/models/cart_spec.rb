require "rails_helper"

describe Cart do
  describe "#create" do
    let(:valid_params) { {ucid: "1234"} }
    let(:valid_user) { {email: "tom@bom.com", password: "welcome"} }

    context "success" do
      before(:each) do
        allow(API).to receive_message_chain(:post, :body) { {data: {bacon: "chicken"}}.to_json }
        allow(API).to receive_message_chain(:post, :status) { 200 }
      end

      it "calls API.post with the correct params" do
        expect(API).to receive("post").with("/cart", valid_params.to_json, valid_user)
        Cart.create(valid_params, valid_user)
      end

      it "parses the response" do
        expect(Cart.create(valid_params, valid_user)).to eq("bacon" => "chicken")
      end
    end

    context "failure" do
      before(:each) do
        allow(API).to receive_message_chain(:post, :body) { {error: {error: "burgers"}}.to_json }
        allow(API).to receive_message_chain(:post, :status) { 402 }
      end

      it "raises an APIError" do
        expect { Cart.create(valid_params, valid_user) }.to raise_exception(APIError, "burgers")
      end
    end
  end

  describe "#update" do
    let(:valid_id) { 1234 }
    let(:valid_params) { {ucid: "1234"} }
    let(:valid_user) { {email: "tom@bom.com", password: "welcome"} }

    context "success" do
      before(:each) do
        allow(API).to receive_message_chain(:post, :body) { {data: {bacon: "chicken"}}.to_json }
        allow(API).to receive_message_chain(:post, :status) { 200 }
      end

      it "calls API.post with the correct params" do
        expect(API).to receive("post").with("/cart/#{valid_id}", valid_params.to_json, valid_user)
        Cart.update(valid_id, valid_params, valid_user)
      end

      it "parses the response" do
        expect(Cart.update(valid_id, valid_params, valid_user)).to eq("bacon" => "chicken")
      end
    end

    context "failure" do
      before(:each) do
        allow(API).to receive_message_chain(:post, :body) { {error: {error: "burgers"}}.to_json }
        allow(API).to receive_message_chain(:post, :status) { 402 }
      end

      it "raises an APIError" do
        expect { Cart.update(valid_id, valid_params, valid_user) }.to raise_exception(APIError, "burgers")
      end
    end
  end

  describe "#find" do
    describe "#create" do
      let(:valid_id) { 1234 }
      let(:valid_user) { {email: "tom@bom.com", password: "welcome"} }

      context "success" do
        before(:each) do
          allow(API).to receive_message_chain(:get, :body) { {data: {bacon: "chicken"}}.to_json }
          allow(API).to receive_message_chain(:get, :status) { 200 }
        end

        it "calls API.post with the correct params" do
          expect(API).to receive("get").with("/cart/#{valid_id}", valid_user)
          Cart.find(valid_id, valid_user)
        end

        it "parses the response" do
          expect(Cart.find(valid_id, valid_user)).to eq("bacon" => "chicken")
        end
      end

      context "failure" do
        before(:each) do
          allow(API).to receive_message_chain(:get, :body) { {error: {error: "burgers"}}.to_json }
          allow(API).to receive_message_chain(:get, :status) { 402 }
        end

        it "raises an APIError" do
          expect { Cart.find(valid_id, valid_user) }.to raise_exception(APIError, "burgers")
        end
      end
    end
  end

  describe "#checkout" do
    describe "#create" do
      let(:valid_params) { { email: "tom@bom.com", password: "welcome" } }
      let(:valid_id) { 1234 }

      context "success" do
        before(:each) do
          allow(API).to receive_message_chain(:post, :body) { {data: {bacon: "chicken"}}.to_json }
          allow(API).to receive_message_chain(:post, :status) { 200 }
        end

        it "calls API.post with the correct params" do
          expect(API).to receive("post").with("/cart/#{ valid_id }/checkout", valid_params.to_json, valid_params)
          Cart.checkout(valid_id, valid_params, valid_params)
        end

        it "parses the response" do
          expect(Cart.checkout(valid_id, valid_params, valid_params)).to eq("bacon" => "chicken")
        end
      end

      context "failure" do
        before(:each) do
          allow(API).to receive_message_chain(:post, :body) { {error: {error: "burgers"}}.to_json }
          allow(API).to receive_message_chain(:post, :status) { 402 }
        end

        it "raises an APIError" do
          expect { Cart.checkout(valid_id, valid_params, valid_params) }.to raise_exception(APIError, "burgers")
        end
      end
    end
  end

  describe "#promo" do
    let(:valid_id) { "123" }
    let(:valid_params) { { email: "tom@bom.com", password: "welcome", promo_code: "promo" } }

    before(:each) do
      allow(API).to receive_message_chain(:get, :body) { {data: { bacon: "chicken" } }.to_json }
      allow(API).to receive_message_chain(:get, :status) { 200 }
    end

    it "calls API.post with the correct params" do
      expect(API).to receive("get").with("/cart/#{ valid_id }/checkout?promo_code=promo", valid_params)
      Cart.promo(valid_id, valid_params)
    end

    it "parses the response" do
      expect(Cart.promo(valid_id, valid_params)).to eq("bacon" => "chicken")
    end
  end
end
