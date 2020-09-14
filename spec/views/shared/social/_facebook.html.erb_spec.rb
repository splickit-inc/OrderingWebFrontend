require "rails_helper"

describe "shared/social/_facebook.html.erb" do
  let(:merchant_url) { "https://order.splickit.com/merchant/1050" }

  before(:each) do
    render partial: "shared/social/facebook", locals: {url: merchant_url}
  end

  it { expect(rendered).to have_css "a[href='https://www.facebook.com/sharer/sharer.php?u=#{merchant_url}']" }
end
