require "rails_helper"
require "application_helper"

describe UsersHelper, type: :helper do
  module ApplicationControllerStub
    def current_user
      User.new("flags" => "1C21000001")
    end
  end

  before { helper.extend(ApplicationControllerStub) }

  describe '#user_loyal?' do
    it "returns false if the @user isn't loyal to the brand" do
      expect(helper.user_loyal?).to eq(false)
    end

    it "returns true if the @user is loyal to the brand" do
      @user = User.initialize
      @user.brand_loyalty = {}
      expect(helper.user_loyal?).to eq(true)
    end
  end

  describe "#trimmed_first_name" do
    context "signed in" do
      before do
        session[:current_user] = { "first_name" => "thiscannotbemuchlongerthantwentycharacters" }
      end

      it "returns only the first 20 characters of a user's first name" do
        expect(helper.trimmed_first_name).to eq("thiscannotbemuchlong")
      end
    end

    context "signed out" do
      it { expect(helper.trimmed_first_name).to eq(nil) }
    end

    context "missing 'first_name' field" do
      before { session[:current_user] = { name: "bob" } }

      it { expect(helper.trimmed_first_name).to eq(nil) }
    end
  end
end
