require "rails_helper"

describe "shared/social/_twitter.html.erb" do
  let(:message) { "https://order.splickit.com/merchant/1050" }

  before(:each) do
    render partial: "shared/social/twitter", locals: {msg: message}
  end

  it { expect(rendered).to have_css "a[href='http://twitter.com/intent/tweet?text=#{message}']" }
end
