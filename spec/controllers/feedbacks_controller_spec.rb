require "rails_helper"
require 'api'

describe FeedbacksController do

  before(:each) { enable_ssl }

  describe "#new" do
    context "skin specifies feedback_url" do
      before(:each) do
        allow_any_instance_of(Skin).to receive(:feedback_url) { "http://another-fb-url.com" }
      end

      it "redirects to the 'feedback_url'" do
        get :new
        expect(response).to redirect_to("http://another-fb-url.com")
      end
    end

    it 'should define @feedback with a new Feedback' do
      get :new
      expect(assigns(:feedback)).to be
    end

    it 'should define @name with params[:name] if provided' do
      get :new, params: { :name => "Bob" }
      expect(assigns(:name)).to eq("Bob")
    end

    it 'should define @name with current_user_name if no params name exists' do
      user = get_user_data.merge("user_id"=>"12345", "first_name"=>"barnis","email" => "tom@bom.com", "splickit_authentication_token" => "B4C0NTOKEN", "delivery_locations" => [
                                                     {
                                                       "user_addr_id" => "1234",
                                                       "address1" => "bacon st."
                                                     }
                                                   ])
      sign_in(user)
      get :new
      expect(assigns(:name)).to eq("barnis roberts")
    end

    it 'should define @name as nil if otherwise' do
      get :new
      expect(assigns(:name)).to be_nil
    end

    it 'should define @email with params[:email] if provided' do
      get :new, params: { :email => "bob@bob.com" }
      expect(assigns(:email)).to eq("bob@bob.com")
    end

    it 'should define @email with current_user_email if no params name exists' do
      user = get_user_data.merge("user_id"=>"12345", "first_name"=>"barnis","email" => "tom@bom.com", "splickit_authentication_token" => "B4C0NTOKEN", "delivery_locations" => [
                                                     {
                                                       "user_addr_id" => "1234",
                                                       "address1" => "bacon st."
                                                     }
                                                   ])
      sign_in(user)

      get :new
      expect(assigns(:email)).to eq("tom@bom.com")
    end

    it 'should define @email as nil if otherwise' do
      get :new
      expect(assigns(:email)).to be_nil
    end
  end

  describe "#create" do
    it 'should setup the Feedback correctly' do
      Timecop.freeze(Time.now)
      feedback = double("feedback")
      allow(feedback).to receive("send_mail")

      expect(Feedback).to receive("new").with(ActionController::Parameters.new("name"=>"Bob", "email"=>"bob@bob.com", "body"=>"Yay").permit!).and_return(feedback)
      expect(feedback).to receive("support_address=").with("feedback@splickit.com")
      expect(feedback).to receive("time=").with(Time.now)
      expect(feedback).to receive("skin_name=").with("order")
      post :create, params: { feedback: { name: "Bob", email: "bob@bob.com", body: "Yay"}, human: "on", honeypot: "" }
    end

    it 'should call send_mail on the created feedback' do
      feedback = double("feedback")
      allow(feedback).to receive(:support_address=)
      allow(feedback).to receive(:time=)
      expect(Feedback).to receive("new").and_return(feedback)
      expect(feedback).to receive("send_mail")
      expect(feedback).to receive("skin_name=").with("order")
      post :create, params: { feedback: {name: "Bob", email: "bob@bob.com", body: "Yay"}, human: "on", honeypot: "" }
    end

    it 'should render feedbacks/thank_you' do
      post :create, params: { feedback: {name: "Bob", email: "bob@bob.com", body: "Yay"}, human: "on" }
      expect(response).to render_template("feedbacks/thank_you")
    end

    context "bots" do
      it 'should ignore any request where honeypot is not blank' do
        expect(Feedback).not_to receive("new")
        post :create, params: { feedback: {name: "Bob", email: "bob@bob.com", body: "Yay"}, honeypot: "botspam" }
      end

      it 'should ignore any request where human is not set' do
        expect(Feedback).not_to receive("new")
        post :create, params: { feedback: {name: "Bob", email: "bob@bob.com", body: "Yay"}, honeypot: "" }
      end
    end
  end
end
