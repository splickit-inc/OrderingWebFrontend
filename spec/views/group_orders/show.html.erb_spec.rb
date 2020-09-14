require "rails_helper"

describe "group_orders/show.html.erb" do

  let(:merchant) {
    Merchant.new({
      "merchant_id" => "12345",
      "name" => "Hammersmith Folly",
      "address1" => "Something St.",
      "address2" => "#105",
      "city" => "Denver",
      "state" => "CO",
      "zip" => "50505",
    })
  }

  context "admin pay" do
    context "pickup" do
      context "with items" do
        let(:group_order) {
          {
            "group_order_id" => "1910",
            "group_order_token" => "5424-b6zqu-24j7y-d7po5",
            "group_order_type" => "1",
            "merchant_id" => "102237",
            "sent_ts" => "0000-00-00 00:00:00",
            "notes" => "",
            "participant_emails" => "",
            "merchant_menu_type" => "pickup",
            "expires_at" => "1415468887",
            "status" => "active",
            "order_summary" => {
              "cart_items" => [
                {
                  "item_name" => "Blu Bayou",
                  "item_price" => "4.29",
                  "item_quantity" => "1",
                  "item_description" => "Chips, Mayo",
                  "order_detail_id" => "6081076",
                  "item_note" => "really tasty Ham S."
                },
                {
                  "item_name" => "Vitamin Water Energy",
                  "item_price" => "2.29",
                  "item_quantity" => "1",
                  "item_description" => "Bacon, Ham",
                  "order_detail_id" => "6081079",
                  "item_note" => "really not tasty Ham S. "
                }
              ],
              "receipt_items" => [
                {
                  "title" => "Subtotal",
                  "amount" => "$13.16"
                },
                {
                  "title" => "Tax",
                  "amount" => "$0.79"
                },
                {
                  "title" => "Total",
                  "amount" => "$13.95"
                }
              ]
            }
          }
        }

        before(:each) do
          assign(:group_order, group_order)
          assign(:merchant, merchant)
          render
        end

        subject { rendered }

        it { is_expected.to have_content "Something St." }
        it { is_expected.to have_content "Denver, CO 50505" }

        it { is_expected.to have_content "Group order - pickup" }
        it { is_expected.to have_content "Group order Activity" }

        it { is_expected.to have_content "Invite more people by sending them this link" }
        it { is_expected.to have_content "If you're paying, wait until all orders are in, then click "+'"checkout"'+" to submit your order." }
        it { is_expected.to have_content "Share link: http://test.host/merchants/12345?group_order_token=5424-b6zqu-24j7y-d7po5&order_type=pickup" }

        it { is_expected.to have_content "If individuals pay, wait until all orders are in and click on "+'"Place Order Now"'+". Or, do nothing and your order will be automatically submitted at the time above." }

        it { is_expected.to have_css "a.button[href='/checkouts/new?group_order_token=#{group_order["group_order_token"]}&merchant_id=#{group_order["merchant_id"]}&order_type=#{group_order["merchant_menu_type"]}&submit=true']" }
        it { is_expected.to have_css "a.button[href='/merchants/#{group_order["merchant_id"]}?group_order_token=#{group_order["group_order_token"]}&order_type=#{group_order["merchant_menu_type"]}']" }
        it { is_expected.to have_css "input.secondary[value='Cancel']" }

        # is expected syntax fails looking hidden fields
        it "should render hidden fields" do
          expect have_css "input[name='id'][value='#{ group_order["group_order_token"] }']"
        end

        it { is_expected.not_to have_css ".delivery-info" }
      end
    end

    context "delivery" do
      context "with items" do
        let(:group_order) {
          {
            "group_order_id" => "1910",
            "group_order_token" => "5424-b6zqu-24j7y-d7po5",
            "merchant_id" => "102237",
            "group_order_type" => "1",
            "sent_ts" => "0000-00-00 00:00:00",
            "notes" => "",
            "participant_emails" => "",
            "merchant_menu_type" => "delivery",
            "expires_at" => "1415468887",
            "status" => "active",
            "order_summary" => {
              "cart_items" => [
                {
                  "item_name" => "Blu Bayou",
                  "item_price" => "4.29",
                  "item_quantity" => "1",
                  "item_description" => "Chips, Mayo",
                  "order_detail_id" => "6081076",
                  "item_note" => "really tasty Ham S."
                },
                {
                  "item_name" => "Vitamin Water Energy",
                  "item_price" => "2.29",
                  "item_quantity" => "1",
                  "item_description" => "Bacon, Ham",
                  "order_detail_id" => "6081079",
                  "item_note" => "really not tasty Ham S. "
                }
              ],
              "receipt_items" => [
                {
                  "title" => "Subtotal",
                  "amount" => "$13.16"
                },
                {
                  "title" => "Tax",
                  "amount" => "$0.79"
                },
                {
                  "title" => "Total",
                  "amount" => "$13.95"
                }
              ]
            },
            "delivery_address" => {
              "business_name" => "Alene Company",
              "address1"=>"819 Sherman Ave",
              "address2"=>"",
              "city"=>"Coeur d'Alene",
              "state"=>"ID",
              "zip"=>"83814"
            }

          }
        }

        before(:each) do
          assign(:group_order, group_order)
          assign(:merchant, merchant)
          render
        end

        subject { rendered }

        it { is_expected.to have_content "Something St." }
        it { is_expected.to have_content "Denver, CO 50505" }

        it { is_expected.to have_content "Group order - delivery" }
        it { is_expected.to have_content "Group order Activity" }

        it { is_expected.to have_content "Invite more people by sending them this link" }
        it { is_expected.to have_content "If you're paying, wait until all orders are in, then click "+'"checkout"'+" to submit your order." }
        it { is_expected.to have_content "Share link: http://test.host/merchants/12345?group_order_token=5424-b6zqu-24j7y-d7po5&order_type=delivery" }

        it { is_expected.to have_content "If individuals pay, wait until all orders are in and click on "+'"Place Order Now"'+". Or, do nothing and your order will be automatically submitted at the time above." }

        it { is_expected.to have_content "Delivering to:" }
        it { is_expected.to have_content "Alene Company" }
        it { is_expected.to have_content "819 Sherman Ave" }
        it { is_expected.to have_content "Coeur d'Alene, ID 83814" }

        it { is_expected.to have_css "a.button[href='/checkouts/new?group_order_token=#{group_order["group_order_token"]}&merchant_id=#{group_order["merchant_id"]}&order_type=#{group_order["merchant_menu_type"]}&submit=true']" }
        it { is_expected.to have_css "input.secondary[value='Cancel']" }

        # is expected syntax fails looking hidden fields
        it "should render hidden fields" do
          expect have_css "input[name='id'][value='#{ group_order["group_order_token"] }']"
        end

        it { is_expected.to have_css ".delivery-info" }
      end
    end

    it "should not appear group order submit time text" do
      expect(subject).not_to have_css("div.title h2")
    end

    it "should not appear group order status" do
      expect(subject).not_to have_css("div#status span.badge")
    end

    it "should have Group order activity text" do
      expect(subject).not_to have_content("Group Order Activity")
    end
  end

  context "individual pay" do
    let(:group_order) do
      { "group_order_id" => "1910",
        "group_order_token" => "5424-b6zqu-24j7y-d7po5",
        "merchant_id" => "102237",
        "group_order_type" => "2",
        "sent_ts" => "0000-00-00 00:00:00",
        "notes" => "",
        "status" => "active",
        "participant_emails" => "",
        "merchant_menu_type" => "delivery",
        "expires_at" => "1415468887",
        "send_on_local_time_string" => "Friday 2:20 pm",
        "total_submitted_orders" => "1",
        "group_order_admin" => { "first_name" => "Test",
                                 "last_name" => "test",
                                 "email" => "test@test.com",
                                 "admin_uuid" => "4922-3zs82-788bk-9e423" },
        "total_orders" => 1,
        "total_items" => 1,
        "total_e_level_items" => 1,
        "order_summary" => { "user_items" => [{ "user_id" => "4777193",
                                                "full_name" => "User Test",
                                                "item_count" => "1" }] } }

    end

    before(:each) do
      assign(:group_order, group_order)
      assign(:merchant, merchant)
      render
    end

    subject { rendered }

    it "should have place order now button" do
      expect(subject).to have_css("a#checkout")
      expect(subject).to have_content("Place Order Now!")
    end

    it "should have status badge" do
      expect(subject).to have_css("section#modifiers span#status.badge")
      expect(subject).to have_content("active")
    end

    it "should have submitted-orders badge" do
      expect(subject).to have_css("section#modifiers span#submitted-orders.badge")
      expect(subject).to have_content("1")
    end

    it "should have group order submit label" do
      expect(subject).to have_css("section.title h2")
      expect(subject).to have_content("Group Order will be submitted at Friday 2:20 pm")
    end

    it "should have Group order activity data" do
      expect(subject).to have_content("Group Order Activity")
      expect(subject).to have_content("1. User Test (1)")
    end
  end
end
