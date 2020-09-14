require "rails_helper"

describe "CartsHelper" do
  before do
    session[:order] = { meta: {}, items: [] }
  end

  describe "reset_cart!" do
    it "should remove order session" do
      helper.reset_cart!
      expect(session[:order]).to be_nil
    end
  end

  describe "order_exists?" do
    it "should return true if meta and items are on the session" do
      session[:order] = { meta: {}, items: [] }
      expect(helper.order_exists?).to be_truthy
    end

    it "should return false if any of items or meta variables are not in session" do
      session.delete(:order)
      expect(helper.order_exists?).to be_falsey

      session[:order] = { items: [] }
      expect(helper.order_exists?).to be_falsey

      session[:order] = { meta: {} }
      expect(helper.order_exists?).to be_falsey
    end
  end

  describe "set_cart_order_type" do
    it "should set order_type" do
      helper.set_cart_order_type("pickup")
      expect(session[:order][:meta][:order_type]).to eq("pickup")
    end

    context "order doesn't exists" do
      before do
        session.delete(:order)
      end

      it "shouldn't set the order type" do
        helper.set_cart_order_type("pickup")
        expect(session[:order]).to be_nil
      end
    end
  end

  describe "cart_merchant_id" do
    before do
      session[:order][:meta][:merchant_id] = "123"
    end

    it "should return cart merchant_id" do
      expect(helper.cart_merchant_id).to eq("123")
    end

    context "order doesn't exists" do
      before do
        session.delete(:order)
      end

      it "shouldn't return cart merchant_id" do
        expect(helper.cart_merchant_id).to be_nil
      end
    end
  end
end