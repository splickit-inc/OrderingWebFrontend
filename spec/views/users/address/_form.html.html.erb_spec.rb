require "rails_helper"

describe "users/address/_form.html.erb" do
  before(:each) do
    render
  end

  subject { rendered }

  it { is_expected.to have_css "form[method='post']" }
  it { is_expected.to have_css "form[action='#{ user_address_index_path }']" }

  # is expected syntax fails looking hidden fields
  it "should render hidden fields" do
    expect(have_css("input#authenticity_token[type='hidden']"))
    expect(have_css("input#user_action[type='hidden']"))
  end

  it { is_expected.to have_css "h2", text: "Delivery information" }

  it { is_expected.to have_css "input[name='address[address1]']" }
  it { is_expected.to have_css "input[placeholder='Street address']" }

  it { is_expected.to have_css "input[name='address[address2]']" }
  it { is_expected.to have_css "input[placeholder='Suite / Apt']" }

  it { is_expected.to have_css "input[name='address[city]']" }
  it { is_expected.to have_css "input[placeholder='City']" }
  it { is_expected.to have_css "input[maxlength='2']" }

  it { is_expected.to have_css "input[name='address[state]']" }
  it { is_expected.to have_css "input[placeholder='State']" }

  it { is_expected.to have_css "input[name='address[zip]']" }
  it { is_expected.to have_css "input[placeholder='Zip']" }

  it { is_expected.to have_css "input[name='address[phone_no]']" }
  it { is_expected.to have_css "input[placeholder='Phone number']" }

  it { is_expected.to have_css "h2", text: "Delivery instructions" }

  it { is_expected.to have_css "input[name='address[instructions]']" }
  it { is_expected.to have_css "input[placeholder='The doorbell is broken; please knock.']" }

  it { is_expected.to have_css "input[type='submit']"}
  it { is_expected.to have_css "input[value='Add delivery address']"}
end
