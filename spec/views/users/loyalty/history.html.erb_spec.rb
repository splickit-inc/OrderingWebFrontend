require "rails_helper"

describe "users/loyalty/history.html.erb" do
  context "with history" do
    let(:user_transactions) do
      { "headings" => { "transaction_date" => "date",
                        "description" => "transaction",
                        "amount" => "amount" },
        "rows" => [{ "amount" => "1116",
                     "description" => "Order 2468479",
                     "transaction_date" => "2014-09-30" }] }
    end

    before(:each) do
      @user = User.initialize({"brand_loyalty" => {"usd" => 333, "points" => 666}})
      assign(:user_transactions, user_transactions)
      @skin = Skin.initialize({'loyalty_features' => {'supports_history' => true}})
      render
    end

    subject { rendered }

    it { is_expected.to render_template "users/loyalty/_navigation" }
    it { is_expected.to render_template "users/loyalty/_card" }

    it { is_expected.to have_content "Transaction history" }

    it { is_expected.to have_content "date" }
    it { is_expected.to have_content "transaction" }
    it { is_expected.to have_content "amount" }

    it { is_expected.to have_content "2014-09-30" }
    it { is_expected.to have_content "Order 2468479" }
    it { is_expected.to have_content "1116" }
  end

  context "without history" do
    let(:user_transactions) do
      { "rows" => [] }
    end

    before(:each) do
      @user = User.initialize({"brand_loyalty" => {"usd" => 333, "points" => 666}})
      assign(:user_transactions, user_transactions)
      @skin = Skin.initialize({'loyalty_features' => {'supports_history' => true}})
      render
    end

    subject { rendered }

    it { is_expected.to have_content "Your loyalty transaction history will appear here." }
    it { is_expected.to have_content "Visit the rules tab above to learn more about earning and using your loyalty card." }
  end
end
