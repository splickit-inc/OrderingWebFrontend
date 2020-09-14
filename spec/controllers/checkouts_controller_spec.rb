require "rails_helper"
require 'api'

describe CheckoutsController do
  let(:valid_cart) do
    { "order_summary" => { "cart_items" => [{ "item_note" => "extra salty butter", "order_detail_id" => "123" }],
                           "receipt_items" => [{ "title" => "Promo Discount",
                                                 "amount" => "$-1.00" },
                                               { "title" => "Subtotal",
                                                 "amount" => "$6.89" },
                                               { "title" => "Tax",
                                                 "amount" => "$0.41" },
                                               { "title" => "Total",
                                                 "amount" => "$6.30" }] },
      "lead_times_array" => [1444348099, 1444348159, 1444348219, 1444348279, 1444348339, 1444348399,
                             1444348459, 1444348519, 1444348579, 1444348639, 1444348699, 1444348819,
                             1444349119, 1444349419, 1444349719, 1444350019, 1444350319, 1444350619,
                             1444350919, 1444351219, 1444351519, 1444351819, 1444352119, 1444352419,
                             1444352719, 1444353019, 1444353319],
      "tip_array" => [["No Tip", 0], ["10%", 0.63], ["15%", 0.95], ["20%", 0.20], ["$1.00", 1], ["$2.00", 2]],
      "ucid" => "9705-j069h-ce8w3-425di" }
  end

  let(:valid_loyalty_cart) { {
    "order_summary" => {
      "receipt_items" => [
        {
          "title" => "Total",
          "amount" => "0"
        }
      ]
    }
  } }

  describe "#new" do
    let(:valid_params) { { merchant_id: "5678", order_type: "pickup" } }
    let(:merchant_data) { create_merchant({ "name" => "black hole", "time_zone_offset" => "-5", "show_tip" => true }) }

    let(:user) do
      get_user_data.merge("user_id" => "12345",
                          "first_name" => "barnis",
                          "email" => "tom@bom.com",
                          "splickit_authentication_token" => "B4C0NTOKEN",
                          "delivery_locations" => [{ "user_addr_id" => "1234",
                                                     "address1" => "bacon st." }])
    end

    before do
      sign_in(user)

      allow(Merchant).to receive(:info) { merchant_data }
      allow(Cart).to receive(:get_checkout) { valid_cart }
      allow(Cart).to receive(:update) { valid_cart }

      session[:order] = { meta: {}, items: [{ "item_id" => "700",
                                              "uuid" => "8945-as",
                                              "quantity" => "1",
                                              "mods" => [],
                                              "size_id" => "800",
                                              "note" => "extra salty butter" }] }

      checkout_stubs(auth_token: "B4C0NTOKEN",
                     body: { user_id: "12345", merchant_id: "5678", submitted_order_type: "pickup",
                             group_order_token: nil, user_addr_id: nil,
                             items: [{ item_id: "700", external_detail_id: "8945-as", quantity: "1", mods: [],
                                       size_id: "800", status: nil, order_detail_id: nil, points_used: nil,
                                       brand_points_id: nil, note: "extra salty butter" },
                                     { item_id: "700", external_detail_id: "8946-as", quantity: "1", mods: [],
                                       size_id: "800", status: nil, order_detail_id: nil, points_used: nil,
                                       brand_points_id: nil, note: "extra salty butter" }],
                             total_points_used: 0 },
                     return: { order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                               item_price: "6.89",
                                                               item_quantity: "1",
                                                               item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                               order_detail_id: "27479804",
                                                               note: "" }],
                                                order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                     user_id: "4777193",
                                                                                     items: [{ item_id: "931",
                                                                                               size_id: "1",
                                                                                               quantity: "1",
                                                                                               order_detail_id: "27479804",
                                                                                               external_detail_id: "8945-as",
                                                                                               status: "saved",
                                                                                               mods: [{ modifier_item_id: "2",
                                                                                                        mod_quantity: "1" }] }] } } })
    end

    describe "#update_checkout_items" do
      before do
        allow(Cart).to receive(:update).and_call_original
        allow(Cart).to receive(:get_checkout).and_call_original
        session[:order][:items] << { "item_id" => "700",
                                     "uuid" => "8946-as",
                                     "quantity" => "1",
                                     "mods" => [],
                                     "size_id" => "800",
                                     "note" => "extra salty butter" }
      end

      it "should update uuid on cart_items if order_detail_id exists" do
        get :new, params: valid_params
        expect(assigns(:checkout)["order_summary"]["cart_items"].first).to eq("item_name" => "Ham n' Eggs",
                                                                              "item_price" => "6.89",
                                                                              "item_quantity" => "1",
                                                                              "item_description" => "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                              "order_detail_id" => "27479804",
                                                                              "note" => "",
                                                                              "uuid" => "8945-as")
      end

      it "should not update uuid on cart_items if order_detail_id does not exists" do
        checkout_stubs(auth_token: "B4C0NTOKEN",
                       body: { user_id: "12345", merchant_id: "5678", group_order_token: nil, user_addr_id: nil,
                               items: [{ item_id: "700", external_detail_id: "8945-as", quantity: "1", mods: [],
                                         size_id: "800", status: nil, order_detail_id: nil, points_used: nil,
                                         brand_points_id: nil, note: "extra salty butter" },
                                       { item_id: "700", external_detail_id: "8946-as", quantity: "1", mods: [],
                                         size_id: "800", status: nil, order_detail_id: nil, points_used: nil,
                                         brand_points_id: nil, note: "extra salty butter" }],
                               total_points_used: 0 },
                       return: { order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                 item_price: "6.89",
                                                                 item_quantity: "1",
                                                                 item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                 note: "" }],
                                                  order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                       user_id: "4777193",
                                                                                       items: [{ item_id: "931",
                                                                                                 size_id: "1",
                                                                                                 quantity: "1",
                                                                                                 order_detail_id: "27479804",
                                                                                                 external_detail_id: "8945-as",
                                                                                                 status: "saved",
                                                                                                 mods: [{ modifier_item_id: "2",
                                                                                                          mod_quantity: "1" }] }] } } })
        get :new, params: valid_params
        expect(assigns(:checkout)["order_summary"]["cart_items"].first).to eq("item_name" => "Ham n' Eggs",
                                                                              "item_price" => "6.89",
                                                                              "item_quantity" => "1",
                                                                              "item_description" => "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                              "note" => "")
      end
    end

    describe "#update_cart_session" do
      before do
        allow(Cart).to receive(:update).and_call_original
        allow(Cart).to receive(:get_checkout).and_call_original
        session[:order][:items] << { "item_id" => "700",
                                     "uuid" => "8946-as",
                                     "quantity" => "1",
                                     "mods" => [],
                                     "size_id" => "800",
                                     "note" => "extra salty butter" }
      end

      it "should set cart_id" do
        get :new, params: valid_params
        expect(session[:order][:cart_id]).to eq("9705-j069h-ce8w3-425di")
      end

      it "should update status and order_detail_id of all items inside the checkout array" do
        get :new, params: valid_params
        item = session[:order][:items].find { |item| item["uuid"] == "8945-as" }
        expect(item["status"]).to eq("saved")
        expect(item["order_detail_id"]).to eq("27479804")
      end

      it "should delete the items that are not in the response" do
        get :new, params: valid_params
        item = session[:order][:items].find { |item| item["uuid"] == "8946-as" }
        expect(item).to be_nil
      end
    end

    describe "#update_user_data" do
      before do
        allow(Cart).to receive(:get_checkout).and_call_original

        checkout_stubs(auth_token: "B4C0NTOKEN",
                       body: { user_id: "12345", merchant_id: "5678", group_order_token: nil, user_addr_id: nil,
                               items: [{ item_id: "700", external_detail_id: "8945-as", quantity: "1", mods: [],
                                         size_id: "800", status: nil, order_detail_id: nil, points_used: nil,
                                         brand_points_id: nil, note: "extra salty butter" }],
                               total_points_used: 0 },
                       return: { user_info: { last_four: "1234", user_has_cc: true }})
      end


      context "user with cc" do
        it "should update cc data" do
          get :new, params: valid_params
          expect(session[:current_user]["flags"].index("1C")).to eq(0)
          expect(session[:current_user]["last_four"]).to eq("1234")
        end
      end

      context "user without cc" do
        before do
          sign_in(user.merge("flags" => "0011111111"))
        end

        it "should update cc data" do
          get :new, params: valid_params
          expect(session[:current_user]["flags"].index("1C")).to eq(0)
          expect(session[:current_user]["last_four"]).to eq("1234")
        end
      end
    end

    context "cart exists from previous visit to checkout" do
      let(:valid_params) { { merchant_id: "5678", order_type: "pickup" } }

      before(:each) do
        allow(Cart).to receive(:update).and_call_original
        allow(API).to receive(:post) { double(status: 200, body: { data: valid_cart }.to_json) }
        session[:order][:cart_id] = "1234"
      end

      it "should call checkout with cart_id" do
        params = { user_id: "12345", merchant_id: "5678",  submitted_order_type: "pickup", group_order_token: nil,
                   user_addr_id: nil, items: [{ item_id: "700", external_detail_id: "8945-as",
                                                quantity: "1", mods: [], size_id: "800",
                                                status: nil, order_detail_id: nil,
                                                points_used: nil, brand_points_id: nil,
                                                note: "extra salty butter" }],
                   total_points_used: 0 }

        expect(API).to receive(:post).with("/cart/1234", params.to_json, { user_auth_token: "B4C0NTOKEN" })
        get :new, params: valid_params
      end

      it "assigns @checkout with expected data" do
        get :new, params: valid_params
        expect(assigns(:checkout)).to eq(valid_cart)
      end

      it "assigns @items with expected data" do
        get :new, params: valid_params
        expect(assigns(:items)).to eq(valid_cart["order_summary"]["cart_items"])
      end

      it "assigns vio credentials" do
        vio_credentials_stubs
        get :new, params: valid_params
        expect(assigns(:account)).to eq("splikit")
        expect(assigns(:token)).to eq("vio-token")
      end
    end

    context "cart doesn't exist" do
      before(:each) do
        allow(Cart).to receive(:update).and_call_original
        allow(API).to receive(:post) { double(status: 200, body: { data: valid_cart }.to_json) }
      end

      it "should call checkout without cart_id" do
        params = { user_id: "12345", merchant_id: "5678", submitted_order_type: "pickup", group_order_token: nil,
                   user_addr_id: nil, items: [{ item_id: "700", external_detail_id: "8945-as",
                                                quantity: "1", mods: [], size_id: "800",
                                                status: nil, order_detail_id: nil,
                                                points_used: nil, brand_points_id: nil,
                                                note: "extra salty butter" }],
                   total_points_used: 0 }

        expect(API).to receive(:post).with("/cart/", params.to_json, { user_auth_token: "B4C0NTOKEN" })
        get :new, params: valid_params
      end

      it "assigns @checkout with expected data" do
        get :new, params: valid_params
        expect(assigns(:checkout)).to eq(valid_cart)
      end

      it "assigns @items with expected data" do
        get :new, params: valid_params
        expect(assigns(:items)).to eq(valid_cart["order_summary"]["cart_items"])
      end

      it "assigns vio credentials" do
        vio_credentials_stubs
        get :new, params: valid_params
        expect(assigns(:account)).to eq("splikit")
        expect(assigns(:token)).to eq("vio-token")
      end

      it "calls cart create with correct params using loyalty points" do
        session[:order][:items].first.merge!("status" => "new", "points_used" => "1")

        valid_params = { user_id: "12345",
                         merchant_id: "5678",
                         submitted_order_type: "pickup",
                         items: [{ item_id: "700",
                                   external_detail_id: "8945-as",
                                   quantity: "1",
                                   mods: [],
                                   size_id: "800",
                                   points_used: "1",
                                   brand_points_id: nil,
                                   status: "new",
                                   order_detail_id: nil,
                                   note: "extra salty butter" }],
                         total_points_used: 1 }

        expect(Cart).to receive(:update).with(nil,
                                              valid_params.merge(group_order_token: nil, user_addr_id: nil),
                                              { user_auth_token: "B4C0NTOKEN" })
        get :new, params: valid_params

        session[:order][:items].each { |item| item["status"] = "saved" }

        valid_params.merge!(total_points_used: 0)
        valid_params[:items].each { |item| item[:status] = "saved" }

        expect(Cart).to receive(:update).with("9705-j069h-ce8w3-425di",
                                              valid_params.merge(group_order_token: nil, user_addr_id: nil),
                                              { user_auth_token: "B4C0NTOKEN" })
        get :new, params: valid_params
      end

      context "pickup" do
        it "calls cart create with correct params" do
          valid_pickup_cart_params = {
            user_id: "12345",
            merchant_id: "5678",
            submitted_order_type: "pickup",
            group_order_token: nil,
            user_addr_id: nil,
            items: [{ item_id: "700",
                      quantity: "1",
                      mods: [],
                      size_id: "800",
                      points_used: nil,
                      brand_points_id: nil,
                      external_detail_id: "8945-as",
                      status: nil,
                      order_detail_id: nil,
                      note: "extra salty butter" }],
            total_points_used: 0
          }

          expect(Cart).to receive(:update).with(nil, valid_pickup_cart_params, { user_auth_token: "B4C0NTOKEN" })
          get :new, params: valid_params
        end
      end

      context "delivery" do
        it "calls cart create with correct params" do
          valid_delivery_cart_params = { user_id: "12345",
                                         merchant_id: "5678",
                                         submitted_order_type: "delivery",
                                         group_order_token: nil,
                                         user_addr_id: nil,
                                         items: [{ item_id: "700",
                                                   quantity: "1",
                                                   mods: [],
                                                   size_id: "800",
                                                   points_used: nil,
                                                   brand_points_id: nil,
                                                   external_detail_id: "8945-as",
                                                   status: nil,
                                                   order_detail_id: nil,
                                                   note: "extra salty butter" }],
                                         total_points_used: 0 }

          expect(Cart).to receive(:update).with(nil, valid_delivery_cart_params, { user_auth_token: "B4C0NTOKEN" })
          get :new, params: valid_params.merge(order_type: "delivery")
        end

        it "assigns vio credentials" do
          vio_credentials_stubs
          get :new, params: valid_params
          expect(assigns(:account)).to eq("splikit")
          expect(assigns(:token)).to eq("vio-token")
        end
      end
    end

    context "pickup" do
      it "assigns vio credentials" do
        vio_credentials_stubs
        get :new, params: valid_params
        expect(assigns(:account)).to eq("splikit")
        expect(assigns(:token)).to eq("vio-token")
      end
    end

    context "delivery order" do
      let(:valid_params) { { merchant_id: "5678", order_type: "delivery" } }

      it "assigns @delivery_address to the preferred address" do
        sign_in(get_user_data)
        request.cookies[:userPrefs] = { preferredAddressId: "5667" }.to_json
        get :new, params: valid_params
        expect(assigns(:delivery_address)).to eq("user_addr_id" => "5667", "user_id" => "2",
                                                 "name" => "Metro Wastewater Reclamation Plant", "address1" => "6450 York St",
                                                 "address2" =>"Basement", "city" => "Denver", "state" => "CO", "zip" => "80229",
                                                 "lat" => "39.8149386187446", "lng" => "-104.956209155655",
                                                 "phone_no" => "(303) 286-3000", "instructions" => "wear cruddy shoes")
      end
    end

    it "assigns @checkout with expected cart data" do
      get :new, params: valid_params
      expect(assigns(:checkout)).to eq("order_summary" => { "cart_items" => [{ "item_note" => "extra salty butter", "order_detail_id" => "123" }],
                                                            "receipt_items" => [{"title" => "Promo Discount", "amount" => "$-1.00"}, {"title" => "Subtotal", "amount" => "$6.89"}, {"title" => "Tax", "amount" => "$0.41"}, {"title" => "Total", "amount" => "$6.30"}]},
                                       "lead_times_array" => [1444348099, 1444348159, 1444348219, 1444348279, 1444348339, 1444348399, 1444348459, 1444348519, 1444348579, 1444348639, 1444348699, 1444348819, 1444349119, 1444349419, 1444349719, 1444350019, 1444350319, 1444350619, 1444350919, 1444351219, 1444351519, 1444351819, 1444352119, 1444352419, 1444352719, 1444353019, 1444353319],
                                       "tip_array" => [["No Tip", 0], ["10%", 0.63], ["15%", 0.95], ["20%", 0.20], ["$1.00", 1], ["$2.00", 2]],
                                       "ucid" => "9705-j069h-ce8w3-425di")
    end

    it "assigns @order_receipt with expected cart data" do
      get :new, params: valid_params
      expect(assigns(:order_receipt)).to eq([{ "title" => "Promo Discount", "amount" => "$-1.00" },
                                             { "title" => "Subtotal", "amount" => "$6.89" },
                                             { "title" => "Tax", "amount" => "$0.41" }])
    end

    it "assigns @merchant with expected cart data" do
      get :new, params: valid_params
      expect(assigns(:merchant).name).to eq("black hole")
    end

    it "assigns @user with expected cart data" do
      get :new, params: valid_params
      expect(assigns(:user).first_name).to eq("barnis")
    end

    it "renders checkouts/new" do
      get :new, params: valid_params
      expect(response).to render_template :new
    end

    context "APIError" do
      before(:each) do
        session[:order][:items] = ['something']
        session[:order][:cart_id] = '1234'

        allow(Cart).to receive(:get_checkout) { raise APIError.new("burgers") }
      end

      context "group order admin" do
        let(:valid_params) { { group_order_token: "8211-guhj7-262d2-b8lw2", merchant_id: "5678", order_type: "pickup" } }

        before do
          session[:current_user]["group_order_token"] = "8211-guhj7-262d2-b8lw2"
        end

        it "sets the flash message" do
          get :new, params: valid_params
          expect(flash[:error]).to eq("burgers")
        end

        it "redirects to group order status" do
          get :new, params: valid_params
          expect(response).to redirect_to(group_order_path("8211-guhj7-262d2-b8lw2"))
        end
      end

      context "group order invitee" do
        let(:valid_params) { { group_order_token: "8211-guhj7-262d2-b8lw2", merchant_id: "5678", order_type: "pickup" } }

        it "sets the flash message" do
          get :new, params: valid_params
          expect(flash[:error]).to eq("burgers")
        end

        it "redirects to merchant page" do
          get :new, params: valid_params
          expect(response).to redirect_to(merchant_path("5678", order_type: "pickup", group_order_token: "8211-guhj7-262d2-b8lw2"))
        end
      end

      context "non-group order" do
        let(:valid_params) { {merchant_id: "5678", order_type: "delivery"} }

        it "sets the flash message" do
          get :new, params: valid_params
          expect(flash[:error]).to eq("burgers")
        end

        it "redirects to the correct merchant path" do
          get :new, params: valid_params
          expect(response).to redirect_to(merchant_path("5678", order_type: "delivery"))
        end
      end
    end

    context "not signed in" do
      let(:valid_params) { {cart_id: "1234", merchant_id: "5678", order_type: "pickup"} }

      before(:each) do
        sign_out
      end

      it "redirects to the sign in path with the correct continue param" do
        get :new, params: valid_params
        expect(response).to redirect_to(sign_in_path(continue: "/checkouts/new?cart_id=1234&merchant_id=5678&order_type=pickup"))
      end
    end

    context "payment with cash" do
      let(:valid_params) { {cart_id: "1234", merchant_id: "5678", order_type: "pickup"} }

      before(:each) do
        allow(Cart).to receive(:find) { valid_cart }
        allow(Cart).to receive(:get_checkout) {
          {
            "order_summary" => {
              "receipt_items" => [
                {
                  "title" => "Subtotal",
                  "amount" => "$6.89"
                },
                {
                  "title" => "Tax",
                  "amount" => "$0.41"
                },
                {
                  "title" => "Total",
                  "amount" => "$6.30"
                }
              ]
            },
            "lead_times_array" => [1444348099, 1444348159, 1444348219, 1444348279, 1444348339, 1444348399, 1444348459,
                                   1444348519, 1444348579, 1444348639, 1444348699, 1444348819, 1444349119, 1444349419,
                                   1444349719, 1444350019, 1444350319, 1444350619, 1444350919, 1444351219, 1444351519,
                                   1444351819, 1444352119, 1444352419, 1444352719, 1444353019, 1444353319],
            "accepted_payment_types" => [
              {
                "splickit_accepted_payment_type_id" => "1000",
                "merchant_payment_type_map_id" => "1022"
              }
            ],
            "tip_array" => [["No Tip", 0], ["10%", 0.63], ["15%", 0.95], ["20%", 0.20], ["$1.00", 1], ["$2.00", 2]]
          }
        }
      end

      it "assigns @cash_payments with the expected data" do
        get :new, params: valid_params
        expect(assigns(:cash_payments)).to eq([{ "splickit_accepted_payment_type_id" => "1000",
                                                 "merchant_payment_type_map_id" => "1022" }])
        expect(assigns(:loyalty_payments)).to eq([])
        expect(assigns(:credit_payments)).to eq([])
      end
    end

    context "payment with credit" do
      let(:valid_params) { {cart_id: "1234", merchant_id: "5678", order_type: "pickup"} }

      before(:each) do
        allow(Cart).to receive(:find) { valid_cart }
        allow(Cart).to receive(:get_checkout) {
          {
            "order_summary" => {
              "receipt_items" => [
                {
                  "title" => "Subtotal",
                  "amount" => "$6.89"
                },
                {
                  "title" => "Tax",
                  "amount" => "$0.41"
                },
                {
                  "title" => "Total",
                  "amount" => "$6.30"
                }
              ]
            },
            "lead_times_array" => [1444348099, 1444348159, 1444348219, 1444348279, 1444348339, 1444348399, 1444348459,
                                   1444348519, 1444348579, 1444348639, 1444348699, 1444348819, 1444349119, 1444349419,
                                   1444349719, 1444350019, 1444350319, 1444350619, 1444350919, 1444351219, 1444351519,
                                   1444351819, 1444352119, 1444352419, 1444352719, 1444353019, 1444353319],
            "accepted_payment_types" => [
              {
                "splickit_accepted_payment_type_id" => "2000",
                "merchant_payment_type_map_id" => "2022"
              }
            ],
            "tip_array" => [["No Tip", 0], ["10%", 0.63], ["15%", 0.95], ["20%", 0.20], ["$1.00", 1], ["$2.00", 2]]
          }
        }
      end

      it "assigns @credit_payments with the expected data" do
        get :new, params: valid_params
        expect(assigns(:credit_payments)).to eq([{ "splickit_accepted_payment_type_id" => "2000",
                                                   "merchant_payment_type_map_id" => "2022" }])
        expect(assigns(:loyalty_payments)).to eq([])
        expect(assigns(:cash_payments)).to eq([])
      end

      it "assigns vio credentials" do
        vio_credentials_stubs
        get :new, params: valid_params
        expect(assigns(:account)).to eq("splikit")
        expect(assigns(:token)).to eq("vio-token")
      end
    end

    context "payment with loyalty" do
      let(:valid_params) { {cart_id: "1234", merchant_id: "5678", order_type: "pickup"} }
      before() do
        allow(Cart).to receive(:find) { valid_loyalty_cart }
      end

      context "pita pit" do
        before(:each) do
          allow(Cart).to receive(:get_checkout) {
            {
              "order_summary" => {
                "receipt_items" => [
                  {
                    "title" => "Points Used",
                    "amount" => "90"
                  },
                  {
                    "title" => "Subtotal",
                    "amount" => "$0.00"
                  },
                  {
                    "title" => "Tax",
                    "amount" => "$0.41"
                  },
                  {
                    "title" => "Total",
                    "amount" => "$0.00"
                  }
                ]
              },
              "lead_times_array" => [1444348099, 1444348159, 1444348219, 1444348279, 1444348339, 1444348399, 1444348459,
                                     1444348519, 1444348579, 1444348639, 1444348699, 1444348819, 1444349119, 1444349419,
                                     1444349719, 1444350019, 1444350319, 1444350619, 1444350919, 1444351219, 1444351519,
                                     1444351819, 1444352119, 1444352419, 1444352719, 1444353019, 1444353319],
              "accepted_payment_types" => [{ "splickit_accepted_payment_type_id" => "3000",
                                             "merchant_payment_type_map_id" => "3022" }],
              "tip_array" => [["No Tip", 0], ["10%", 0.63], ["15%", 0.95], ["20%", 0.20], ["$1.00", 1], ["$2.00", 2]]
            }
          }
        end

        it "assigns @loyalty_payments with the expected data" do
          get :new, params: valid_params
          expect(assigns(:loyalty_payments)).to eq([{ "splickit_accepted_payment_type_id" => "3000",
                                                      "merchant_payment_type_map_id" => "3022" }])
          expect(assigns(:cash_payments)).to eq([])
          expect(assigns(:credit_payments)).to eq([])
        end

        it "assigns vio credentials" do
          vio_credentials_stubs
          get :new, params: valid_params
          expect(assigns(:account)).to eq("splikit")
          expect(assigns(:token)).to eq("vio-token")
        end
      end

      context "moes 2 or more loyalty payments" do
        before(:each) do
          allow(Cart).to receive(:get_checkout) {
            {
              "order_summary" => {
                "receipt_items" => [
                  {
                    "title" => "Points Used",
                    "amount" => "90"
                  },
                  {
                    "title" => "Subtotal",
                    "amount" => "$0.00"
                  },
                  {
                    "title" => "Tax",
                    "amount" => "$0.41"
                  },
                  {
                    "title" => "Total",
                    "amount" => "$0.00"
                  }
                ]
              },
              "lead_times_array" => [1444348099, 1444348159, 1444348219, 1444348279, 1444348339, 1444348399, 1444348459,
                                     1444348519, 1444348579, 1444348639, 1444348699, 1444348819, 1444349119, 1444349419,
                                     1444349719, 1444350019, 1444350319, 1444350619, 1444350919, 1444351219, 1444351519,
                                     1444351819, 1444352119, 1444352419, 1444352719, 1444353019, 1444353319],
              "accepted_payment_types" => [{ "splickit_accepted_payment_type_id" => "3000",
                                             "merchant_payment_type_map_id" => "3022" },
                                           { "splickit_accepted_payment_type_id" => "8000",
                                             "merchant_payment_type_map_id" => "3023" }],
              "tip_array" => [["No Tip", 0], ["10%", 0.63], ["15%", 0.95], ["20%", 0.20], ["$1.00", 1], ["$2.00", 2]]
            }
          }
        end

        it "assigns @loyalty_payments with the expected data" do
          get :new, params: valid_params
          expect(assigns(:loyalty_payments)).to eq([{ "splickit_accepted_payment_type_id" => "3000",
                                                      "merchant_payment_type_map_id" => "3022" },
                                                    { "splickit_accepted_payment_type_id" => "8000",
                                                      "merchant_payment_type_map_id" => "3023" }])
          expect(assigns(:cash_payments)).to eq([])
          expect(assigns(:credit_payments)).to eq([])
        end
      end

      context "tullys" do
        before(:each) do
          allow(Cart).to receive(:get_checkout) {
            {
              "order_summary" => {
                "receipt_items" => [
                  {
                    "title" => "Points Used",
                    "amount" => "90"
                  },
                  {
                    "title" => "Subtotal",
                    "amount" => "$0.00"
                  },
                  {
                    "title" => "Tax",
                    "amount" => "$0.41"
                  },
                  {
                    "title" => "Total",
                    "amount" => "$0.00"
                  }
                ]
              },
              "lead_times_array" => [1444348099, 1444348159, 1444348219, 1444348279, 1444348339, 1444348399, 1444348459,
                                     1444348519, 1444348579, 1444348639, 1444348699, 1444348819, 1444349119, 1444349419,
                                     1444349719, 1444350019, 1444350319, 1444350619, 1444350919, 1444351219, 1444351519,
                                     1444351819, 1444352119, 1444352419, 1444352719, 1444353019, 1444353319],
              "accepted_payment_types" => [
                {
                  "splickit_accepted_payment_type_id" => "7000",
                  "merchant_payment_type_map_id" => "3022"
                }
              ],
              "tip_array" => [["No Tip", 0], ["10%", 0.63], ["15%", 0.95], ["20%", 0.20], ["$1.00", 1], ["$2.00", 2]]
            }
          }
        end

        it "assigns @loyalty_payments with the expected data" do
          get :new, params: valid_params
          expect(assigns(:loyalty_payments)).to eq([{ "splickit_accepted_payment_type_id" => "7000",
                                                      "merchant_payment_type_map_id" => "3022" }])
        end
      end
    end

    context "group order" do
      before do
        session[:order] = { items: [{ item_id: "123" }] }
      end

      let(:valid_params) { { group_order_token: "1234", merchant_id: "5678", order_type: "pickup" } }

      it "assigns @checkout with expected data" do
        get :new, params: valid_params
        expect(assigns(:checkout)).to eq(valid_cart)
      end

      it "assigns @items with expected data" do
        get :new, params: valid_params
        expect(assigns(:items)).to eq([{"item_note" => "extra salty butter", "order_detail_id" => "123"}])
      end

      it "checkout group order" do
        allow(Cart).to receive(:get_checkout) { valid_cart.merge("cart_ucid" => valid_params[:group_order_token]) }
        session[:current_user]["group_order_token"] = valid_params[:group_order_token]

        get :new, params: valid_params.merge(submit: true)
        expect(assigns(:checkout)["cart_ucid"]).to eq(valid_params[:group_order_token])
      end

      it "assigns vio credentials" do
        vio_credentials_stubs
        get :new, params: valid_params
        expect(assigns(:account)).to eq("splikit")
        expect(assigns(:token)).to eq("vio-token")
      end

      context "GroupOrderError" do
        before do
          checkout_stubs(auth_token: "B4C0NTOKEN", cart_id: "test",
                         body: { user_id: "12345", merchant_id: "5678", group_order_token: "1234", user_addr_id: nil,
                                 total_points_used: 0, items: [{ item_id: nil, external_detail_id: nil, quantity: nil,
                                                                 mods: nil, size_id: nil, status: nil, order_detail_id: nil,
                                                                 points_used: nil, brand_points_id: nil, note: nil }] },
                         error: { error: "GO error", error_type: "group_order" })
          session[:order][:meta] = {}
          session[:order][:cart_id] = "test"

          allow(Cart).to receive(:update).and_call_original
          allow(Cart).to receive(:get_checkout).and_call_original
        end

        it "should redirect to checkout page with correct params" do
          get :new, params: valid_params

          expect(response).to redirect_to(new_checkout_path(merchant_id: "5678", reset_dialog: "1", order_type: "pickup"))
        end

        it "should reset cart_id" do
          get :new, params: valid_params

          expect(session[:order][:cart_id]).to be_nil
        end

        it "should clear GO data" do
          get :new, params: valid_params

          expect(session[:group_order]).to be_nil
        end
      end
    end

    context "no items in cart" do
      before do
        session[:order] = { items: [] }
      end

      it "redirects to edit_item with the correct params" do
        get :new, params: valid_params
        expect(response).to redirect_to(empty_cart_path(valid_params))
      end

      it "should redirect if it is a group order" do
        params = { group_order_token: "1234", merchant_id: "5678", order_type: "pickup" }

        get :new, params: params
        expect(response).to redirect_to(empty_cart_path(params))
      end
    end
  end

  describe "#create" do
    let(:valid_params) { { tip: "1.00", note: "bacon please", payment_type: "6703", time: "1234789",
                           order: { merchant_id: "5678", cart_id: "1234", order_type: "pickup" },
                           payment_types_map: "[{\"merchant_payment_type_map_id\":\"5481\",\"name\":\"Cash\",\"splickit_accepted_payment_type_id\":\"1000\",\"billing_entity_id\":null},{\"merchant_payment_type_map_id\":\"6703\",\"name\":\"Credit Card\",\"splickit_accepted_payment_type_id\":\"2000\",\"billing_entity_id\":\"1080\"}]" } }

    let(:no_tip_params) { valid_params.merge(tip: "") }

    let(:cash_no_tip_params) { no_tip_params.merge(payment_type: "5481") }

    let(:merchant_data) { create_merchant("time_zone_offset" => "-5", "show_tip" => true) }
    let(:user) { get_user_data.merge("user_id" => "5555555",
                                     "delivery_locations" => [{ "user_addr_id" => "5001",
                                                                "address1" => "bacon st." }]) }

    shared_examples "failure" do
      it "should set flash message" do
        post :create, params: valid_params
        expect(flash[:error]).to eq(error_message)
      end
    end

    before do
      sign_in(user)
      allow(Merchant).to receive(:info) { merchant_data }
    end

    context "success" do
      before do
        allow(API).to receive_message_chain(:post, :body) { { data: valid_cart }.to_json }
        allow(API).to receive_message_chain(:post, :status) { 200 }

        session[:order] = {}
        session[:order][:items] = [{ item_id: "700",
                                     quantity: "1",
                                     mods: [],
                                     size_id: "800" }]

        cookies[:userPrefs] = "{\"preferredAddressId\":102}"
        session[:current_user]["group_order_token"] = "DA-GO-TOKEN"
      end

      it "submits the order data to the API" do
        expect(API).to receive("post").with("/orders/1234", { user_id: user["user_id"],
                                                              cart_ucid: "1234",
                                                              tip: "1.00",
                                                              note: "bacon please",
                                                              merchant_payment_type_map_id: "6703",
                                                              requested_time: "1234789" }.to_json,
                                            { user_auth_token: user["splickit_authentication_token"] })

        post :create, params: valid_params
      end

      it "assigns @user" do
        post :create, params: valid_params
        expect(assigns(:user)).to be_a(User)
      end

      it "clears the order from the session" do
        expect(session[:order]).not_to be_nil
        post :create, params: valid_params
        expect(session[:order]).to be_nil
      end

      it "redirects to checkout/show" do
        post :create, params: valid_params
        expect(response).to redirect_to(last_order_path)
      end

      context "as group order" do
        before do
          valid_params.merge!(order: { merchant_id: "5678",
                                       cart_id: "1234",
                                       order_type: "pickup",
                                       group_order_token: "123" })
          session[:order] = {}
          session[:order][:cart_id] = "1234"
          session[:order][:items] = [{ item_id: "700",
                                       quantity: "1",
                                       mods: [],
                                       size_id: "800" }]
          session[:group_order] = { type: 1 }
        end

        it "should clear group_order_token and order from the session" do
          expect(session[:order]).not_to be_nil
          expect(session[:current_user]["group_order_token"]).not_to be_nil
          post :create, params: valid_params
          expect(session[:order]).to be_nil
          expect(session[:current_user]["group_order_token"]).to be_nil
        end

        it "assigns @group_order_token with a UserFavorite object" do
          post :create, params: valid_params
          expect(assigns(:group_order_token)).to eq("123")
        end

        context "failure" do
          let(:error_message) { "burguers" }

          context "API error" do
            before do
              allow(API).to receive_message_chain(:post, :body) { { error: { error: error_message } }.to_json }
              allow(API).to receive_message_chain(:post, :status) { 402 }
            end

            it_behaves_like "failure"

            it "redirects back to the checkout page with group_order_token" do
              post :create, params: valid_params
              expect(response).to redirect_to(new_checkout_path(merchant_id: valid_params[:order][:merchant_id],
                                                                order_type: valid_params[:order][:order_type],
                                                                group_order_token: valid_params[:order][:group_order_token]))
            end

            context "no order" do
              before do
                session[:order] = nil
              end

              it "should redirect to merchant path with group_order_token" do
                post :create, params: valid_params
                expect(response).to redirect_to(merchant_path(valid_params[:order][:merchant_id],
                                                              order_type: valid_params[:order][:order_type],
                                                              group_order_token: valid_params[:order][:group_order_token]))
              end
            end
          end
        end
      end

      context "user left no tip" do
        before do
          valid_params.merge!(tip: "")
        end

        context "cash_order" do
          before do
            payments = JSON.parse(valid_params[:payment_types_map])
            cash_payment = payments.find { |payment| payment["splickit_accepted_payment_type_id"] == "1000" }
            valid_params.merge!(payment_type: cash_payment["merchant_payment_type_map_id"])
          end

          it "should redirect to last order path" do
            post :create, params: valid_params
            expect(response).to redirect_to(last_order_path)
          end
        end

        context "group order type 1 submit false" do
          before do
            valid_params.merge!(order: { merchant_id: "5678",
                                         cart_id: "1234",
                                         order_type: "pickup",
                                         group_order_token: "123" })
            session[:group_order] = { type: 1 }
          end

          it "should redirect to last order path" do
            post :create, params: valid_params
            expect(response).to redirect_to(last_order_path)
          end
        end

        context "merchant no show tip" do
          let(:no_tip_merchant_data) { create_merchant("time_zone_offset" => "-5", "show_tip" => false) }

          before do
            allow(Merchant).to receive(:info) { no_tip_merchant_data }
          end

          it "should redirect to last order path" do
            post :create, params: valid_params
            expect(response).to redirect_to(last_order_path)
          end
        end
      end
    end

    context "failure" do
      let(:error_message) { "burgers" }

      before do
        session[:order] = {}
        session[:order][:cart_id] = "1234"
        session[:order][:items] = [{ item_id: "700",
                                     quantity: "1",
                                     mods: [],
                                     size_id: "800" }]

        allow(API).to receive_message_chain(:post, :body) { { error: { error: error_message } }.to_json }
        allow(API).to receive_message_chain(:post, :status) { 402 }
      end

      it_behaves_like "failure"

      it "redirects back to the checkout page" do
        post :create, params: valid_params
        expect(response).to redirect_to(new_checkout_path(merchant_id: "5678", order_type: "pickup"))
      end

      context "no order" do
        before do
          session[:order] = nil
        end

        it "should redirect to merchant path" do
          post :create, params: valid_params
          expect(response).to redirect_to(merchant_path(valid_params[:order][:merchant_id],
                                                        order_type: valid_params[:order][:order_type]))
        end
      end

      context "user left no tip" do
        before do
          valid_params.merge!(tip: "")
        end

        context "no cash order" do
          it "should raise Missing Tip error" do
            post :create, params: valid_params
            expect(response).to redirect_to(new_checkout_path(merchant_id: valid_params[:order][:merchant_id],
                                                              order_type: valid_params[:order][:order_type]))
          end
        end

        context "merchant show tip" do
          it "should raise Missing Tip error" do
            post :create, params: valid_params
            expect(response).to redirect_to(new_checkout_path(merchant_id: valid_params[:order][:merchant_id],
                                                              order_type: valid_params[:order][:order_type]))
          end
        end

        context "group order type 1 submit true" do
          before do
            valid_params.merge!(order: { merchant_id: "5678",
                                         cart_id: "1234",
                                         order_type: "pickup",
                                         group_order_token: "123" })
            session[:group_order] = { type: 1, submit: true }
          end

          it "should raise Missing Tip error" do
            post :create, params: valid_params
            expect(response).to redirect_to(new_checkout_path(merchant_id: valid_params[:order][:merchant_id],
                                                              order_type: valid_params[:order][:order_type],
                                                              group_order_token: valid_params[:order][:group_order_token]))
          end
        end

        context "group order type 2" do
          before do
            valid_params.merge!(order: { merchant_id: "5678",
                                         cart_id: "1234",
                                         order_type: "pickup",
                                         group_order_token: "123" })
            session[:group_order] = { type: 2 }
          end

          it "should raise Missing Tip error" do
            post :create, params: valid_params
            expect(response).to redirect_to(new_checkout_path(merchant_id: valid_params[:order][:merchant_id],
                                                              order_type: valid_params[:order][:order_type],
                                                              group_order_token: valid_params[:order][:group_order_token]))
          end
        end
      end
    end
  end

  describe "#show" do
    let(:valid_params) { { id: "2122" } }
    let(:merchant_data) { create_merchant({"time_zone_offset" => "-5"}) }

    before do
      user = get_user_data.merge("user_id" => "12345",
                                 "first_name" => "barnis",
                                 "email" => "tom@bom.com",
                                 "splickit_authentication_token" => "B4C0NTOKEN")

      sign_in(user)

      session[:last_order] = {
        order_type: 'delivery',
        order: { 'order_type' => 'delivery',
                 'merchant_id' => '1082' },
        confirmation: valid_cart.merge("user_delivery_address" => { "user_addr_id" => "1234",
                                                                    "address1" => "bacon st." },
                                       "user_delivery_location_id" => "1234")
      }

      allow(Merchant).to receive(:info) { merchant_data }
    end

    it "assigns @delivery_address" do
      get :show, params: valid_params
      expect(assigns(:delivery_address)).to eq("user_addr_id" => "1234", "address1" => "bacon st.")
    end

    it "assigns @confirmation with the expected data" do
      get :show, params: valid_params
      expect(assigns(:confirmation)).to eq(valid_cart.merge("user_delivery_address" => { "user_addr_id" => "1234",
                                                                                         "address1" => "bacon st." },
                                                            "user_delivery_location_id" => "1234"))
    end

    it "assigns @order_type with the expected data" do
      get :show, params: valid_params
      expect(assigns(:order_type)).to eq('delivery')
    end

    it "assigns @order_receipt with the expected data" do
      get :show, params: valid_params
      expect(assigns(:order_receipt)).to eq([{ "title" => "Promo Discount",
                                               "amount" => "$-1.00" },
                                             { "title" => "Subtotal",
                                               "amount" => "$6.89" },
                                             { "title" => "Tax",
                                               "amount" => "$0.41" }])
    end

    it "assigns @user_favorite with a UserFavorite object" do
      get :show, params: valid_params
      expect(assigns(:user_favorite)).to be_kind_of(UserFavorite)
    end

    it "assigns @merchant with the expected data" do
      get :show, params: valid_params
      expect(assigns(:merchant)).to eq(merchant_data)
    end

    it "assigns @payment_items to empty array if it is nil" do
      get :show, params: valid_params
      expect(assigns(:payment_items)).to eq([])
    end

    it "assigns @payment_items to correct array" do
      payment_items =[{ "title" => "Credit Card",
                        "amount" => "$1.45" }]
      session[:last_order][:confirmation] = valid_cart.merge("order_summary" => { "payment_items" => payment_items })
      get :show, params: valid_params
      expect(assigns(:payment_items)).to eq(payment_items)
    end

    context "guest user" do
      before do
        sign_in(get_user_data.merge("flags" => "1C21000021"))
      end

      it "should clear current user" do
        get :show, params: {}
        expect(session[:current_user]).to be_nil
      end
    end

    context "group order" do
      let(:group_order_token) { "123" }

      before do
        session[:last_order] = {}
        session[:last_order][:order] = { group_order_token: group_order_token }
      end

      it "assigns @group_order_token with a UserFavorite object" do
        get :show, params: valid_params
        expect(assigns(:group_order_token)).to eq(group_order_token)
      end
    end
  end

  describe "#empty_cart" do
    context "with valid params" do
      it "redirects to the correct merchant w/ valid params" do
        get :empty_cart, params: { merchant_id: 1234, order_type: "pickup" }
        expect(assigns(:add_more_items_href)).to eq(merchant_path(1234, order_type: "pickup"))
      end

      it "renders the correct partial" do
        get :empty_cart, params: { merchant_id: 1234, order_type: "pickup" }
        expect(response).to render_template(:empty_cart)
      end

      it "returns the correct status code" do
        get :empty_cart, params: { merchant_id: 1234, order_type: "pickup" }
        expect(response.status).to eq(200)
      end
    end

    context "without valid params" do
      it "assigns the @add_more_items_href correctly" do
        get :empty_cart
        expect(assigns(:add_more_items_href)).to eq(root_path)
      end
    end
  end

  describe "#apply_promo" do
    before do
      user = get_user_data.merge("user_id" => "12345",
                                 "first_name" => "barnis",
                                 "email" => "tom@bom.com",
                                 "splickit_authentication_token" => "B4C0NTOKEN",
                                 "delivery_locations" => [{ "user_addr_id" => "1234",
                                                            "address1" => "bacon st." }])
      sign_in(user)

      session[:order] = { cart_id: "123", items: [], meta: {} }
    end

    context "its a valid promo" do
      it "should assign flash:notice" do
        cart_promo_stub(auth_token: "B4C0NTOKEN", promo_code: "lucky", cart_id: "123",
                        message: "Congratulations!  You're geting $1.00 off your current order!")

        post :apply_promo, xhr: true, params: { promo_code: "lucky" }
        expect(flash[:notice]).to eq "Congratulations!  You're geting $1.00 off your current order!"
        expect(assigns[:order_receipt]).to eq([{ "title" => "Promo Discount", "amount" => "$-1.00" },
                                               { "title" => "Subtotal", "amount" => "$6.89" },
                                               { "title" => "Tax", "amount" => "$0.41" }])
      end

      it "should not assign flash:notice" do
        cart_promo_stub(auth_token: "B4C0NTOKEN", promo_code: "lucky", cart_id: "123")

        post :apply_promo, xhr: true, params: { promo_code: "lucky" }
        expect(flash[:notice]).to be_nil
        expect(assigns[:order_receipt]).to eq([{ "title" => "Promo Discount", "amount" => "$-1.00" },
                                               { "title" => "Subtotal", "amount" => "$6.89" },
                                               { "title" => "Tax", "amount" => "$0.41" }])
      end
    end

    context "invalid promo" do
      it "should assign flash:alert" do
        cart_promo_stub(auth_token: "B4C0NTOKEN", promo_code: "invalid", cart_id: "123",
                        error: { error: "error_message", error_type: "promo" })
        post :apply_promo, xhr: true,  params: { promo_code: "invalid" }
        expect(flash[:error]).to eq "error_message"
      end
    end
  end
end
