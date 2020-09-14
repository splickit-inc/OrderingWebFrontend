require "rails_helper"

describe SessionsHelper, type: :helper do
  describe "reset_cookies" do
    before do
      cookies[:test] = "test"
    end

    it "should reset cookies" do
      helper.reset_cookies
      expect(cookies[:test]).to be_nil
    end
  end
end
