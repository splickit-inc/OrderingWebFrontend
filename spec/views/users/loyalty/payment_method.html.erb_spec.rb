require "rails_helper"

describe "users/payment_method.html.erb" do
  before(:each) do
    user = OpenStruct.new("has_cc?" => false)
    user.last_four = nil
    assign(:user, user)
    assign(:account, "vio-account")
    assign(:token, "vio-token")
    render
  end

  subject { rendered }

  it { expect(view.content_for(:head)).to eq("  <script src='/assets/test/fake_value.js' type=\"text/javascript\"></script>\n  <link rel=\"stylesheet\" media=\"screen\" href=\"https://api.value.io/assets/value.css\" />\n  <script>\n    window.valueio_account = 'vio-account';\n    window.valueio_write_only_token = 'vio-token';\n    window.valueio_form_selector = '#cc-form';\n    window.valueio_resource = 'credit_cards';\n    window.valueio_secure_form_collect_credit_card='true';\n    window.valueio_vault='true';\n    window.valueio_secure_form_collect_name='true';\n    window.valueio_secure_form_collect_zip='true';\n    window.valueio_secure_form_require_zip = 'true';\n  </script>\n") }
  it { is_expected.to have_content "New payment method" }

  it { is_expected.to have_css "form[method='post']" }
  it { is_expected.to have_css "form[action='#{ user_payment_index_path }']" }
  it { is_expected.to have_css "form[id='cc-form']" }

  context "no existing card" do
    it { is_expected.to have_css "input[type='submit']"}
    it { is_expected.to have_css "input[value='Add card']"}
  end

  context "existing card" do
    before(:each) do
      user = OpenStruct.new("has_cc?" => true)
      user.last_four = "1234"
      assign(:user, user)
      assign(:account, "vio-account")
      assign(:token, "vio-token")
      render
    end

    subject { rendered }

    it { is_expected.to have_css "h2", text: "Payment information" }
    it { is_expected.to have_css "input[type='submit']"}
    it { is_expected.to have_css "input[value='Replace card']"}
  end
end
