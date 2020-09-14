require "rails_helper"

describe "feedbacks/thank_you.html.erb" do
  before { render }
  subject { rendered }

  it { is_expected.to have_css "img[src='https://d38o1hjtj2mzwt.cloudfront.net/shared/mobile/webviews/feedback-assets/thank-you.png']" }
  it { is_expected.to have_content "Thank you!" }
  it { is_expected.to have_content "We appreciate your feedback." }
end
