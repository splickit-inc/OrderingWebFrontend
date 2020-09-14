require "rails_helper"

describe "users/address/delivery_address.html.erb" do
  context "no delivery addresses" do
    before(:each) do
      render
    end

    subject { rendered }

    it { is_expected.to render_template "users/_navigation" }
    it { is_expected.to render_template "users/address/_form" }
    it { is_expected.to render_template "users/address/_profile" }
  end
end
