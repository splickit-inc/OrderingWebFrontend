require "rails_helper"

describe "users/orders_history.html.erb" do
  context "with history pagination" do
    before(:each) do
      orders_response = get_user_orders_json["orders"].each { |order| order["merchant"] = Merchant.new(order["merchant"]) }
      orders_data = { orders: orders_response, count: get_user_orders_json["totalOrders"] }
      assign(:orders_pag, Kaminari.paginate_array([], total_count: orders_data[:count].to_i).page(1).per(10))
      assign(:orders, orders_data[:orders])
      @skin = Skin.initialize("loyalty_features" => { "supports_history" => true })
      render
    end

    subject { rendered }

    it { expect render_template "users/orders_history" }
    it { expect render_template "users/_navigation" }

    it { expect have_content "History" }
    it { expect have_content "A history view showing all orders" }

    it "expect render table headers" do
      expect have_content "id"
      expect have_content "merchant"
      expect have_content "date"
      expect have_content "status"
      expect have_content "total"
    end

    it "expects to render html elements" do
      expect have_css "h2", text: "History"
      expect have_css "div#order-data"
      expect have_css "th.add-favorite-button"
      expect have_css "button", count: 10, text: "Add to favorites"
      expect have_css "tr", count: 11
    end

    it "expects to render pagination elements" do
      expect have_css "div#pagination ul.pagination li", count: 4
      expect have_css "div#pagination ul.pagination li.active", count: 1
    end
  end

  context "with history page 2" do
    before(:each) do
      orders_response = get_user_orders_json_2["orders"].each { |order| order["merchant"] = Merchant.new(order["merchant"]) }
      orders_data = { orders: orders_response, count: get_user_orders_json_2["totalOrders"] }
      assign(:orders_pag, Kaminari.paginate_array([], total_count: orders_data[:count].to_i).page(2).per(10))
      assign(:orders, orders_data[:orders])
      @skin = Skin.initialize({ "loyalty_features" => { "supports_history" => true } })
      render
    end

    subject { rendered }

    it { expect render_template "users/orders_history" }
    it { expect render_template "users/_navigation" }

    it { expect have_content "History" }
    it { expect have_content "A history view showing all orders" }

    it "expect render table headers" do
      expect have_content "id"
      expect have_content "merchant"
      expect have_content "date"
      expect have_content "status"
      expect have_content "total"
    end

    it "expect render table data" do
      expect have_content "6923234"
      expect have_content "Springfield"
      expect have_content "2825 S. Glenstone, Battlefield Mall, H08F"
      expect have_content "Springfield, MO 65804"
      expect have_content "2015-05-28"
      expect have_content "In Process"
      expect have_content "$16.79"
    end

    it "expects to render html elements" do
      expect have_css "h2", text: "History"
      expect have_css "div#order-data"
      expect have_css "th.add-favorite-button"
      expect have_css "button", count: 1, text: "Add to favorites"
      expect have_css "tr", count: 2
    end
  end

  context "without history" do
    before(:each) do
      assign(:orders_pag, Kaminari.paginate_array([], total_count: 0).page(2).per(10))
      assign(:orders, [])
      @skin = Skin.initialize({ "loyalty_features" => { "supports_history" => true } })
      render
    end

    subject { rendered }

    it { is_expected.to have_content "No orders available" }
  end
end