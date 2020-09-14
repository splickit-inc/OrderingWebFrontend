require "rails_helper"

describe ErrorsController do
  describe "#error_404" do
    it "renders the error_404 template" do
      get :error_404
      expect(response).to render_template(:error_404)
    end

    it "has a 404 status" do
      get :error_404
      expect(response.status).to eq(404)
    end
  end

  describe "#error_422" do
    it "renders the error_422 template" do
      get :error_422
      expect(response).to render_template(:error_422)
    end

    it "has a 422 status" do
      get :error_422
      expect(response.status).to eq(422)
    end
  end

  describe "#error_500" do
    it "renders the error_500 template" do
      get :error_500
      expect(response).to render_template(:error_500)
    end

    it "has a 500 status" do
      get :error_500
      expect(response.status).to eq(500)
    end
  end

  describe "#error_590" do
    it "renders the error_500 template" do
      get :error_590
      expect(response).to render_template(:error_590)
    end

    it "has a 500 status" do
      get :error_590
      expect(response.status).to eq(590)
    end
  end
end
