require "rails_helper"

describe "route redirection" do
  it "redirects legacy merchants routes" do
    get "/order/Colorado/Boulder/Snarfs-2128-Pearl-Street/1083"
    expect(response).to redirect_to("http://www.example.com/merchants/1083?order_type=pickup")
  end
end
