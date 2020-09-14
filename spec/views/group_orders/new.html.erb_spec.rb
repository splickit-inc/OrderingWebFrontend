require "rails_helper"

describe "group_orders/new.html.erb" do
  let(:merchant) { Merchant.new(
    name: "Bacon Co.",
    address1: "Hog St.",
    address2: "#101",
    city: "Frycaster",
    state: "Porksillvania",
    zip: "54321"
  ) }

  context "delivery" do
    before(:each) do
      merchant.group_order_available_times(GroupOrder::ORGANIZER_PAY, "delivery")
      allow(view).to receive(:params).and_return(order_type: "delivery")
      assign(:merchant, merchant)
      assign(:group_order, GroupOrder.new)
      allow_any_instance_of(Merchant).to receive(:delivery) { "Y" }
      render
    end

    subject { rendered }

    it { is_expected.to have_content "START YOUR GROUP ORDER" }
    it { is_expected.to have_content merchant.name }
    it { is_expected.to have_content merchant.full_address }

    it { is_expected.to have_css "a[href='#{root_path}']", text: "Place a group order from a different location" }

    it { is_expected.to have_css "form[action='/group_orders']" }
    it { is_expected.to have_content "Invite Others" }
    it { is_expected.to have_content "Type as many email addresses as you'd like (the more the merrier), using commas between emails." }
    it { is_expected.to have_css "textarea[placeholder='name@food.com, name@food.com']" }
    it { is_expected.to have_content "Include a note" }
    it { is_expected.to have_css "textarea[placeholder=\"Hi, we're getting food for the office. Please put in your order within the next 15 min.\"]" }

    it { is_expected.to have_css "input[type='submit']" }
    it { is_expected.to have_css "input[value='Send']" }

    it { is_expected.to have_content "You're ordering from this location" }
    it { is_expected.to have_content "Type as many email addresses as you'd like (the more the merrier), using commas between emails." }
    it { is_expected.to have_content "Select who's paying and click send" }
    it { is_expected.to have_content "Please anticipate an average of 45 minutes from the time your order is placed, to your actual pickup or delivery time. You'll see your estimated pickup/delivery time once you place the order." }
  end
end
