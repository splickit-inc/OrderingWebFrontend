require "rails_helper"

describe OrdersController do

  before(:each) { enable_ssl }

  describe "#show" do
    context "order exists" do
      before(:each) do
        session[:order] = { items: ["toast"], meta: { merchant_id: "5", merchant_name: "Bacon", order_type: "pickup" } }
      end

      it "returns a 200 response" do
        get :show
        expect(response.status).to eq(200)
      end

      it "returns the order as json" do
        get :show
        expect(response.body).to eq({ order: { items: ["toast"],
                                               meta: { merchant_id: "5",
                                                       merchant_name: "Bacon",
                                                       order_type: "pickup" } } }.to_json)
      end
    end

    context "order with deleted items" do
      before do
        session[:order] = { :items => ["toast", { "name" => "test_name", "status" => "deleted" }],
                            :meta => { :merchant_id => "5", :merchant_name => "Bacon", :order_type => "pickup" } }
      end

      it "returns a 200 response" do
        get :show
        expect(response.status).to eq(200)
      end

      it "returns the order as json" do
        get :show
        expect(response.body).to eq({ order: { items: ["toast"],
                                               meta: { merchant_id: "5",
                                                       merchant_name: "Bacon",
                                                       order_type: "pickup" } } }.to_json)
      end
    end

    context "order does not exist" do
      it "returns an empty order" do
        get :show
        expect(response.body).to eq({order: {items: []}}.to_json)
      end

      it "returns a 200 response" do
        get :show
        expect(response.status).to eq(200)
      end
    end
  end

  describe "#create_item" do
    describe "unique ID" do
      it "sets each item with it's own UUID" do
        post :create_item, params: { merchant_id: 1, order_type: "pickup", items: [{"name" => "cats"}].to_json }
        sleep 0.05
        post :create_item, params: { merchant_id: 1, order_type: "pickup", items: [{"name" => "cats"}].to_json }

        first_uuid = JSON.parse(response.body)["order"]["items"].first["uuid"]
        second_uuid = JSON.parse(response.body)["order"]["items"].second["uuid"]

        expect(first_uuid).not_to eq(second_uuid)
      end

      it "sets the UUID using SecureRandom" do
        allow(SecureRandom).to receive(:uuid).and_return("chris-wA$-h3r3")
        post :create_item, params: { merchant_id: 1, order_type: "pickup", items: [{"name" => "cats"}].to_json }
        expect(JSON.parse(response.body)["order"]["items"].first["uuid"]).to eq("chris-wA$-h3r3")
      end
    end

    context "success" do
      let(:valid_item) { {"item_id" => "287734", "name" => "eggs"} }
      let(:valid_item_response) { { "item_id" => "287734", "name" => "eggs", "uuid" => "chris-wA$-h3r3", "status" => "new" } }
      let(:valid_params) {
        {merchant_id: "1", order_type: "pickup", merchant_name: "The Bacon Shop", items: [valid_item].to_json}
      }

      before { allow(SecureRandom).to receive(:uuid).and_return("chris-wA$-h3r3") }

      it "returns a 200 response" do
        post :create_item, params: valid_params
        expect(response.status).to eq(200)
      end

      it "sets session[:order] with the correct items" do
        allow(SecureRandom).to receive(:uuid).and_return("chris-wA$-h3r3")
        expect(session[:order]).to eq(nil)
        post :create_item, params: valid_params
        expect(session[:order][:items]).to eq([valid_item_response])
      end

      it "returns the order as json" do
        post :create_item, params: valid_params
        expect(response.body).to eq({order: {items: [valid_item_response]}}.to_json)
      end

      it "sets items status to new" do
        post :create_item, params: valid_params
        session[:order][:items].each { |item| expect(item["status"]).to eq("new") }
      end

      it "sets the order meta-merchant-id attribute" do
        post :create_item, params: valid_params
        expect(session[:order][:meta][:merchant_id]).to eq("1")
      end

      it "sets the order meta-menu-type attribute" do
        post :create_item, params: valid_params
        expect(session[:order][:meta][:order_type]).to eq("pickup")
      end

      it "sets the order meta-merchant-name attribute" do
        post :create_item, params: valid_params
        expect(session[:order][:meta][:merchant_name]).to eq("The Bacon Shop")
      end

      it "sets the order meta-skin-name attribute" do
        post :create_item, params: valid_params
        expect(session[:order][:meta][:skin_name]).to eq("Test")
      end

      context "group_order" do
        it "sets the order meta-group-order-token attribute" do
          post :create_item, params: { merchant_id: "1", order_type: "pickup", merchant_name: "The Bacon Shop", items: [valid_item].to_json, group_order_token: "HXBX-1000" }
          expect(session[:order][:meta][:group_order_token]).to eq("HXBX-1000")
        end
      end
    end

    context "failure" do
      let(:valid_item) { {"item_id" => "287734", "name" => "eggs"} }

      it "responds correctly when missing the merchant ID param" do
        post :create_item, params: { order_type: "pickup", item: valid_item }
        expect(response.status).to eq(400)
      end

      it "responds correctly when missing the menu type param" do
        post :create_item, params: { merchant_id: "1", item: valid_item }
        expect(response.status).to eq(400)
      end

      it "responds correctly when missing the item param" do
        post :create_item, params: { merchant_id: "1", order_type: "pickup" }
        expect(response.status).to eq(400)
      end
    end
  end

  describe "#show_item" do
    let(:valid_items) {
      [
        {
          "uuid" => 187263,
          "name" => "Steak and Eggs"
        },
        {
          "uuid" => 912731,
          "name" => "Hazmat Clothes"
        }
      ]
    }
    context "item found" do
      before(:each) do
        session[:order] = {}
        session[:order][:items] = valid_items
        session[:order][:meta] = {"merchant_id" => "100234"}
      end

      it "returns a 200 status code" do
        get :show_item, params: { id: "187263" }
        expect(response.status).to eq(200)
      end

      it "returns the item as JSON" do
        get :show_item, params: { id: "187263" }
        expect(response.body).to eq({
          "item" => valid_items.first,
          "meta" => {"merchant_id" => "100234"}
        }.to_json)
      end
    end

    context "item not found" do
      before(:each) do
        session[:order] = {}
        session[:order][:items] = valid_items
      end

      it "returns a 200 status code" do
        get :show_item, params: { id: "1234" }
        expect(response.status).to eq(200)
      end

      it "renders nothing" do
        get :show_item, params: { id: "1234" }
        expect(response).to render_template(nil)
      end
    end

    context "no order exists" do
      it "returns the correct status code" do
        get :show_item, params: { id: "1234" }
        expect(response.status).to eq(404)
      end

      it "renders nothing" do
        get :show_item, params: { id: "1234" }
        expect(response).to render_template(nil)
      end
    end
  end

  describe "#update_item" do
    context "item found" do
      before(:each) do
        session[:order] = {}
        session[:order][:items] = [{"uuid" => "2001", "name" => "Bacon and Bacon", "size_id" => "1234"}]
        session[:order][:meta]  = {"merchant_id" => "100296"}
      end

      it "returns a 200 status code" do
        get :update_item, params: { id: "2001", item: {name: "Hashbrowns"} }
        expect(response.status).to eq(200)
      end

      it "returns the updated item as JSON" do
        get :update_item, params: { id: "2001", item: {uuid: "2001", name: "Hashbrowns", size_id: "1235"} }
        expect(response.body).to eq({
          "order" => {
            "items" => [
              "uuid" => "2001",
              "name" => "Hashbrowns",
              "size_id" => "1235"
            ]},
          "meta" =>{
            "merchant_id" => "100296"
          }}.to_json)
      end

      it "updates the item in the session" do
        expect(session[:order][:items]).to eq([{"uuid" => "2001", "name" => "Bacon and Bacon", "size_id" => "1234"}])
        get :update_item, params: { id: "2001", item: {uuid: "2001", name: "Hashbrowns", size_id: "1235" }}
        expect(session[:order][:items]).to eq([{"uuid" => "2001", "name" => "Hashbrowns", "size_id" => "1235"}])
      end

      it "should not set status to updated" do
        get :update_item, params: { id: "2001", item: { uuid: "2001", name: "Hashbrowns", size_id: "1235" } }
        expect(session[:order][:items].first["status"]).not_to eq("updated")
      end

      context "item with order_detail_id" do
        before(:each) do
          session[:order][:items].each_with_index { |item, index| item["order_detail_id"] = index.to_s }
        end

        it "should set status to updated" do
          get :update_item, params: { id: "2001", item: { uuid: "2001", name: "Hashbrowns", size_id: "1235" } }
          expect(session[:order][:items].first["status"]).to eq("updated")
        end
      end
    end

    context "item not found" do
      it "returns the correct status code" do
        get :show_item, params: { id: "1234" }
        expect(response.status).to eq(404)
      end

      it "renders nothing" do
        get :show_item, params: { id: "1234" }
        expect(response).to render_template(nil)
      end
    end

    context "order not found" do
      it "returns the correct status code" do
        get :show_item, params: { id: "1234" }
        expect(response.status).to eq(404)
      end

      it "renders nothing" do
        get :show_item, params: { id: "1234" }
        expect(response).to render_template(nil)
      end
    end
  end

  describe "#delete_item" do
    let(:valid_order) do
      { :items => [{ "uuid" => "128371283", "name" => "eggs", "points_used" => "10" },
                   { "uuid" => "128371985", "name" => "bacon", "points_used" => "10" }],
        :meta => {} }
    end

    before(:each) do
      session[:order] = valid_order
    end

    context "success" do
      it "returns a 200 response" do
        delete :delete_item, params: { id: valid_order[:items].first["uuid"] }
        expect(response.status).to eq(200)
      end

      it "sets session[:order] with the correct items" do
        delete :delete_item, params: { id: valid_order[:items].first["uuid"] }
        expect(session[:order][:items]).to eq([{ "uuid" => valid_order[:items].last["uuid"], "name" => "bacon", "points_used" => "10" }])
      end

      it "returns the updated order as json" do
        delete :delete_item, params: { id: valid_order[:items].first["uuid"] }
        expect(response.body).to eq({order: {items: [{"uuid" => valid_order[:items].last["uuid"], "name" => "bacon", "points_used" => "10"}]}, "user" => {"points_used" => "10"}}.to_json)
      end

      it "should delete item" do
        get :delete_item, params: { id: "128371283" }
        expect(session[:order][:items]).to eq([{ "uuid" => valid_order[:items].last["uuid"],
                                                 "name" => "bacon", "points_used" => "10" }])
      end

      context "item with order_detail_id" do
        before(:each) do
          session[:order][:items].each_with_index { |item, index| item["order_detail_id"] = index.to_s }
        end

        it "should set status to deleted" do
          get :delete_item, params: { id: "128371283" }
          expect(session[:order][:items].first["status"]).to eq("deleted")
        end
      end

      context "multiple items of similar type" do
        let(:valid_order) do
          { :items => [{ "uuid" => "2637138282", "name" => "eggs" },
                       { "uuid" => "2637197263", "name" => "bacon", "modifier" => "bacon" },
                       { "uuid" => "8172387822", "name" => "bacon", "modifier" => "chicken" }],
            :meta => {} }
        end

        it "sets session[:order][:items] with the correct items" do
          delete :delete_item, params: { id: valid_order[:items].last["uuid"] }
          expect(session[:order][:items]).to eq([{"uuid" => valid_order[:items].first["uuid"], "name" => "eggs"}, {"uuid" => valid_order[:items].second["uuid"], "name" => "bacon", "modifier" => "bacon"}])
        end

        it "sets session[:order][:cart_id] to nil" do
          delete :delete_item, params: { id: valid_order[:items].last["uuid"] }
          expect(session[:order][:cart_id]).to eq(nil)
        end

        it "returns the updated order as json" do
          delete :delete_item, params: { id: valid_order[:items].last["uuid"] }
          expect(response.body).to eq({order: {items: [{"uuid" => valid_order[:items].first["uuid"], "name" => "eggs"}, {"uuid" => valid_order[:items].second["uuid"], "name" => "bacon", "modifier" => "bacon"}]}, "user" => {"points_used" => nil}}.to_json)
        end
      end
    end

    context "no order exists" do
      before(:each) do
        session[:order] = nil
      end

      it "returns the correct status" do
        delete :delete_item, params: { order_type: "pickup", id: "1" }
        expect(response.status).to eq(404)
      end

      it "should not blow up" do
        delete :delete_item, params: { merchant_id: "1", order_type: "pickup", id: "1" }
        expect(session[:order]).to be_nil
      end
    end
  end

  describe "#destroy" do

    it "should reset cart" do
      delete :destroy

      expect(session[:order]).to be_nil
    end

    it "should redirect to root" do
      delete :destroy

      expect(response).to redirect_to(root_path)
    end
  end

  describe "#checkout" do
    context "with order" do
      let(:valid_items) {
        [
          {
            "uuid" => 187263,
            "name" => "Steak and Eggs"
          },
          {
            "uuid" => 912731,
            "name" => "Hazmat Clothes"
          }
        ]
      }

      before(:each) do
        session[:order] = {}
        session[:order][:items] = valid_items
        session[:order][:meta] = {:merchant_id => "100234",:merchant_name => "Bob's House of Cakes"}
      end

      it 'should redirect to checkouts#new if we have an order' do
        get :checkout
        expect(response).to redirect_to(new_checkout_path({"merchant_id" => "100234"}))
      end
    end

    context "without order" do
      it 'should redirect to root if we have no order' do
        get :checkout
        expect(response).to redirect_to(root_path)
      end

      it 'should display an error flash' do
        get :checkout
        expect(flash[:error]).to eq("We're sorry, we cannot place your order. Your cart is currently empty.")
      end
    end
  end
end
