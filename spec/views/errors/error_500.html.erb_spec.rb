require "rails_helper"

describe "errors/error_500.html.erb" do
  before(:each) do
    render
  end

  subject { rendered }

  it { is_expected.to have_content "500" }
  it { is_expected.to have_content "Internal service error" }
  it { is_expected.to have_content "If you continue to get this error please contact" }

  it { is_expected.to have_css "a[href='mailto:support@order140.com']", text: "support@order140.com" }
  it { is_expected.to have_css "a[href='#{root_path}']", text: "Take me home" }
end
