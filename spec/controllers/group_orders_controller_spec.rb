require "rails_helper"

describe GroupOrdersController do
  describe "GET show" do
    let(:group_order_token) { "L2N9V-08ERQ" }

    context "success" do
      let(:group_order) { {
        "notes" => "Lunch on me.",
        "merchant_id" => "1234",
        "group_order_token" => group_order_token}
      }

      let(:merchant) {
        Merchant.new({
                       "name" => "Hammersmith Folly",
                       "address1" => "Something St.",
                       "address2" => "#105",
                       "city" => "Denver",
                       "state" => "CO",
                       "zip" => "50505",
                     })
      }

      before(:each) do
        user = get_user_data.merge("email"=>"tom@bom.com")
        sign_in(user)
        allow(GroupOrder).to receive(:find) { group_order }
        allow(Merchant).to receive(:info) { merchant }
      end

      it "has a 200 status code" do
        get :show, params: { id: group_order_token }
        expect(response.code).to eq("200")
      end

      it "assigns @group_order" do
        get :show, params: { id: group_order_token }
        expect(assigns(:group_order)).to eq(group_order)
      end

      it "assigns @merchant" do
        get :show, params: { id: group_order_token }
        expect(assigns(:merchant)).to eq(merchant)
      end

      it "renders @group_order" do
        get :show, params: { id: group_order_token }
        expect(response).to render_template(:show)
      end

      it "stores the group order token in the session" do
        get :show, params: { id: group_order_token }
        expect(assigns[:user].group_order_token).to eq(group_order_token)
        expect(session[:current_user]["group_order_token"]).to eq(group_order_token)
      end

      context "AJAX request for JSON" do
        before(:each) do
          request.env["HTTP_ACCEPT"] = 'application/json'
        end

        it "returns a @group_order as json" do
          get :show, params:  { id: group_order_token }
          expect(response.body).to eq(group_order.to_json)
        end
      end
    end

    context "failure" do
      before(:each) do
        user = get_user_data.merge("email"=>"tom@bom.com", "group_order_token"=>nil)
        sign_in(user)
        allow(GroupOrder).to receive(:find).and_raise(APIError.new("We ate a cat."))
      end

      it "redirects to the root_path" do
        get :show, params: { id: group_order_token }
        expect(response).to redirect_to(root_path)
      end

      it "displays a failure message" do
        get :show, params: { id: group_order_token }
        expect(flash[:error]).to eq("We ate a cat.")
      end

      it "doesn't store the group order token in the session" do
        get :show, params: { id: group_order_token }
        expect(session[:current_user]["group_order_token"]).to be_nil
      end
    end
  end

  describe "#admin_redirect_if_signed_out" do
    before { sign_out }

    it "should redirect with admin params to sign in page" do
      get :new, params: { merchant_id: 1, order_type: "pickup" }
      expect(response).to redirect_to(sign_in_path(continue: request.fullpath, admin_login: "1"))
    end
  end

  describe "#new" do
    let(:valid_params) { {merchant_id: 1, order_type: "pickup"} }
    let(:merchant) {
      Merchant.new({
        "name" => "Hammersmith Folly",
        "address1" => "Something St.",
        "address2" => "#105",
        "city" => "Denver",
        "state" => "CO",
        "zip" => "50505",
      })
    }

    before do
      allow(Merchant).to receive(:info) { merchant }
      user = get_user_data.merge("email"=>"tom@bom.com")
      sign_in(user)
    end

    context "valid params" do
      # let(:merchant) { {name: "Bacon Land"} }

      it "has a 200 status code" do
        get :new, params: valid_params
        expect(response.code).to eq("200")
      end

      it "assigns @merchant" do
        get :new, params: valid_params
        expect(assigns(:merchant)).to eq(merchant)
      end

      it "assigns @group_order" do
        get :new, params: valid_params
        expect(assigns(:group_order).participant_emails).to eq(nil)
        expect(assigns(:group_order).notes).to eq(nil)
        expect(assigns(:group_order).merchant_menu_type).to eq(nil)
      end

      it "assigns @group_order w/ valid passed params" do
        get :new, params: { merchant_id: 1, notes: "more bacon", participant_emails: "tom@bom.com", merchant_menu_type: "delivery" }
        expect(assigns(:group_order).participant_emails).to eq("tom@bom.com")
        expect(assigns(:group_order).notes).to eq("more bacon")
        expect(assigns(:group_order).merchant_menu_type).to eq("delivery")
      end

      it "renders the :new view" do
        get :new, params: valid_params
        expect(response).to render_template(:new)
      end
    end

    context "invalid params" do
      it "redirects to the root_path" do
        get :new
        expect(response).to redirect_to(root_path)
      end

      it "displays a failure message" do
        get :new
        expect(flash[:error]).to eq("Invalid merchant.")
      end
    end

    context "delivery" do
      let(:valid_params) { {merchant_id: 1, order_type: "delivery", user_addr_id: "666"} }

      context "delivery not in range" do
        before(:each) do
          allow(Merchant).to receive(:in_delivery_area?) { false }
        end

        it "redirects to the root_path" do
          get :new, params: valid_params
          expect(response).to redirect_to(root_path)
        end

        it "redirects with the user specified zip" do
          session[:location] = "12345"
          get :new, params: valid_params
          expect(response).to redirect_to(root_path(location: "12345"))
        end

        it "sets the correct flash message" do
          get :new, params: valid_params
          expect(response.request.flash[:error]).to eq("Sorry, that address isn't in range.")
        end
      end

      context "delivery address is in rage" do
        before(:each) do
          allow(Merchant).to receive(:in_delivery_area?) { true }
        end

        it 'should render page' do

        end
      end
    end

    context "API error" do
      before do
        allow(Merchant).to receive(:info) { raise APIError.new("Oh crap!") }
      end

      it 'should redirect to root path' do
        get :new, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it 'should display error message' do
        get :new, params: valid_params
        expect(flash[:error]).to eq("Oh crap!")
      end
    end
  end

  describe "#create" do
    let(:valid_params) { {
      group_order: {
        participant_emails: "bob@tom.com",
        notes: "make much big",
        merchant_menu_type: "pickup",
        merchant_id: "5788"
      }
    } }

    let(:valid_delivery_params) { {
      group_order: {
        participant_emails: "bob@tom.com",
        notes: "make much big",
        merchant_menu_type: "pickup",
        merchant_id: "5788",
        user_addr_id: "1988"
      }
    } }

    context "success" do
      let(:valid_response) { {"group_order_token" => "L2N9V-08ERQ"} }

      before(:each) do
        user = get_user_data.merge("email"=>"tom@bom.com")
        sign_in(user)
        allow(GroupOrder).to receive(:save) { valid_response }
      end

      it "has a 302 status code" do
        post :create, params: valid_params
        expect(response.code).to eq("302")
      end

      it "assigns @group_order" do
        post :create, params: valid_params
        expect(assigns(:group_order)).to eq(valid_response)
      end

      it "redirects to group_orders#show" do
        post :create, params: valid_params
        expect(response).to redirect_to(group_order_path("L2N9V-08ERQ"))
      end

      it "displays a success message" do
        get :create, params: valid_params
        expect(flash[:notice]).to eq("Group order successfully created!")
      end

      it "doesn't set the users preferred address ID" do
        get :create, params: valid_params
        expect(cookies[:userPrefs]).to eq(nil)
      end

      context "delivery order" do
        it "sets the users preferred address ID" do
          get :create, params: valid_delivery_params
          expect(cookies[:userPrefs]).to eq("{\"preferredAddressId\":\"1988\"}")
        end
      end
    end

    context "API failure" do
      before(:each) do
        user = get_user_data.merge("email"=>"tom@bom.com")
        sign_in(user)
        allow(API).to receive_message_chain(:post, :body) { {error: {error: "We barfed that up."}}.to_json }
        allow(API).to receive_message_chain(:post, :status) { 500 }
      end

      it "redirects to the group_orders/new" do
        post :create, params: valid_params
        expect(response).to redirect_to(new_group_orders_path(valid_params[:group_order]))
      end

      it "displays a failure message" do
        post :create, params: valid_params
        expect(flash[:error]).to eq("We barfed that up.")
      end
    end

    context "Invalid emails" do
      let(:invalid_params) { {
        group_order: {
          participant_emails: "bob.tom.com",
          notes: "make much big",
          merchant_menu_type: "pickup",
          merchant_id: "5788"
        }
      } }

      before(:each) do
        user = get_user_data.merge("email"=>"tom@bom.com")
        sign_in(user)
      end

      it "redirects to the group_orders/new" do
        post :create, params: invalid_params
        expect(response).to redirect_to(new_group_orders_path(invalid_params[:group_order]))
      end

      it "displays a failure message" do
        post :create, params: invalid_params
        expect(flash[:error]).to eq("The list of participants includes invalid emails")
      end
    end
  end

  describe "#add_items" do
    let(:merchant_id) { "5555" }
    let(:user_id) { "1234" }

    before(:each) do
      user = get_user_data.merge("email"=>"tom@bom.com", "user_id"=>user_id)
      sign_in(user)
    end

    context "success" do
      let(:valid_params) { {group_order_token: "kitty-001", merchant_id: merchant_id, order_type: "delivery"} }
      let(:items_params) { {
        :user_id => user_id,
        :merchant_id => merchant_id,
        :items => [
          {
            :item_id => "666",
            :quantity => "1",
            :mods => [],
            :size_id => "7",
            :note => "more bacon"
          }]
      } }

      before(:each) do
        session[:order] = {}
        session[:order][:items] = [{"item_id" => "666", "quantity" => "1", "mods" => [], "size_id" => "7", "note" => "more bacon"}]
        allow(API).to receive_message_chain(:post, :body) { {}.to_json }
        allow(API).to receive_message_chain(:post, :status) { 200 }
      end

      it "calls GroupOrder.add_item with the correct params" do
        expect(GroupOrder).to receive(:add_items)
          .with("kitty-001",
                items_params,
                { user_auth_token: session[:current_user]["splickit_authentication_token"] })
        get :add_items, params: valid_params
      end

      it "removes the order from the session" do
        expect(session[:order]).not_to be_nil
        get :add_items, params: valid_params
        expect(session[:order]).to be_nil
      end

      context "group order admin" do
        before(:each) do
          user = get_user_data.merge("group_order_token" => valid_params[:group_order_token])
          sign_in(user)
        end

        it "redirects to the group order show page" do
          get :add_items, params: valid_params
          expect(response).to redirect_to(group_order_path(valid_params[:group_order_token]))
        end

        it "displays the correct flash message" do
          get :add_items, params: valid_params
          expect(response.request.flash[:notice]).to eq("Item added successfully")
        end

        it "has a 302 status code" do
          get :add_items, params: valid_params
          expect(response.code).to eq("302")
        end
      end

      context "group order invitee" do
        before(:each) do
          user = get_user_data.merge("group_order_token"=>nil)
          sign_in(user)
        end

        it "has a 302 status code" do
          get :add_items, params: valid_params
          expect(response.code).to eq("302")
        end

        it "redirects to the group order show page" do
          get :add_items, params: valid_params
          expect(response).to redirect_to(confirmation_group_orders_path)
        end
      end
    end

    context "failure" do
      context "api failure" do
        let(:valid_params) { {group_order_token: "kitty-001", merchant_id: merchant_id} }

        before(:each) do
          session[:order] = {}
          session[:order][:items] = [{ "item_id" => "666",
                                       "quantity" => "1",
                                       "mods" => [],
                                       "size_id" => "7" }]
          allow(API).to receive_message_chain(:post, :body) { {error: {error: "We ate a donkey."}}.to_json }
          allow(API).to receive_message_chain(:post, :status) { 500 }
        end

        it "redirects to the root_path" do
          get :add_items, params: valid_params
          expect(response).to redirect_to(merchant_path(merchant_id, valid_params))
        end

        it "displays a failure message" do
          get :add_items, params: valid_params
          expect(flash[:error]).to eq("We ate a donkey.")
        end

        it "doesn't remove the order from the session" do
          expect(session[:order]).not_to be_nil
          get :add_items, params: valid_params
          expect(session[:order]).not_to be_nil
        end
      end
    end
  end

  describe "#remove_item" do
    let(:valid_user) { {email: "tom@bom.com", password: "welcome"} }
    let(:valid_params) { {item_id: "619238", group_order_token: "5436-4w89q-v8j88-8t2v9"} }
    let(:valid_response) { {"order_summary" => {"cart_items" => [{}, {}]}} }

    before do
      user = get_user_data.merge("email"=>"tom@bom.com", "splickit_authentication_token" => "BANANAS")
      sign_in(user)
    end

    context "success" do
      before(:each) do
        allow(API).to receive_message_chain(:delete, :body) { {"data" => valid_response}.to_json }
        allow(API).to receive_message_chain(:delete, :status) { 200 }
      end

      it "calls GroupOrder.add_item with the correct params" do
        allow_any_instance_of(GroupOrdersController).to receive(:number_of_items) { 55 }
        expect(GroupOrder).to receive(:remove_item).with({ "item_id" => "619238",
                                                           "group_order_token" => "5436-4w89q-v8j88-8t2v9" },
                                                         { user_auth_token: "BANANAS" })

        delete :remove_item, params: valid_params
      end

      it "returns a 200 status code" do
        delete :remove_item, params: valid_params
        expect(response.code).to eq("200")
      end

      it "assigns @group_order with the response data" do
        delete :remove_item, params: valid_params
        expect(assigns(:group_order)).to eq(valid_response)
      end

      it "returns a JSON response w/ the expected response values" do
        delete :remove_item, params: valid_params
        expect(response.body).to eq({itemID: valid_params[:item_id], itemCount: 2}.to_json)
      end
    end

    context "failure" do
      before(:each) do
        allow(API).to receive_message_chain(:delete, :body) { {error: {error: "Our CPU had a stroke."}}.to_json }
        allow(API).to receive_message_chain(:delete, :status) { 505 }
      end

      it "returns a 500 status code" do
        delete :remove_item, params: valid_params
        expect(response.code).to eq("500")
      end

      it "returns a JSON response w/ the deleted item_id and error message" do
        delete :remove_item, params: valid_params
        expect(response.body).to eq({
                                      item_id: valid_params[:item_id],
                                      message: "Our CPU had a stroke."
                                    }.to_json)
      end
    end
  end

  describe "#destroy" do
    let(:valid_params) { {id: "L2N9V-08ERQ"} }

    context "success" do
      let(:group_order) { { "notes" => "Lunch on me.",
                            "merchant_id" => "1234",
                            "status" => "cancelled" } }

      before(:each) do
        user = get_user_data.merge("email" => "tom@bom.com",
                                   "group_order_token" => valid_params[:id])
        sign_in(user)
        allow(API).to receive_message_chain(:delete, :body) { { data: group_order }.to_json }
        allow(API).to receive_message_chain(:delete, :status) { 200 }
      end

      it "clears the group order token from session" do
        expect(session[:current_user]["group_order_token"]).to eq(valid_params[:id])
        delete :destroy, params: valid_params
        expect(session[:current_user]["group_order_token"]).to eq(nil)
      end

      it "redirects to root_path" do
        delete :destroy, params: valid_params
        expect(response).to redirect_to root_path
      end

      it "displays a success message" do
        delete :destroy, params: valid_params
        expect(flash[:notice]).to eq("Your group order was cancelled")
      end
    end

    context "failure" do
      before(:each) do
        user = get_user_data.merge("email"=>"tom@bom.com")
        sign_in(user)
        allow(API).to receive_message_chain(:delete, :body) { {error: {error: "We ate a cat."}}.to_json }
        allow(API).to receive_message_chain(:delete, :status) { 500 }
      end

      it "redirects to the root_path" do
        delete :destroy, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it "displays a failure message" do
        delete :destroy, params: valid_params
        expect(flash[:error]).to eq("We ate a cat.")
      end
    end
  end

  describe "#increment" do
    before do
      sign_in(get_user_data)
    end

    context "success" do
      before do
        group_order_increment_stub(auth_token: "ASNDKASNDAS")
      end

      it "should assign group order" do
        post :increment, params: { id: "9109-nyw5d-g8225-irawz", time: "10" }

        expect(assigns[:group_order]).to eq("group_order_id" => "2290", "group_order_token" => "9109-nyw5d-g8225-irawz",
                                            "merchant_id" => "102237", "sent_ts" => "0000-00-00 00 =>00 =>00", "notes" => "",
                                            "participant_emails" => "", "merchant_menu_type"=>"pickup", "expires_at"=>"1421789477",
                                            "send_on_local_time_string" => "9:31 pm", "group_order_type" => "1", "status"=>"active",
                                            "group_order_admin" => { "first_name" => "mr", "last_name" => "bean",
                                                                     "email" => "mr@bean.com", "admin_uuid"=>"1195-vdi97-q2kug-38j07" },
                                            "order_summary" => nil)
      end

      it "should redirect to group order path" do
        post :increment, params: { id: "9109-nyw5d-g8225-irawz", time: "10" }

        expect(response).to redirect_to(group_order_path("9109-nyw5d-g8225-irawz"))
      end

      context "ajax" do
        before do
          change_to_json_request
        end

        it "should return group order as json" do
          post :increment, xhr: true, params: { id: "9109-nyw5d-g8225-irawz", time: "10" }

          expect(JSON.parse(response.body)).to eq("group_order_id" => "2290", "group_order_token" => "9109-nyw5d-g8225-irawz",
                                                  "merchant_id" => "102237", "sent_ts" => "0000-00-00 00 =>00 =>00", "notes" => "",
                                                  "participant_emails" => "", "merchant_menu_type"=>"pickup", "expires_at"=>"1421789477",
                                                  "send_on_local_time_string" => "9:31 pm", "group_order_type" => "1", "status"=>"active",
                                                  "group_order_admin" => { "first_name" => "mr", "last_name" => "bean",
                                                                           "email" => "mr@bean.com", "admin_uuid"=>"1195-vdi97-q2kug-38j07" },
                                                  "order_summary" => nil)
          expect(response.status).to eq(200)
        end
      end
    end

    context "API error" do
      before do
        group_order_increment_stub(auth_token: "ASNDKASNDAS", error: { error: "error_message" })
      end

      it "should redirect to group order path" do
        post :increment, params: { id: "9109-nyw5d-g8225-irawz", time: "10" }

        expect(response).to redirect_to(group_order_path("9109-nyw5d-g8225-irawz"))
      end

      context "ajax" do
        before do
          change_to_json_request
        end

        it "should return a unprocessable entity response" do
          post :increment, xhr: true, params: { id: "9109-nyw5d-g8225-irawz", time: "10" }

          expect(response.body).to eq("Error_message")
          expect(response.status).to eq(422)
        end
      end
    end
  end

  describe "#confirmation" do
    before() do
      user = get_user_data.merge("email"=>"tom@bom.com")
      sign_in(user)
    end

    it "renders confirmation" do
      get :confirmation
      expect(response).to render_template(:confirmation)
    end
  end

  describe "#inactive" do
    before do
      sign_in(get_user_data.merge("email"=>"tom@bom.com"))
    end

    it "renders the inactive template" do
      get :inactive
      expect(response).to render_template(:inactive)
    end
  end
end
