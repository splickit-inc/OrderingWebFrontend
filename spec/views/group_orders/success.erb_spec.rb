require "rails_helper"

describe "group_orders/success.html.erb" do
  let(:token) { "123-1" }

  before do
    assign(:group_order_token, token)
    render
  end

  context "when success" do
    subject { rendered }

    it { is_expected.to have_content "Your Order was Successful" }
    it { is_expected.to have_content "Thank you. Enjoy your order." }

    it { is_expected.to have_css "a[href='#{ root_path }']", text: "Return to home" }
    it { is_expected.to have_css "a[href='#{ group_order_path(token) }']", text: "Group Order Status" }
  end
end
