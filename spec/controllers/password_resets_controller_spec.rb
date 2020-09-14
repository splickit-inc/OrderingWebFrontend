require "rails_helper"
require 'api'

describe PasswordResetsController do

  before(:each) { enable_ssl }

  describe "#request_email" do
    it "should render the request_email template" do
      request.env['HTTPS'] = 'on'
      get :request_email
      expect(subject).to render_template("password_resets/request_email")
    end
  end

  describe "#request_token" do
    context "successful request" do
      before(:each) do
        stub_request(:get, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users/forgotpassword?email=kenny@powers.com").
          with().
          to_return(
          :status => 200,
          :body => {data: {user_message: "succsss!"}}.to_json)
      end

      it "should render the request_token template with the given email parameter" do
        get :request_token, params: { email: "kenny@powers.com" }
        expect(assigns(:email)).to eq("kenny@powers.com")
        expect(subject).to render_template("password_resets/email_sent")
      end
    end

    context "unsuccessful request" do
      before(:each) do
        stub_request(:get, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users/forgotpassword?email=kenny@powers.com").
          with().
          to_return(
          :status => 200,
          :body => {error: {error: "failure!"}}.to_json)
      end

      it "redirects to request_email_path" do
        get :request_token, params: { email: "kenny@powers.com" }
        expect(response).to redirect_to(request_email_path)
      end

      it "sets the correct flash messages" do
        get :request_token, params: { email: "kenny@powers.com" }
        expect(response.request.flash[:error]).to eq("failure!")
      end
    end

    context "no email address provided" do
      it "redirects to request_email_path" do
        get :request_token
        expect(response).to redirect_to(request_email_path)
      end

      it "sets the correct flash messages" do
        get :request_token
        expect(response.request.flash[:error]).to eq("Please enter a valid email.")
      end    end
  end

  describe "#request_reset" do
    it "should render the request_reset template with the given token parameter" do
      request.env['HTTPS'] = 'on'
      get :request_reset, params: { token: "twizzlersmakemouthshappy" }
      expect(assigns(:token)).to eq("twizzlersmakemouthshappy")
      expect(subject).to render_template("password_resets/request_reset")
    end
  end

  describe "#update_password" do
    context "valid password" do
      before(:each) do
        stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users/resetpassword").
          with(
          :body => "{\"token\":\"41p$t3r$h03$\",\"password\":\"baconlover\"}").
          to_return(
          :status => 200,
          :body => {body: {user_message: "nice work"}}.to_json)
      end

      it "redirects to the sign_in_path" do
        post :update_password, params: { token: "41p$t3r$h03$", password: "baconlover", confirm: "baconlover" }
        expect(response).to redirect_to sign_in_path(continue: root_path)
      end

      it "sets the correct flash message" do
        post :update_password, params: { token: "41p$t3r$h03$", password: "baconlover", confirm: "baconlover" }
        expect(response.request.flash[:notice]).to eq("Your password has been reset. Please sign in below.")
      end
    end

    context "new password is too short" do
      it "redirects to the request_reaet_path with the correct params" do
        post :update_password, params: { token: "old-tolkien", password: "hi", confirm: "hi" }
        expect(response).to redirect_to request_reset_path(token: "old-tolkien")
      end

      it "sets the correct flash message" do
        post :update_password, params: { token: "old-tolkien", password: "hi", confirm: "hi" }
        expect(response.request.flash[:error]).to eq("Password must be at least 8 characters in length.")
      end
    end

    context "new password doesn't match password confirmation" do
      it "redirects to the request_reaet_path with the correct params" do
        post :update_password, params: { token: "old-tolkien", password: "firstpassword", confirm: "secondpassword" }
        expect(response).to redirect_to request_reset_path(token: "old-tolkien")
      end

      it "sets the correct flash message" do
        post :update_password, params: { token: "old-tolkien", password: "firstpassword", confirm: "secondpassword" }
        expect(response.request.flash[:error]).to eq("Password confirmation must match your password.")
      end
    end

    context "new password is all whitespace" do
      it "redirects to the request_reaet_path with the correct params" do
        post :update_password, params: { token: "old-tolkien", password: "        ", confirm: "        " }
        expect(response).to redirect_to request_reset_path(token: "old-tolkien")
      end

      it "sets the correct flash message" do
        post :update_password, params: { token: "old-tolkien", password: "        ", confirm: "        " }
        expect(response.request.flash[:error]).to eq("Password cannot be whitespace.")
      end
    end

    context "API errors" do
      before(:each) do
        stub_request(:post, "#{ API.protocol }://admin:welcome@#{ API.domain }#{ API.base_path }/users/resetpassword").
          with(
            :body => "{\"token\":\"old-tolkien\",\"password\":\"rule them all\"}").
          to_return(
            :status => 200,
            :body => {error: {error: "old token!"}}.to_json)
      end

      it "redirects to the request_reaet_path with the correct params" do
        post :update_password, params: { token: "old-tolkien", password: "rule them all", confirm: "rule them all" }
        expect(response).to redirect_to request_reset_path(token: "old-tolkien")
      end

      it "sets the correct flash message" do
        post :update_password, params: { token: "old-tolkien", password: "rule them all", confirm: "rule them all" }
        expect(response.request.flash[:error]).to eq("old token!")
      end
    end
  end
end
