require "rails_helper"

describe CacheController do
  describe "#clear_merchant" do
    context "success" do
      before(:each) do
        @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:temppass")
        allow(Rails).to receive_message_chain(:cache, :delete_matched) { true }
      end

      it "returns the correct response" do
        get :clear_merchant, params: { id: 1234 }
        expect(response.body).to eq({id: "1234", status: 200, message: "success"}.to_json)
      end

      it "returns a 200 status" do
        get :clear_merchant, params: { id: 1234 }
        expect(response.status).to eq(200)
      end

      it "clears the cache" do
        expect_any_instance_of(CacheController).to receive(:clear_cache).with("*-1234")
        get :clear_merchant, params: { id: 1234 }
      end
    end

    context "failure" do
      context "w/ authentication" do
        before(:each) do
          @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:temppass")
          allow(Rails).to receive_message_chain(:cache, :delete_matched) { raise "mobile cow chopper" }
        end

        it "returns the correct response" do
          get :clear_merchant, params: { id: 1234 }
          expect(response.body).to eq({id: "1234", status: 422, message: "mobile cow chopper"}.to_json)
        end

        it "returns a 422 status" do
          get :clear_merchant, params: { id: 1234 }
          expect(response.status).to eq(422)
        end
      end

      context "w/o authentication" do
        it "returns the correct response" do
          get :clear_merchant, params: { id: 1234 }
          expect(response.body).to eq("HTTP Basic: Access denied.\n")
        end
      end
    end
  end

  describe "#clear_merchants" do
    context "success" do
      before(:each) do
        @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:temppass")
        allow(API).to receive_message_chain(:get, :body) { {"data" => ["1234"]}.to_json }
        allow(API).to receive_message_chain(:get, :status) { 200 }
      end

      it "clears the cache" do
        expect_any_instance_of(CacheController).to receive(:clear_cache).with("view-partial-*")
        post :clear_merchants
      end

      it "returns the correct response" do
        post :clear_merchants
        expect(response.body).to eq({skin: "all skins", status: 200, message: "success"}.to_json)
      end

      it "returns a 200 status" do
        post :clear_merchants
        expect(response.status).to eq(200)
      end
    end

    context "failure" do
      context "w/ authentication" do
        before(:each) do
          @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:temppass")
          allow(Rails).to receive_message_chain(:cache, :delete_matched) { raise "mobile cow chopper" }
        end

        it "returns a 422 status" do
          post :clear_merchants
          expect(response.status).to eq(422)
        end
      end

      context "w/o authentication" do
        it "returns the correct response" do
          post :clear_merchants
          expect(response.body).to eq("HTTP Basic: Access denied.\n")
        end
      end
    end
  end
end
