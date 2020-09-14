require "rails_helper"

describe "group_orders/confirmation.html.erb" do
  before(:each) do
    render
  end

  subject { rendered }

  it { is_expected.to have_content "Your group order has been submitted" }
  it { is_expected.to have_content "Congratulations, your order has been sent to the organizer. Enjoy your meal." }
  it { is_expected.to have_css "a[href='#{root_path}']", text: "Return to home." }
end
