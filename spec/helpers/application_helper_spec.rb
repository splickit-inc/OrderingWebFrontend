require "rails_helper"

describe ApplicationHelper do
  before do
    controller.request.path = "bob"
  end

  describe "#sign_in_url" do
    it 'should be non-ssl for development or test' do
      expect(helper.sign_in_url).to eq("#{ sessions_url }?continue=bob")
    end

    it 'should be ssl for any environment not development or test' do
      allow(Rails.env).to receive("development?").and_return(false)
      allow(Rails.env).to receive("test?").and_return(false)

      expect(helper.sign_in_url).to eq("#{ sessions_url(protocol: "https") }?continue=bob")
    end

    it 'should set continue to session[:continue] if it exists' do
      session[:continue] = "jim"
      expect(helper.sign_in_url).to eq("#{ sessions_url }?continue=jim")
    end
  end

  describe "#sign_up_url" do
    it 'should be non-ssl for development or test' do
      expect(helper.sign_up_url).to eq("#{ user_url }?continue=bob")
    end

    it 'should be ssl for any environment not development or test' do
      allow(Rails.env).to receive("development?").and_return(false)
      allow(Rails.env).to receive("test?").and_return(false)

      expect(helper.sign_up_url).to eq("#{ user_url(protocol: "https") }?continue=bob")
    end

    it 'should set continue to session[:continue] if it exists' do
      session[:continue] = "jim"
      expect(helper.sign_up_url).to eq("#{ user_url }?continue=jim")
    end
  end

  describe "#signed_in?" do
    context "user signed in" do
      before { session[:current_user] = "somebody" }
      it { expect(helper.signed_in?).to eq(true) }
    end

    context "user signed out" do
      it { expect(helper.signed_in?).to eq(false) }
    end
  end

  describe "#item_count" do
    it 'should return the number of items in cart' do
      session[:order] = {}
      session[:order][:items] = [{
                                   item_id: "700",
                                   quantity: "1",
                                   mods: [],
                                   size_id: "800"
                                 }]
      expect(helper.item_count).to eq(1)
    end

    it 'should return 0 if order is nil' do
      session[:order] = nil
      expect(helper.item_count).to eq(0)
    end

    it 'should return 0 if order is empty' do
      session[:order] = {}
      session[:order][:items] = []
      expect(helper.item_count).to eq(0)
    end

    it 'should update as cart is updated' do
      session[:order] = {}
      session[:order][:items] = [{
                                   item_id: "700",
                                   quantity: "1",
                                   mods: [],
                                   size_id: "800"
                                 }]

      expect(helper.item_count).to eq(1)

      session[:order][:items].push({item_id: "701", quantity: "1",mods:[],size_id: "800"})

      expect(helper.item_count).to eq(2)

    end
  end

  describe "#my_order_text" do
    it 'should return My group order if there is a group_order_token param' do
      params["group_order_token"] = "222"
      expect(helper.my_order_text).to eq("My group order")
    end

    it 'should return My group order if there is a group_order_token in order meta data' do
      session[:order] = {meta: {group_order_token: "111"}}
      expect(helper.my_order_text).to eq("My group order")
    end

    it 'should return My order if there is no group_order_token info' do
      expect(helper.my_order_text).to eq("My order")
    end
  end

  describe "#loyalty_link_text" do
    it 'should return Loyalty for users without points' do
      @user = User.new(get_user_data)
      expect(helper.loyalty_link_text).to eq("Loyalty")
    end

    it 'should return XX Points for users with points' do
      @user = User.new(get_loyal_user_data)
      expect(helper.loyalty_link_text).to eq("500 Points")
    end
  end

  describe "#is_punchh" do
    it "should return true if token present" do
      session[:punch_auth_token] = "1"
      expect(helper.is_punchh?).to be_truthy
    end

    it "should return false if token is not present" do
      expect(helper.is_punchh?).to be_falsey
    end
  end
end
