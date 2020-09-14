require "rails_helper"

describe AppsController, :type => :controller do
  before(:each) { enable_ssl }

  before do
    skin_where_stub
  end

  describe "#redirect_to_app_store" do
    
    it "should return the iphone store url" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/9A405"
      get :redirect_to_app_store
      expect(assigns(:skin).iphone_app_link).to eq("http://itunes.apple.com/us/app/pita-pit/id461735388?mt=8")
      expect(response).to redirect_to ("http://itunes.apple.com/us/app/pita-pit/id461735388?mt=8")
    end

    it "should return the Android store url" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Android 5.0.2; Mobile; rv:42.0) Gecko/42.0 Firefox/42.0"
      get :redirect_to_app_store
      expect(assigns(:skin).android_marketplace_link).to eq("https://play.google.com/store/apps/details?id=com.splickit.pitapit&hl=en")
      expect(response).to redirect_to ("https://play.google.com/store/apps/details?id=com.splickit.pitapit&hl=en")
    end

    it "should return the https://test.host/" do
      get :redirect_to_app_store
      expect(response).to redirect_to ("https://test.host/")
    end
  end
end
