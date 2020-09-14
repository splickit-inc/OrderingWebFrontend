require "rails_helper"
require 'api'

describe UserPaymentsController do
  describe "#new" do
    before(:each) do
      sign_in(get_user_data)
      vio_credentials_stubs
    end

    it "assigns the current user to @user" do
      get :new, params: {}
      expect(assigns(:user).user_id).to eq("2")
      expect(assigns(:user).first_name).to eq("bob")
      expect(assigns(:user).last_name).to eq("roberts")
    end

    it "should assign @token and @account" do
      get :new, params: {}
      expect(assigns(:account)).to eq("splikit")
      expect(assigns(:token)).to eq("vio-token")
    end

    it "renders 'users/payment_method'" do
      get :new, params: {}
      expect(response).to render_template("users/payment_method")
    end
  end

  describe "#destroy" do
    before(:each) do
      sign_in(get_user_data.merge({"flags" => "1000000001"}))
      delete_credit_card_stub
    end

    it "should return successfully message" do
      delete :destroy, params: {}
      expect(assigns(:user).user_id).to eq("2")
      expect(flash[:notice]).to eq 'Your credit card has been deleted.'
      expect(assigns(:user).flags).to eq("1000000001")
    end
  end

  describe "#create" do
    before(:each) do
      sign_in(get_user_data)
    end

    context "before filter" do
      let(:valid_params) { { vio: { token: "vio_token", account: "splikit" },
                             valueio_token: "vio-token",
                             replace: "false", continue: "/" } }
      it "should save continue param" do
        stubs_for_valid_update_payment
        post :create, params: valid_params
        expect(subject).to redirect_to("/")
      end
    end

    context "error response" do
      let(:invalid_params) { { vio: { token: "vio_token", account: "splikit" },
                               valueio_token: "vio-token",
                               replace: "false" } }

      before(:each) do
        stub_request(:post, "#{ API.protocol }://splickit_authentication_token:ASNDKASNDAS@#{ API.domain }#{ API.base_path }/users/2").
          with(
            :body => "{\"credit_card_saved_in_vault\":false,\"credit_card_token_single_use\":\"vio-token\"}").
          to_return(
            :status => 200,
            :body => {error: {error: "Bad things happened."}}.to_json)
      end

      it "redirects to 'new'" do
        post :create, params: invalid_params
        expect(response).to redirect_to(new_user_payment_path)
      end

      it "sets the correct flash message" do
        post :create, params: invalid_params
        expect(flash[:error]).to eq("Bad things happened.")
      end
    end

    context "valid response" do
      let(:valid_params) { { vio: { token: "vio_token", account: "splikit" },
                             valueio_token: "vio-token",
                             replace: "false" } }

      before(:each) do
        stubs_for_valid_update_payment
      end

      it "calls update with the correct params" do
        expect(User).to receive(:update).with({ credit_card_saved_in_vault: false, credit_card_token_single_use: "vio-token" }, "2", "ASNDKASNDAS")
        post :create, params: valid_params
      end

      it "updates last four session" do
        post :create, params: valid_params
        expect(session[:current_user]["last_four"]).to eq("1111")
      end

      context "continue param" do
        it "redirects to continue param" do
          session[:continue] = "bob"
          post :create, params: valid_params
          expect(response).to redirect_to("bob")
        end
      end

      context "no continue param" do
        it "redirects to 'new'" do
          post :create, params: valid_params
          expect(response).to redirect_to(new_user_payment_path)
        end
      end

      it "sets the correct flash message" do
        post :create, params: valid_params
        expect(flash[:notice]).to eq("Your card was successfully updated.")
      end
    end
  end
end