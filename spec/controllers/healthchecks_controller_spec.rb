require "spec_helper"

describe HealthchecksController do
  describe "#new" do
    it "should return a status ok" do
      get :new
      expect(response.status).to eq(200)
    end

    it "should return a error status" do
      expect(@controller).to receive(:render).and_raise(StandardError)
      get :new
      expect(response.status).to eq(302)
    end
  end
end