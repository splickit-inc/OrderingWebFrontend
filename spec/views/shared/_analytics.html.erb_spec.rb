require "rails_helper"

describe "shared/_analytics.html.erb" do
  before :each do    
    render
  end
  
  it 'should populate google analytics with the appropriate property id' do
    expect(rendered).to include Rails.application.config.google_analytics_tracking_id
  end
end