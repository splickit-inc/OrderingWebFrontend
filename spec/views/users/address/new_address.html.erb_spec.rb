require "rails_helper"

describe "users/address/new_address.html.erb" do
  let(:merchant_id) { rand(1000) }

  before(:each) do
    render
  end

  subject { rendered }

  it { is_expected.to have_css "h1", text: "Add a new delivery address" }

  it { is_expected.to render_template "users/address/_form.html.erb" }
  it { is_expected.to render_template "users/address/_profile.html.erb" }

end

