require "rails_helper"

describe "users/email_sent.html.erb" do
  let(:email) { Faker::Internet.email }

  before(:each) do
    assign(:email, email)
    render
  end

  subject { rendered }

  it { is_expected.to have_css "h1", text: "Instructions sent" }
  it { is_expected.to have_content "Password reset instructions have been sent to #{email}." }
  it { is_expected.to have_content "Please check your junk mail and spam filters if you don't see it at first" }
  it { is_expected.to have_css "a[href='#{sign_in_path}']", text: "Return to sign in" }
end
