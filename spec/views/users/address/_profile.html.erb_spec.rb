require "rails_helper"

describe "users/address/_profile.html.erb" do
  before(:each) do
    render
  end

  subject {rendered}

  it { is_expected.to have_css "h2", text: "Delivery address" }
  it { is_expected.to have_css "p", text: "Add or select a delivery address so when you choose delivery it will arrive at the right address." }
end
