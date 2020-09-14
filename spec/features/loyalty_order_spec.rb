require "support/feature_spec_helper"

describe "loyalty ordering", js: true do
  let(:menu_data) { get_default_menu }
  let(:menu) { menu_data[:menu] }
  let(:modifier_item_1) { menu_data[:modifier_item_1] }

  before do
    allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731239)

    visit merchants_path

    ## Merchant Search
    merchant_where_stub({ params: { location: "80305" } })
    merchant_find_stub({ return: { menu: menu } })
    merchant_find_stub({ auth_token: "ASNDKASNDAS", return: { menu: menu } })

    fill_in("location", with: "80305")
    click_button("Search")
    first(".pickup.button").click
  end

  context "user with 200 points" do
    before do
      feature_sign_in(user_return: { brand_loyalty: { loyalty_number: "140105420000001793",
                                                      pin: "9189",
                                                      points: "200",
                                                      usd: "25" } })
    end

    context "176 points used" do
      ## Use this hash for cart create, the 176 points items are there
      let!(:cart_hash) do
        { items: [{ item_id: 931,
                    quantity: 1,
                    mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                             mod_quantity: 1,
                             name: "Spicy Club Sauce" }],
                    size_id: "1",
                    order_detail_id: nil,
                    external_detail_id: 92391731239,
                    status: "new",
                    points_used: "88",
                    brand_points_id: nil,
                    note: "" },
                  { item_id: 931,
                    quantity: 1,
                    mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                             mod_quantity: 1,
                             name: "Spicy Club Sauce" }],
                    size_id: "1",
                    order_detail_id: nil,
                    external_detail_id: 92391731240,
                    status: "new",
                    points_used: "88",
                    brand_points_id: nil,
                    note: "" }],
         total_points_used: 176 }
      end

      let!(:checkout_return) do
        return_cart = Marshal.load(Marshal.dump(cart_hash))

        return_cart[:items].each_with_index do |item, index|
          item[:order_detail_id] = index + 1
          item[:status] = "saved"
        end

        { order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                          item_price: "88 pts",
                                          item_quantity: "1",
                                          item_description: "A bed of fresh pastrami topped with cool ranch pastrami.",
                                          order_detail_id: return_cart[:items].first[:order_detail_id],
                                          note: "" },
                                        { item_name: "Pastrami Salad",
                                          item_price: "88 pts",
                                          item_quantity: "1",
                                          item_description: "A bed of fresh pastrami topped with cool ranch pastrami.",
                                          order_detail_id: return_cart[:items].last[:order_detail_id],
                                          note: "" }],
                           order_data_as_ids_for_cart_update: { items: return_cart[:items] },
                           receipt_items: [{ title: "Subtotal",
                                             amount: "$6.89" },
                                           { title: "Tax",
                                             amount: "$0.41" },
                                           { title: "Total",
                                             amount: "$7.30" }] } }
      end

      before do
        first("article.item").click
        all("section#size label")[2].click ## The one with points
        first("button.add.points").click

        allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)

        first("article.item").click
        all("section#size label")[2].click ## The one with points
        first("button.add.points").click
      end

      it "should show loyalty button and cash button in edit item modal in loyalty transaction" do
        first(".my-order-link").click

        checkout_stubs(body: cart_hash, return: checkout_return)

        click_button("Checkout - 176 pts")

        ## Checkout#new page
        loy_items = all(:xpath, "//td[@class='price'][contains(text(),'pts')]/preceding-sibling::td/descendant::div[@class='edit-item']")
        loy_items.each do |item|
          item.click
          expect(page).to have_css("button.add.points")
          expect(page).to have_css("button.add.cash")
          find("span[data-dialog-close]").click
        end
      end

      it "should send total_points used param only on new items" do
        first(".my-order-link").click

        checkout_stubs(body: cart_hash, return: checkout_return)

        click_button("Checkout - 176 pts")

        ## Checkout#new page
        expect(page).to have_content("Place order")

        find("a#add").click

        ## Menu page
        first(".my-order-link").click

        cart_hash[:items].each { |item| item[:status] = "saved" }

        cart_hash[:items].first[:order_detail_id] = 1
        cart_hash[:items].last[:order_detail_id] = 2


        checkout_stubs(cart_id: "9705-j069h-ce8w3-425di",
                       body: cart_hash.merge(total_points_used: 0),
                       return: checkout_return)

        click_button("Checkout - 176 pts")

        expect(page).to have_content("Place order")
      end

      context "not enough points" do
        before do
          allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731241)

          first("article.item").click
          all("section#size label")[2].click ## The one with points
          first("button.add.cash").click

          first(".my-order-link").click

          new_item_hash = { item_id: 931,
                            quantity: 1,
                            mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                     mod_quantity: 1,
                                     name: "Spicy Club Sauce" }],
                            size_id: "1",
                            order_detail_id: nil,
                            external_detail_id: 92391731241,
                            status: "new",
                            points_used: nil,
                            brand_points_id: nil,
                            note: "" }

          cart_hash[:items] << new_item_hash

          checkout_return[:order_summary][:cart_items] << { item_name: "Pastrami Salad",
                                                            item_price: "$8.24",
                                                            item_quantity: "1",
                                                            item_description: "A bed of fresh pastrami topped with cool ranch pastrami.",
                                                            order_detail_id: "123",
                                                            note: "" }

          checkout_return[:order_summary][:order_data_as_ids_for_cart_update][:items] << new_item_hash.merge(status: "saved",
                                                                                                             order_detail_id: "123")

          checkout_stubs(body: cart_hash, return: checkout_return)

          click_button("Checkout - 176 pts + $8.24")
        end

        it "should not show loyalty button in edit item modal if there isn't enough points available" do
          ## Checkout#new page
          loy_items = all(:xpath, "//td[@class='price'][contains(text(),'pts')]/preceding-sibling::td/descendant::div[@class='edit-item']")
          loy_items.each do |item|
            item.click
            expect(page).to have_css("button.add.points")
            expect(page).to have_css("button.add.cash")
            find("span[data-dialog-close]").click
          end

          items = all(:xpath, "//td[@class='price'][contains(text(),'$')]/preceding-sibling::td/descendant::div[@class='edit-item']")
          items.each do |item|
            item.click
            expect(page).to have_css("button.add.points", visible: false)
            expect(page).to have_css("button.add.cash")
            find("span[data-dialog-close]").click
          end
        end

        it "should show buttons if we remove an item to have enough points" do
          ## Checkout#new page
          loy_items = all(:xpath, "//td[@class='price'][contains(text(),'pts')]/preceding-sibling::td/descendant::div[@class='edit-item']")
          loy_items.each do |item|
            item.click
            expect(page).to have_css("button.add.points")
            expect(page).to have_css("button.add.cash")
            find("span[data-dialog-close]").click
          end

          items = all(:xpath, "//td[@class='price'][contains(text(),'$')]/preceding-sibling::td/descendant::div[@class='edit-item']")
          items.each do |item|
            item.click
            expect(page).to have_css("button.add.points", visible: false)
            expect(page).to have_css("button.add.cash")
            find("span[data-dialog-close]").click
          end

          ## Remove item
          cart_hash[:items].first[:status] = "deleted"
          cart_hash[:total_points_used] = 88
          checkout_return[:order_summary][:cart_items].delete_at(0)
          checkout_return[:order_summary][:order_data_as_ids_for_cart_update][:items].delete_at(0)

          checkout_stubs(body: cart_hash, return: checkout_return)

          first("div.remove-item").click

          items = all(:xpath, "//td[@class='price'][contains(text(),'$')]/preceding-sibling::td/descendant::div[@class='edit-item']")
          items.each do |item|
            item.click
            expect(page).to have_css("button.add.points")
            expect(page).to have_css("button.add.cash")
            find("span[data-dialog-close]").click
          end
        end
      end
    end

    it "should show loyalty button and cash button in edit item modal in cash transaction" do
      ## Merchant#show page
      first("article.item").click
      all("section#size label")[2].click ## The one with points
      first("button.add.cash").click

      items = cart_session_items

      first(".my-order-link").click

      checkout_stubs(body: { items: [{ item_id: 931,
                                       quantity: 1,
                                       mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                                mod_quantity: 1,
                                                name: "Spicy Club Sauce" }],
                                       size_id: "1",
                                       order_detail_id: nil,
                                       external_detail_id: items.first["uuid"],
                                       status: "new",
                                       points_used: nil,
                                       brand_points_id: nil,
                                       note: "" }] },
                     return: { order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                             item_price: "6.89",
                                                             item_quantity: "1",
                                                             item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                             order_detail_id: "27479804",
                                                             note: "" }],
                                                order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                     user_id: "4777193",
                                                                                     items: [{ item_id: "931",
                                                                                               size_id: "1",
                                                                                               quantity: "1",
                                                                                               order_detail_id: "27479804",
                                                                                               external_detail_id: items.first["uuid"],
                                                                                               status: "saved",
                                                                                               mods: [{ modifier_item_id: "2",
                                                                                                        mod_quantity: "1" }] }] },
                                                receipt_items: [{ title: "Subtotal",
                                                                  amount: "$6.89" },
                                                                { title: "Tax",
                                                                  amount: "$0.41" },
                                                                { title: "Total",
                                                                  amount: "$7.30" }] } })

      click_button("Checkout - $8.24")

      ## Checkout#new page
      first("div.edit-item").click

      expect(page).to have_css("button.add.points")
      expect(page).to have_css("button.add.cash")
    end
  end

  context "user with 10 points" do
    before do
      feature_sign_in(user_return: { brand_loyalty: { loyalty_number: "140105420000001793",
                                                      pin: "9189",
                                                      points: "10",
                                                      usd: "25" } })
    end

    it "should not show loyalty button if user does not have enough points" do
      ## Merchant#show page
      first("article.item").click
      all("section#size label")[2].click ## The one with points
      first("button.add.cash").click

      items = cart_session_items

      first(".my-order-link").click

      checkout_stubs(body: { items: [{ item_id: 931,
                                       quantity: 1,
                                       mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                                mod_quantity: 1,
                                                name: "Spicy Club Sauce" }],
                                       size_id: "1",
                                       order_detail_id: nil,
                                       external_detail_id: items.first["uuid"],
                                       status: "new",
                                       points_used: nil,
                                       brand_points_id: nil,
                                       note: "" }] },
                     return: { order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                               item_price: "6.89",
                                                               item_quantity: "1",
                                                               item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                               order_detail_id: "27479804",
                                                               note: "" }],
                                                order_data_as_ids_for_cart_update: { merchant_id: "102237",
                                                                                     user_id: "4777193",
                                                                                     items: [{ item_id: "931",
                                                                                               size_id: "1",
                                                                                               quantity: "1",
                                                                                               order_detail_id: "27479804",
                                                                                               external_detail_id: items.first["uuid"],
                                                                                               status: "saved",
                                                                                               mods: [{ modifier_item_id: "2",
                                                                                                        mod_quantity: "1" }] }] },
                                                receipt_items: [{ title: "Subtotal",
                                                                  amount: "$6.89" },
                                                                 { title: "Tax",
                                                                   amount: "$0.41" },
                                                                 { title: "Total",
                                                                   amount: "$7.30" }] } })

      click_button("Checkout - $8.24")

      ## Checkout#new page
      first("div.edit-item").click

      expect(page).to have_css("button.add.points", visible: false)
      expect(page).to have_css("button.add.cash")
    end
  end

  context "pay with loyalty rewards" do
    before do
      feature_sign_in

      allow_any_instance_of(OrdersController).to receive(:uuid).and_return(2391731239)

      checkout_stubs(body: { items: [{ item_id: 931,
                                       quantity: 1,
                                       mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                                mod_quantity: 1,
                                                name: "Spicy Club Sauce" }],
                                       size_id: "3",
                                       order_detail_id: nil,
                                       external_detail_id: 2391731239,
                                       status: "new",
                                       points_used: nil,
                                       brand_points_id: nil,
                                       note: "" }] },
                     return: { user_info: { last_four: "1111" },
                               accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                          name: "Cash",
                                                          splickit_accepted_payment_type_id: "1000",
                                                          billing_entity_id: nil },
                                                        { merchant_payment_type_map_id: "2000",
                                                          name: "Credit Card",
                                                          splickit_accepted_payment_type_id: "2000",
                                                          billing_entity_id: nil },
                                                        { merchant_payment_type_map_id: "8000",
                                                          name: "Loyalty Balance($3.81) + CreditCard",
                                                          splickit_accepted_payment_type_id: "8000",
                                                          billing_entity_id: nil },
                                                        { merchant_payment_type_map_id: "8001",
                                                          name: "Loyalty Balance($3.81) + Cash",
                                                          splickit_accepted_payment_type_id: "8000",
                                                          billing_entity_id: nil }] })
    end

    it "should display new payments and new info on checkout and last order page" do
      first("article.item").click
      first("button.checkout").click

      expect(page).to have_content("Place order")

      within "div#payment" do
        expect(first("span.cash-label").text).to eq("Cash")
        expect(first("span.credit-label").text).to eq("••••1111")
        loyalty_labels = all("span.loyalty-label")
        expect(loyalty_labels.first.text).to eq("Loyalty Balance($3.81) + CreditCard")
        expect(loyalty_labels.last.text).to eq("Loyalty Balance($3.81) + Cash")
      end

      order_submit_stub(auth_token: "ASNDKASNDAS",
                        body: { user_id: "2", cart_ucid: "9705-j069h-ce8w3-425di", tip: "1.03", note: "",
                                merchant_payment_type_map_id: "8000" },
                        return: { loyalty_earned_label: "Congratulations! You just earned",
                                  loyalty_earned_message: "88 Points",
                                  loyalty_balance_label: "*New Rewards Balance",
                                  loyalty_balance_message: "$43",
                                  order_summary: { cart_items: [{ item_name: "Pastrami Salad",
                                                                  item_price: "8.24",
                                                                  item_quantity: "1",
                                                                  item_description: "Spicy Club Sauce",
                                                                  order_detail_id: "6082053",
                                                                  note: "" }],
                                                   receipt_items: [{ title: "Subtotal",
                                                                     amount: "$8.24" },
                                                                   { title: "Tax",
                                                                     amount: "$0.41" },
                                                                   { title: "Total",
                                                                     amount: "$8.65" }],
                                                   payment_items: [{ title: "Rewards Used",
                                                                     amount: "- $8" },
                                                                   { title: "Credit Card Charged",
                                                                     amount: "$0.65" }] } })

      find("#tip #tip").find(:xpath, "option[4]").select_option

      first("div.payment-type.loyalty label").click

      first("button#create_checkout_submit").click

      expect(page).to have_content("Thanks! Your order has been placed.")

      ## Loyalty message
      within "#loyalty" do
        expect(page).to have_content("Earned")
        expect(page).to have_content("88 Points")
        expect(page).to have_content("Rewards Balance")
        expect(page).to have_content("$43")
      end

      ## Payment items
      within "table#total" do
        expect(page).to have_css("td.price", count: 3)
        expect(page).to have_css("td.title", count: 2)
        expect(page).to have_content("Rewards Used")
        expect(page).to have_content("- $8")
        expect(page).to have_content("Credit Card Charged")
        expect(page).to have_content("$0.65")
      end
    end
  end
end