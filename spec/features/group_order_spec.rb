require "support/feature_spec_helper"

describe "Group Orders", js: true do
  let!(:user_data) { get_user_data }

  let(:menu_data) { get_default_menu }
  let(:menu) { menu_data[:menu] }
  let(:modifier_item_1) { menu_data[:modifier_item_1] }

  let(:merchant) do
    merchant = Merchant.new
    merchant.merchant_id = "102237"
    merchant.name = "Coeur d'Restaurant"
    merchant.display_name = "Coeur d'Alene"
    merchant.address1 = "320 Sherman Ave"
    merchant.city = "Coeur d'Alene"
    merchant.state = "83814"
    merchant.delivery = "Y"
    merchant.group_ordering_on = "1"
    merchant.show_tip = true
    merchant.menu = menu

    merchant
  end

  let(:checkout_group_order_items_body) {
    { group_order_token: "9109-nyw5d-g8225-irawz",
      merchant_id: merchant.merchant_id,
      items: [{ item_id: 931,
                quantity: 1,
                mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                         mod_quantity: 1,
                         name: "Spicy Club Sauce"}],
                size_id: "3",
                order_detail_id: nil,
                status: "new",
                external_detail_id: 92391731240,
                points_used: nil,
                brand_points_id: nil,
                note: "" }] }
  }

  before do
    merchant_where_stub(params: { location: "83814" },
                        auth_token: user_data["splickit_authentication_token"],
                        return: { merchants: [merchant.as_json(root: false)], promos: [] })

    group_order_create_stub(auth_token: user_data["splickit_authentication_token"])

    visit merchants_path

    # We add group order token nil to show that user doesn't have a previous group order
    feature_sign_in(email: "mr@bean.com",
                    password: "password",
                    user_return: user_data.merge("group_order_token" => nil))
  end

  shared_examples "group order add items" do
    it "should appear all popup texts and my order modal" do
      expect(page.first("div#item-added-popup h3").text).to eq("Item Added to My Cart")

      within("div.item-added-link-group") do
        expect(page).to have_link("View order")
        expect(page).to have_link("Submit to Group Order")
      end

      ## Should show 'My group order' and redirect to checkout page
      find("a#item-added-view-order").click
      expect(page).to have_content "My group order"
      expect(page).to have_selector ".submit-order.group-order"
      first('button.submit-order.group-order').click
      expect(URI.parse(current_url).request_uri).to eq(new_checkout_path(group_order_token: "9109-nyw5d-g8225-irawz",
                                                                         merchant_id: merchant.merchant_id,
                                                                         order_type: order_type))
    end
  end

  shared_examples "group order checkout page #title pickup" do
    it "should show correct title" do
      expect(page).to have_content("Place group order")
    end
  end

  shared_examples "group order checkout page #title delivery" do
    it "should show correct title" do
      expect(page).to have_content("Place group order - Delivery")
    end
  end

  shared_examples "group order checkout page #checkout summary" do
    it "should show checkout elements" do
      within "#summary" do
        expect(page).to have_content "320 Sherman Ave"
        expect(page).to have_content "Coeur d'Alene, 83814"
        expect(page).to have_content "Ham n' Eggs"
        expect(page).to have_content "$6.89"
        expect(page).to have_content "Subtotal"
        expect(page).to have_content "$6.89"
        expect(page).to have_content "Tax"
        expect(page).to have_content "$0.41"
        expect(page).to have_content "$7.30"
      end

      within "div#buttons" do
        expect(page).to have_content "Submit to Group Order"
      end
    end
  end

  shared_examples "group order checkout page #checkout summary 'promo code' you pay" do
    it "should not show promo code section" do
      expect(page).to_not have_content "Add promotional code"
    end
  end

  shared_examples "group order checkout page #checkout summary 'promo code' invitees pay" do
    it "should show promo code section" do
      within "#summary" do
        expect(page).to have_content "Add promotional code"
      end
    end
  end

  shared_examples "group order checkout page #checkout detail 'notes'" do
    it "should show order notes" do
      expect(page).to have_content "Order notes"
    end
  end

  shared_examples "group order checkout page #checkout detail 'delivery info'" do
    it "should show delivery info" do
      within "#details" do
        expect(page).to have_css "div.delivery-address"

        expect(page).to have_content "Delivering to:"
        expect(page).to have_content "6450 York St, Denver, CO 80229"
      end

    end
  end

  shared_examples "group order checkout page #checkout detail you pay" do
    it "should not show time, tip and card payment information" do
      within "#details" do
        expect(page).to_not have_content "Select a pickup time"
        expect(page).to_not have_content "Select a tip"
        expect(page).to_not have_content "Payment information"
      end
    end
  end

  shared_examples "group order checkout page #checkout detail invitees pay" do
    it "should not show time" do
      within "#details" do
        expect(page).to_not have_content "Select a pickup time"
        expect(page).to have_content "Your Order will be ready with the Group Order"

      end
    end

    it "should  show tip and card payment information" do
      within "#details" do
        expect(page).to have_content "Select a tip"
        expect(page).to have_content "Payment information"
      end
    end
  end

  shared_examples "group order last order page common content" do
    it "should contain common elements" do
      expect(page).to have_content "Email:"
      expect(page).to have_content "#{ user_data['email'] }"
      expect(page).to have_content "Save this order as a favorite."
    end
  end

  shared_examples "group order last order pay not submit" do
    it "should contain the group order status button" do
      expect(page).not_to have_content("Order Number: 102237")
    end
  end

  shared_examples "group order last order invitee pay" do
    it "should display group order submit and ready time" do
      expect(page).to have_content("Pickup Time:")
    end
  end

  context "without authentication" do
    before do
      merchant_where_stub(params: { location: "83814" },
                          return: { merchants: [merchant.as_json(root: false)], promos: [] })

      feature_sign_out

      fill_in("location", with: "83814")
      click_button("Search")

      find(:xpath, "//input[@class='checkbox-group-order'][@value='102237']/..").click

      within("aside") do
        click_link("Pickup")
      end
    end

    it "should not appear 'continue as a guest' button" do
      within "div.sign-in" do
        expect(page).not_to have_css("a", text: "Continue as Guest")
      end
    end
  end

  describe "organizer" do
    before do
      fill_in("location", with: "83814")
      click_button("Search")

      find(:xpath, "//input[@class='checkbox-group-order'][@value='102237']/..").click
    end

    shared_examples "group order new page" do
      it "#should verify title" do
        expect(page).to have_content("START YOUR GROUP ORDER")
        expect(page).to have_content("Coeur d'Alene, 83814")

        within "#group-order-type" do
          expect(page).to have_content("You Pay")
          expect(page).to have_content("Invitees Pay")
        end

        within ".right-container" do
          expect(page).to have_content("Please anticipate an average of 45 minutes from the time your order is placed, to your actual pickup or delivery time. You'll see your estimated pickup/delivery time once you place the order.")
        end

        ## should send button should redirect to status
        click_button("Send")

        expect(URI.parse(current_url).request_uri).to include(group_order_path("9109-nyw5d-g8225-irawz"))
      end
    end

    shared_examples "group order new you pay" do
      it "shouldn't display submit options" do
        expect(page).to have_selector "input[type=radio]", visible: false, count: 2
        view_hidden_elements do
          expect(find("input#you-pay")).to be_checked
          expect(find("input#invitees-pay")).not_to be_checked
        end
      end
    end

    shared_examples "group order new invitees pay" do
      it "should display the submit options" do
        group_order_available_times_find_stub(auth_token: user_data["splickit_authentication_token"],
                                              merchant_id: merchant.merchant_id)

        within "#group-order-type" do
          page.find("label[for='invitees-pay']").click
          expect(page).to have_content("Select order submit time")
          expect(page).to have_selector("select#group_order_submit_at_ts")
        end

        expect(page).to have_content("Please select a time you would like your order to be submitted.")
      end
    end

    shared_examples "group order show page" do
      it "should show merchant info" do
        expect(page).to have_content("Group order successfully created!")

        within ".left-container" do
          expect(page).to have_content("Ordering from:")
          expect(page).to have_content("320 Sherman Ave")
          expect(page).to have_content("Coeur d'Alene, 83814")
        end

        expect(page).to have_css("a#add")
        expect(find("a#add").text).to eq("Add items")

        expect(page).to have_css("span#submitted-orders", text: "1")

        expect(page).to have_css("form#cancel input.secondary")
        expect(find("form#cancel input.secondary").value).to eq("Cancel")

        group_order_find_stub(auth_token: user_data["splickit_authentication_token"],
                              return: return_data.merge(total_submitted_orders: "2"))

        visit(group_order_path("9109-nyw5d-g8225-irawz"))

        expect(page).to have_css("span#submitted-orders", text: "2")

        find("a#add").click
        expect(URI.parse(current_url).request_uri).to include(merchant_path(id: merchant.merchant_id,
                                                                            group_order_token: "9109-nyw5d-g8225-irawz",
                                                                            order_type: order_type))
      end

      it "should verify cancel group order dialog and disable checkout button" do
        ## should disable checkout button
        group_order_find_stub(auth_token: "ASNDKASNDAS",
                              return: return_data.merge(total_submitted_orders: "0"))

        visit(group_order_path("9109-nyw5d-g8225-irawz"))

        expect(page.find("a#checkout")[:disabled]).to be_truthy

        ## should verify cancel group order dialog
        find("form#cancel input.secondary").click

        within("div#cancel-group-order") do
          expect(page).to have_content("Cancel group order")
          expect(page).to have_content("Do not cancel")
          find("button#cancel-abort").click
        end

        expect(page).to_not have_css("div#cancel-group-order")

        find("form#cancel input.secondary").click

        group_order_delete_stub(auth_token: user_data["splickit_authentication_token"])

        within("div#cancel-group-order") do
          find("button#cancel-proceed").click
        end

        expect(URI.parse(current_url).request_uri).to include(root_path)
      end
    end

    shared_examples "group order show page delivery" do
      it "should show title" do
        expect(page).to have_content("Group order - delivery")
      end
    end

    shared_examples "group order show page pickup" do
      it "should show title" do
        expect(page).to have_content("Group order - pickup")
      end
    end

    shared_examples "group order show page you pay" do
      it "should display items data" do
        expect(page).to have_css("div.data-row.user-item", count: 1)

        expect(find("div.data-row.user-item h3").text).to have_content("test")
        expect(find("div.data-row.user-item h3 span").text).to have_content("10.00")
        expect(first("div.data-row.user-item p").text).to have_content("test description")
        expect(all("div.data-row.user-item p").last.text).to have_content("Notes: test_note")

        expect(page).to have_content "#{ merchant_path(id: merchant.merchant_id, group_order_token: "9109-nyw5d-g8225-irawz", order_type: order_type) }"

        expect(page).to have_css("a#checkout")
        expect(find("a#checkout").text).to eq("Checkout")

        ## should not display items data
        group_order_find_stub(auth_token: user_data["splickit_authentication_token"],
                              return: return_data.merge(order_summary: nil))

        visit(group_order_path("9109-nyw5d-g8225-irawz"))
        expect(page).to have_content("No items have been added to the group order yet.")
      end
    end

    shared_examples "group order show page invitee pay" do
      it "should_display_users_data" do
        expect(page).to have_css("tr.data-row.user-order", count: 1)
        order_column_list = all("tr.data-row.user-order td")
        expect(order_column_list.first.text).to eq("1. test (2)")
        expect(order_column_list.last.text).to eq("Submitted")

        ## should show place order now button
        expect(page).to have_css("a#checkout")
        expect(find("a#checkout").text).to eq("Place Order Now!")

        ## should show group order status
        expect(page).to have_css("span#status", text: "active")

        ## should show title
        expect(page).to have_content("Group Order will be submitted at 9:31 pm")

        ## should display Add 10 minutes button
        group_order_increment_stub(auth_token: "ASNDKASNDAS", return: { send_on_local_time_string: "9:41 pm" })

        expect(page).to have_css("button#increment-button", text: "Add 10 minutes")

        find("button#increment-button").click

        expect(page).to have_content("Group Order will be submitted at 9:41 pm")

        ## should display dialog if the increment fails
        group_order_increment_stub(auth_token: "ASNDKASNDAS", error: { error: "error_message" })

        find("button#increment-button").click

        expect(page).to have_content("Sorry your auto submit time can not be pushed back any farther.")

        find("button.modal-close").click

        ## should not display users data
        group_order_find_stub(auth_token: user_data["splickit_authentication_token"],
                              return: return_data.merge(order_summary: nil))

        visit(group_order_path("9109-nyw5d-g8225-irawz"))
        expect(page).to have_content("No users have submitted their order to the group order yet.")
      end
    end

    shared_examples "group order show group order button" do
      it "show group order status in any page" do
        ## should show group order status in group order status page
        verify_show_group_order_status_link

        visit(root_path)
        verify_show_group_order_status_link

        stub_request(:get, "#{ API.protocol }://splickit_authentication_token:#{ user_data["splickit_authentication_token"] }@#{ API.domain }#{ API.base_path }/users/#{ user_data["user_id"] }/orderhistory?page=1").
          to_return(:status => 200, :body => {data: get_user_orders_json}.to_json, :headers => {})

        visit(orders_history_user_path)
        verify_show_group_order_status_link
      end
    end

    shared_examples "group order last order organizer" do
      it "should contain the group order status button" do
        expect(page).to have_link("GROUP ORDER STATUS", href: "/group_order/9109-nyw5d-g8225-irawz")
        click_link("GROUP ORDER STATUS")
        expect(URI.parse(current_url).request_uri).to eq("/group_order/9109-nyw5d-g8225-irawz")
      end
    end

    shared_examples "group order nav organizer" do
      it "should show My Group order link" do
        expect(page).to have_selector("div.group-order.group-order-status")
        expect(page.first("a.my-order-link span").text).to eq("MY GROUP ORDER")
      end
    end

    context "--> pickup" do
      let (:order_type) { "pickup" }

      before do
        merchant_find_stub(merchant_id: merchant.merchant_id,
                           auth_token: user_data["splickit_authentication_token"],
                           return: merchant.as_json(root: false))

        allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)

        within("aside") do
          click_link("Pickup")
        end
      end

      it "should return to home and create GO" do
        page.evaluate_script("window.history.back()")

        within("aside") do
          click_link("Pickup")
        end

        expect(URI.parse(current_url).request_uri).to include(new_group_orders_path)
      end

      it_behaves_like "group order new page"

      it_behaves_like "group order new you pay"

      it_behaves_like "group order new invitees pay"

      context "- you pay" do
        let(:return_data) do
          { merchant_menu_type: "pickup",
            total_submitted_orders: "1",
            order_summary: { cart_items: [{ order_detail_id: 1,
                                            item_name: "test",
                                            item_price: "10.00",
                                            item_description: "test description",
                                            item_note: "test_note" }]}}
        end

        before do
          group_order_find_stub(auth_token: user_data["splickit_authentication_token"],
                                return: return_data)

          group_order_find_stub(auth_token: {email: "admin", password: "welcome"},
                                return: return_data)

          checkout_stubs(body: checkout_group_order_items_body,
                         return: { lead_times_array: [],
                                   accepted_payment_types: [],
                                   tip_array: [],
                                   grand_total: "7.30",
                                   order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                   item_price: "6.89",
                                                                   item_quantity: "1",
                                                                   item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                   order_detail_id: "6082053",
                                                                   note: "" }],
                                                    order_data_as_ids_for_cart_update: { merchant_id: merchant.merchant_id,
                                                                                         user_id: "4777193",
                                                                                         items: [{ item_id: "931",
                                                                                                   size_id: "1",
                                                                                                   quantity: "1",
                                                                                                   order_detail_id: "6082053",
                                                                                                   external_detail_id: 92391731240,
                                                                                                   status: "saved",
                                                                                                   mods: [{ modifier_item_id: "2",
                                                                                                            mod_quantity: "1" }] }] },
                                                    receipt_items: [{ title: "Subtotal",
                                                                      amount: "$6.89" },
                                                                    { title: "Tax",
                                                                      amount: "$0.41" },
                                                                    { title: "Tip",
                                                                      amount: "$0.00" },
                                                                    { title: "Total",
                                                                      amount: "$7.30" }] } })

          order_submit_stub({auth_token: user_data["splickit_authentication_token"],
                             body: {
                               cart_ucid: "9705-j069h-ce8w3-425di",
                               user_id: user_data["user_id"],
                               requested_time: nil
                             },
                             return: {tip_amt: 0,
                                      order_summary: {cart_items: [{item_name: "Ham n' Eggs",
                                                                    item_price: "6.89",
                                                                    item_quantity: "1",
                                                                    item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                    order_detail_id: "6082053",
                                                                    note: ""}],
                                                      receipt_items: [{title: "Subtotal",
                                                                       amount: "$6.89"},
                                                                      {title: "Tax",
                                                                       amount: "$0.41"},
                                                                      {title: "Total",
                                                                       amount: "$7.30"}]}
                             }
                            })

          page.find("label[for='you-pay']").click

          click_button("Send")
        end

        it_behaves_like "group order show page"

        it_behaves_like "group order show page you pay"

        context "submit group order" do
          before do
            checkout_stubs(cart_id: "9109-nyw5d-g8225-irawz",
                           no_items: true,
                           body: { group_order_token:"9109-nyw5d-g8225-irawz",
                                   merchant_id: merchant.merchant_id },
                           return: { ucid: "9109-nyw5d-g8225-irawz",
                                     grand_total: "14.60",
                                     user_info: { last_four: "1111" },
                                     accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                                name: "Credit Card",
                                                                splickit_accepted_payment_type_id: "2000",
                                                                billing_entity_id: nil }],
                                     order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                     item_price: "6.89",
                                                                     item_quantity: "1",
                                                                     item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                     note: "" },
                                                                   { item_name: "Ham n' Eggs",
                                                                     item_price: "6.89",
                                                                     item_quantity: "1",
                                                                     item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                     note: "" }],
                                                      receipt_items: [{ title: "Subtotal",
                                                                        amount: "$13.78" },
                                                                      { title: "Tax",
                                                                        amount: "$0.82" },
                                                                      { title: "Tip",
                                                                        amount: "$0.00" },
                                                                      { title: "Total",
                                                                        amount: "$14.60" }] } })
            find("a#checkout").click
          end

          it_behaves_like "group order checkout page #title pickup"

          it "should show order summary" do
            within "#summary" do
              expect(page).to have_content "320 Sherman Ave"
              expect(page).to have_content "Coeur d'Alene, 83814"
              expect(page).to have_content "Ham n' Eggs", count: 2
              expect(page).to have_content "6.89", count: 2
              expect(page).to have_content "Subtotal"
              expect(page).to have_content "$13.78"
              expect(page).to have_content "Tax"
              expect(page).to have_content "$0.82"
              expect(page).to have_content "$14.60"
            end
          end

          it_behaves_like "group order checkout page #checkout detail 'notes'"

          it "should show promo code section" do
            within "#summary" do
              expect(page).to have_content "Add promotional code"
            end

            ## should show time, tip and card payment information
            within "#details" do
              expect(page).to have_content "Select a pickup time"
              expect(page).to have_content "Select a tip"
              expect(page).to have_content "Payment information"
            end
          end

          context "group order last order page" do
            before do
              user_find_stub(auth_token: "ASNDKASNDAS", return: user_data.merge("group_order_token" => "9109-nyw5d-g8225-irawz"))

              order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                                body: { cart_ucid: "9109-nyw5d-g8225-irawz",
                                        user_id: user_data["user_id"],
                                        tip: "0.69",
                                        note: "Something with bacon, please.",
                                        merchant_payment_type_map_id:"1000",
                                        requested_time: "1415823383" },
                                return: { tip_amt: 0.69,
                                          order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                          item_price: "6.89",
                                                                          item_quantity: "1",
                                                                          item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                          order_detail_id: "6082053",
                                                                          note: "" }],
                                                           receipt_items: [{ title: "Subtotal",
                                                                             amount: "$6.89" },
                                                                           { title: "Tax",
                                                                             amount: "$0.41" },
                                                                           { title: "Total",
                                                                             amount: "$7.30" }] } })

              find("#tip #tip").find(:xpath, "option[3]").select_option
              fill_in("Order notes", with: "Something with bacon, please.")

              find_button("Submit to Group Order").click
            end

            it_behaves_like "group order last order page common content"

            it_behaves_like "group order last order organizer"

            it "should contain last order elements" do
              expect(page).to have_content("Order Number:")
              expect(page).to have_content "Your order has been submited to the Group Order!"

              ## Should not show invitees link on status page
              group_order_find_stub(auth_token: "ASNDKASNDAS",
                                    return: return_data.merge(status: "SUBMITTED"))

              click_link("GROUP ORDER STATUS")

              expect(page).not_to have_content("Invite more people to this order")
              expect(page).not_to have_content("Invite people to this order by pasting the link below into chat, share via email, etc. Anyone with the link will be able to add items to your group order.")
              expect(page).not_to have_content("Share link")
            end
          end
        end

        it_behaves_like "group order show page pickup"

        it_behaves_like "group order show group order button"

        context "Add items" do
          before do
            group_order_find_stub(auth_token: { email: "admin", password: "welcome" },
                                  return: return_data)

            find("a#add").click
            first("article").click
            first("button.add.cash").click
          end

          it_behaves_like "group order add items"

          it_behaves_like "group order nav organizer"

          context "group order checkout order items" do
            before do
              find(".my-order-link").click
              first('button.submit-order').click
            end

            it_behaves_like "group order checkout page #title pickup"

            it_behaves_like "group order checkout page #checkout summary"

            it_behaves_like "group order checkout page #checkout summary 'promo code' you pay"

            it_behaves_like "group order checkout page #checkout detail 'notes'"

            it_behaves_like "group order checkout page #checkout detail you pay"

            it "last order page " do
              find_button("Submit to Group Order").click
              expect(URI.parse(current_url).request_uri).to eq("/last_order")
            end

            context "group order last order page" do
              before do
                user_find_stub(auth_token: "ASNDKASNDAS", return: user_data.merge("group_order_token" => "9109-nyw5d-g8225-irawz"))
                find_button("Submit to Group Order").click
              end

              it_behaves_like "group order last order page common content"

              it_behaves_like "group order last order organizer"

              it_behaves_like "group order last order pay not submit"

              it "should contain group order information to pickup option" do
                expect(page).to have_content "Note: On pickup, just bypass the line and ask for your order."
              end
            end
          end
        end
      end

      context "- invitee pay" do
        let(:return_data) do
          { merchant_menu_type: "pickup",
            group_order_type: "2",
            total_submitted_orders: "1",
            order_summary: { user_items: [{ full_name: "test",
                                            item_count: "2",
                                            status: "Submitted" }] } }
        end

        before do
          group_order_create_stub(auth_token: user_data["splickit_authentication_token"],
                                  body: {group_order_type: "2", submit_at_ts: "1460561760"})

          group_order_find_stub(auth_token: user_data["splickit_authentication_token"],
                                return: return_data)

          group_order_find_stub(auth_token: {email: "admin", password: "welcome"},
                                return: return_data)

          checkout_stubs(body: checkout_group_order_items_body,
                         return: { lead_times_array: [1415823683],
                                   grand_total: "7.30",
                                   accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                              name: "Credit Card",
                                                              splickit_accepted_payment_type_id: "2000",
                                                              billing_entity_id: nil }],
                                   order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                   item_price: "6.89",
                                                                   item_quantity: "1",
                                                                   item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                   order_detail_id: "6082053",
                                                                   note: "" }],
                                                    order_data_as_ids_for_cart_update: { merchant_id: merchant.merchant_id,
                                                                                         user_id: "4777193",
                                                                                         items: [{ item_id: "931",
                                                                                                   size_id: "1",
                                                                                                   quantity: "1",
                                                                                                   order_detail_id: "6082053",
                                                                                                   external_detail_id: 92391731240,
                                                                                                   status: "saved",
                                                                                                   mods: [{ modifier_item_id: "2",
                                                                                                            mod_quantity: "1" }] }] },
                                                  receipt_items: [{ title: "Subtotal",
                                                                    amount: "$6.89" },
                                                                  { title: "Tax",
                                                                    amount: "$0.41" },
                                                                  { title: "Tip",
                                                                    amount: "$0.00" },
                                                                  { title: "Total",
                                                                    amount: "$7.30" }] } })

          order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                            body: { cart_ucid: "9705-j069h-ce8w3-425di",
                                    user_id: user_data["user_id"],
                                    requested_time: "1415823683",
                                    tip: "0.69",
                                    note: "Something with bacon, please.",
                                    merchant_payment_type_map_id: "1000" },
                            message: "Your order to Pita Pit will be ready for pickup at 10:00am",
                            return: { tip_amt: 0.69,
                                      requested_time_string: "10:00 AM",
                                      order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                      item_price: "6.89",
                                                                      item_quantity: "1",
                                                                      item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                      order_detail_id: "6082053",
                                                                      note: "" }],
                                                      receipt_items: [{ title: "Subtotal",
                                                                        amount: "$6.89" },
                                                                      { title: "Tax",
                                                                        amount: "$0.41" },
                                                                      { title: "Total",
                                                                        amount: "$7.99" }] } })

          group_order_available_times_find_stub(auth_token: user_data["splickit_authentication_token"],
                                                merchant_id: merchant.merchant_id)

          within "#group-order-type" do
            page.find("label[for='invitees-pay']").click
            find("select#group_order_submit_at_ts").find(:xpath, "option[4]").select_option
          end

          click_button("Send")
        end

        it_behaves_like "group order show page"

        it_behaves_like "group order show page invitee pay"

        context "submit group order" do
          before do
            group_order_submit_stub({ auth_token: user_data["splickit_authentication_token"] })
            find("a#checkout").click
          end

          it "should redirect to home" do
            expect(page).to have_link "Return to home"
            click_link("Return to home")
            expect(URI.parse(current_url).request_uri).to include(root_path)
          end

          it "should have group order success elements" do
            expect(page).to have_content "Your Order was Successful"
            expect(page).to have_content "Thank you. Enjoy your order."

            ## Should not show invitees link on status page
            group_order_find_stub(auth_token: "ASNDKASNDAS",
                                  return: return_data.merge(status: "submitted"))

            expect(page).to have_link "Group Order Status"
            click_link("Group Order Status")
            expect(URI.parse(current_url).request_uri).to include(group_order_path("9109-nyw5d-g8225-irawz"))

            expect(page).not_to have_content("Invite more people to this order")
            expect(page).not_to have_content("Invite people to this order by pasting the link below into chat, share via email, etc. Anyone with the link will be able to add items to your group order.")
            expect(page).not_to have_content("Share link")

            expect(page).to have_button('Add 10 minutes', disabled: true)
            expect(find('a#add')[:disabled]).to eql 'true'
            expect(find('a#checkout')[:disabled]).to eql 'true'
            expect(find('input#btn_cancel')[:disabled]).to eql 'true'
          end
        end

        it_behaves_like "group order show page pickup"

        it_behaves_like "group order show group order button"

        context "Add items" do
          before do
            group_order_find_stub(auth_token: { email: "admin", password: "welcome" },
                                  return: return_data)

            find("a#add").click
            first("article").click
            first("button.add.cash").click
          end

          it_behaves_like "group order add items"

          it_behaves_like "group order nav organizer"

          context "group order checkout order items" do
            before do
              find(".my-order-link").click
              first('button.submit-order').click
            end

            it_behaves_like "group order checkout page #title pickup"

            it_behaves_like "group order checkout page #checkout summary"

            it_behaves_like "group order checkout page #checkout summary 'promo code' invitees pay"

            it_behaves_like "group order checkout page #checkout detail 'notes'"

            it_behaves_like "group order checkout page #checkout detail invitees pay"

            it "last order page " do
              find("#tip #tip").find(:xpath, "option[3]").select_option
              fill_in("Order notes", with: "Something with bacon, please.")

              find_button("Submit to Group Order").click
              expect(URI.parse(current_url).request_uri).to eq("/last_order")
            end

            context "group order last order page" do
              before do
                user_find_stub(auth_token: "ASNDKASNDAS", return: user_data.merge("group_order_token" => "9109-nyw5d-g8225-irawz"))
                find("#tip #tip").find(:xpath, "option[3]").select_option
                fill_in("Order notes", with: "Something with bacon, please.")
                find_button("Submit to Group Order").click
              end

              it_behaves_like "group order last order page common content"

              it_behaves_like "group order last order organizer"

              it_behaves_like "group order last order pay not submit"

              it_behaves_like "group order last order invitee pay"

              it "should contain group order information to pickup option" do
                expect(page).to have_content "Note: On pickup, just bypass the line and ask for your order."
              end
            end
          end
        end
      end
    end

    context "--> delivery" do
      let (:order_type) { "delivery" }

      before do
        merchant.trans_fee_rate = "0.25"

        merchant_find_stub(auth_token: user_data["splickit_authentication_token"],
                           delivery: true,
                           return: merchant.as_json(root: false),
                           merchant_id: merchant.merchant_id)

        merchant_indeliveryarea_stub(auth_token: user_data["splickit_authentication_token"],
                                     merchant_id: merchant.merchant_id,
                                     delivery_address_id: (user_data["delivery_locations"]).first["user_addr_id"])

        group_order_create_stub(auth_token: user_data["splickit_authentication_token"],
                                body: {merchant_menu_type: "delivery",
                                       user_addr_id: (user_data["delivery_locations"].first)["user_addr_id"]},
                                return: {delivery_address: {business_name: "Sherman Company",
                                                            address1: "350 Sherman Ave",
                                                            address2: "",
                                                            city: "Coeur d'Ham",
                                                            state: "ID",
                                                            zip: "83814"}})

        allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)

        within("aside") do
          click_link("Delivery")
        end

        click_button("Set")
      end

      it "should return to home and create GO" do
        page.evaluate_script("window.history.back()")

        within("aside") do
          click_link("Delivery")
        end

        click_button("Set")

        expect(URI.parse(current_url).request_uri).to include(new_group_orders_path)
      end

      it_behaves_like "group order new page"

      it_behaves_like "group order new you pay"

      it_behaves_like "group order new invitees pay"

      context "- you pay" do
        let(:return_data) do
          { delivery_address: {business_name: "Sherman Company",
                              address1: "350 Sherman Ave",
                              address2: "",
                              city: "Coeur d'Ham",
                              state: "ID",
                              zip: "83814" },
            merchant_menu_type: "delivery",
            total_submitted_orders: "1",
            order_summary: { cart_items: [{ order_detail_id: 1,
                                            item_name: "test",
                                            item_price: "10.00",
                                            item_description: "test description",
                                            item_note: "test_note" }] } }
        end

        before do
          group_order_create_stub(auth_token: user_data["splickit_authentication_token"],
                                  body: { merchant_menu_type: "delivery",
                                          user_addr_id: (user_data["delivery_locations"]).first["user_addr_id"],
                                          submit_at_ts: "1460561760",
                                          group_order_type: "2" },
                                  return: { delivery_address: {business_name: "Sherman Company",
                                                              address1: "350 Sherman Ave",
                                                              address2: "",
                                                              city: "Coeur d'Ham",
                                                              state: "ID",
                                                              zip: "83814" } })

          group_order_find_stub(auth_token: user_data["splickit_authentication_token"],
                                return: return_data)

          group_order_find_stub(auth_token: {email: "admin", password: "welcome"},
                                return: return_data)

          checkout_stubs(body: checkout_group_order_items_body.merge(user_addr_id:"5667",
                                                                     submitted_order_type: "delivery"),
                         return: { lead_times_array: [],
                                   accepted_payment_types: [],
                                   tip_array: [],
                                   grand_total: "7.30",
                                   order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                   item_price: "6.89",
                                                                   item_quantity: "1",
                                                                   item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                   order_detail_id: "6082053",
                                                                   note: "" }],
                                                    order_data_as_ids_for_cart_update: { merchant_id: merchant.merchant_id,
                                                                                         user_id: "4777193",
                                                                                         items: [{ item_id: "931",
                                                                                                   size_id: "1",
                                                                                                   quantity: "1",
                                                                                                   order_detail_id: "6082053",
                                                                                                   external_detail_id: 92391731240,
                                                                                                   status: "saved",
                                                                                                   mods: [{ modifier_item_id: "2",
                                                                                                            mod_quantity: "1" }] }] },
                                                    receipt_items: [{ title: "Subtotal",
                                                                      amount: "$6.89" },
                                                                    { title: "Tax",
                                                                      amount: "$0.41" },
                                                                    { title: "Tip",
                                                                      amount: "$0.00" },
                                                                    { title: "Total",
                                                                      amount: "$7.30" }] } })

          order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                            body: { cart_ucid: "9705-j069h-ce8w3-425di",
                                    user_id: user_data["user_id"],
                                    requested_time: nil,
                                    delivery_time: nil },
                            return: { tip_amt: 0,
                                      order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                      item_price: "6.89",
                                                                      item_quantity: "1",
                                                                      item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                      order_detail_id: "6082053",
                                                                      note: "" }],
                                                       receipt_items: [{ title: "Subtotal",
                                                                         amount: "$6.89"},
                                                                       { title: "Tax",
                                                                         amount: "$0.41"},
                                                                       { title: "Total",
                                                                         amount: "$7.30" }] } })

          page.find("label[for='you-pay']").click

          click_button("Send")
        end

        it_behaves_like "group order show page"

        it_behaves_like "group order show page you pay"

        context "submit group order" do
          before do
            checkout_stubs(cart_id: "9109-nyw5d-g8225-irawz",
                           no_items: true,
                           body: { group_order_token:"9109-nyw5d-g8225-irawz",
                                   merchant_id: merchant.merchant_id,
                                   submitted_order_type: "delivery",
                                   user_addr_id: "5667" },
                           return: { ucid: "9109-nyw5d-g8225-irawz",
                                     user_info: { last_four: "1111" },
                                     grand_total: "14.60",
                                     accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                                name: "Credit Card",
                                                                splickit_accepted_payment_type_id: "2000",
                                                                billing_entity_id: nil }],
                                     order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                     item_price: "6.89",
                                                                     item_quantity: "1",
                                                                     item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                     note: "" },
                                                                   { item_name: "Ham n' Eggs",
                                                                     item_price: "6.89",
                                                                     item_quantity: "1",
                                                                     item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                     note: "" }],
                                                      receipt_items: [{ title: "Subtotal",
                                                                      amount: "$13.78" },
                                                                      { title: "Tax",
                                                                        amount: "$0.82" },
                                                                      { title: "Tip",
                                                                        amount: "$0.00" },
                                                                      { title: "Total",
                                                                        amount: "$14.60" }] } })
            find("a#checkout").click
          end

          it_behaves_like "group order checkout page #title pickup"

          it "should show order summary" do
            within "#summary" do
              expect(page).to have_content "320 Sherman Ave"
              expect(page).to have_content "Coeur d'Alene, 83814"
              expect(page).to have_content "Ham n' Eggs", count: 2
              expect(page).to have_content "6.89", count: 2
              expect(page).to have_content "Subtotal"
              expect(page).to have_content "$13.78"
              expect(page).to have_content "Tax"
              expect(page).to have_content "$0.82"
              expect(page).to have_content "$14.60"
            end
          end

          it_behaves_like "group order checkout page #checkout detail 'notes'"

          it "should show promo code section" do
            within "#summary" do
              expect(page).to have_content "Add promotional code"
            end
          end

          it "should not show time, tip and card payment information" do
            within "#details" do
              expect(page).to have_content "Select a delivery time"
              expect(page).to have_content "Select a tip"
              expect(page).to have_content "Payment information"
            end
          end

          context "group order last order page" do
            before do
              user_find_stub(auth_token: "ASNDKASNDAS", return: user_data.merge("group_order_token" => "9109-nyw5d-g8225-irawz"))

              order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                                body: { cart_ucid: "9109-nyw5d-g8225-irawz",
                                        user_id: user_data["user_id"],
                                        tip: "0.69",
                                        note: "Something with bacon, please.",
                                        merchant_payment_type_map_id:"1000",
                                        requested_time: "1415823383",
                                        delivery_time: "Wed 11-12 08:16 PM" },
                                return: { tip_amt: 0.69,
                                          user_delivery_address: { user_addr_id: "5667",
                                                                   user_id: "2",
                                                                   name: "Metro Wastewater Reclamation Plant",
                                                                   address1: "6450 York St",
                                                                   address2: "Basement",
                                                                   city: "Denver",
                                                                   state: "CO",
                                                                   zip: "80229",
                                                                   lat: "39.8149386187446",
                                                                   lng: "-104.956209155655",
                                                                   phone_no: "(303) 286-3000",
                                                                   instructions: "wear cruddy shoes" },
                                          order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                          item_price: "6.89",
                                                                          item_quantity: "1",
                                                                          item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                          order_detail_id: "6082053",
                                                                          note: "" }],
                                                           receipt_items: [{ title: "Subtotal",
                                                                             amount: "$6.89"},
                                                                           { title: "Tax",
                                                                             amount: "$0.41"},
                                                                           { title: "Total",
                                                                             amount: "$7.30" }] } })

              find("#tip #tip").find(:xpath, "option[3]").select_option
              fill_in("Order notes", with: "Something with bacon, please.")

              find_button("Submit to Group Order").click
            end

            it_behaves_like "group order last order page common content"

            it_behaves_like "group order last order organizer"

            it "should contain the group order status button" do
              expect(page).to have_content("Order Number:")
            end

            it "should contain group order information to delivery option" do
              expect(page).to have_content "Delivery Address:"
              expect(page).to have_content "6450 York St, Denver, CO 80229"
            end
          end

        end

        it_behaves_like "group order show page delivery"

        it_behaves_like "group order show group order button"

        context "Add items" do
          before do
            group_order_find_stub(auth_token: { email: "admin", password: "welcome" },
                                  return: return_data)

            find("a#add").click
            first("article").click
            first("button.add.cash").click
          end

          it_behaves_like "group order add items"

          it_behaves_like "group order nav organizer"

          context "group order checkout order items" do
            before do
              find(".my-order-link").click
              first('button.submit-order').click
            end

            it_behaves_like "group order checkout page #title delivery"

            it_behaves_like "group order checkout page #checkout summary"

            it_behaves_like "group order checkout page #checkout summary 'promo code' you pay"

            it_behaves_like "group order checkout page #checkout detail 'delivery info'"

            it_behaves_like "group order checkout page #checkout detail 'notes'"

            it_behaves_like "group order checkout page #checkout detail you pay"

            it "last order page " do
              find_button("Submit to Group Order").click
              expect(URI.parse(current_url).request_uri).to eq("/last_order")
            end

            context "group order last order page" do
              before do
                user_find_stub(auth_token: "ASNDKASNDAS", return: user_data.merge("group_order_token" => "9109-nyw5d-g8225-irawz"))
                find_button("Submit to Group Order").click
              end

              it_behaves_like "group order last order page common content"

              it_behaves_like "group order last order organizer"

              it_behaves_like "group order last order pay not submit"
            end
          end
        end
      end

      context "- invitee pay" do
        let(:return_data) do
          { merchant_menu_type: "delivery",
            group_order_type: "2",
            total_submitted_orders: "1",
            order_summary: { user_items: [{ full_name: "test",
                                            item_count: "2",
                                            status: "Submitted" }] } }
        end

        before do
          group_order_create_stub(auth_token: user_data["splickit_authentication_token"],
                                  body: {merchant_menu_type: "delivery",
                                         user_addr_id: (user_data["delivery_locations"]).first["user_addr_id"],
                                         submit_at_ts: "1460561760",
                                         group_order_type: "2"},
                                  return: {delivery_address: {business_name: "Sherman Company",
                                                              address1: "350 Sherman Ave",
                                                              address2: "",
                                                              city: "Coeur d'Ham",
                                                              state: "ID",
                                                              zip: "83814"}})

          group_order_find_stub(auth_token: user_data["splickit_authentication_token"],
                                return: return_data)

          group_order_find_stub(auth_token: {email: "admin", password: "welcome"},
                                return: return_data)

          checkout_stubs(body: checkout_group_order_items_body.merge(submitted_order_type: "delivery",
                                                                     user_addr_id: "5667"),
                         return: { lead_times_array: [1415823683],
                                   user_info: { last_four: "1111" },
                                   grand_total: "7.30",
                                   accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                                              name: "Credit Card",
                                                              splickit_accepted_payment_type_id: "2000",
                                                              billing_entity_id: nil }],
                                   order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                   item_price: "6.89",
                                                                   item_quantity: "1",
                                                                   item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                   order_detail_id: "6082053",
                                                                   note: "" }],
                                                    order_data_as_ids_for_cart_update: { merchant_id: merchant.merchant_id,
                                                                                         user_id: "4777193",
                                                                                         items: [{ item_id: "931",
                                                                                                   size_id: "1",
                                                                                                   quantity: "1",
                                                                                                   order_detail_id: "6082053",
                                                                                                   external_detail_id: 92391731240,
                                                                                                   status: "saved",
                                                                                                   mods: [{ modifier_item_id: "2",
                                                                                                            mod_quantity: "1" }] }] },
                                                    receipt_items: [{ title: "Subtotal",
                                                                      amount: "$6.89"},
                                                                    { title: "Tax",
                                                                      amount: "$0.41"},
                                                                    { title: "Tip",
                                                                      amount: "$0.00"},
                                                                    { title: "Total",
                                                                      amount: "$7.30" }] } })

          order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                            body: { cart_ucid: "9705-j069h-ce8w3-425di",
                                    user_id: user_data["user_id"],
                                    requested_time: "1415823683",
                                    tip: "0.69",
                                    note: "Something with bacon, please.",
                                    delivery_time: "Wed 11-12 08:21 PM",
                                    merchant_payment_type_map_id: "1000" },
                            message: "Your order to Pita Pit will be ready for pickup at 10:00am",
                            return: { tip_amt: 0.69,
                                      requested_time_string: "10:00 AM",
                                      order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                      item_price: "6.89",
                                                                      item_quantity: "1",
                                                                      item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                      order_detail_id: "6082053",
                                                                      note: "" }],
                                                       receipt_items: [{ title: "Subtotal",
                                                                         amount: "$6.89"},
                                                                       { title: "Tax",
                                                                         amount: "$0.41"},
                                                                       { title: "Total",
                                                                         amount: "$7.99" }] } })

          group_order_available_times_find_stub(auth_token: user_data["splickit_authentication_token"],
                                                merchant_id: merchant.merchant_id,
                                                order_type: "delivery")

          within "#group-order-type" do
            page.find("label[for='invitees-pay']").click
            find("select#group_order_submit_at_ts").find(:xpath, "option[4]").select_option
          end

          click_button("Send")
        end

        it_behaves_like "group order show page"

        it_behaves_like "group order show page invitee pay"

        it_behaves_like "group order show page delivery"

        it_behaves_like "group order show group order button"

        context "Add items" do
          before do
            group_order_find_stub(auth_token: { email: "admin", password: "welcome" },
                                  return: return_data)

            find("a#add").click
            first("article").click
            first("button.add.cash").click
          end

          it_behaves_like "group order add items"

          it_behaves_like "group order nav organizer"

          context "group order checkout order items" do
            before do
              find(".my-order-link").click
              first('button.submit-order').click
            end

            it_behaves_like "group order checkout page #title delivery"

            it_behaves_like "group order checkout page #checkout summary"

            it_behaves_like "group order checkout page #checkout summary 'promo code' invitees pay"

            it_behaves_like "group order checkout page #checkout detail 'notes'"

            it_behaves_like "group order checkout page #checkout detail invitees pay"

            it "last order page" do
              find("#tip #tip").find(:xpath, "option[3]").select_option
              fill_in("Order notes", with: "Something with bacon, please.")

              find_button("Submit to Group Order").click
              expect(URI.parse(current_url).request_uri).to eq("/last_order")
            end

            context "group order last order page" do
              before do
                user_find_stub(auth_token: "ASNDKASNDAS", return: user_data.merge("group_order_token" => "9109-nyw5d-g8225-irawz"))
                find("#tip #tip").find(:xpath, "option[3]").select_option
                fill_in("Order notes", with: "Something with bacon, please.")
                find_button("Submit to Group Order").click
              end

              it_behaves_like "group order last order page common content"

              it_behaves_like "group order last order organizer"

              it_behaves_like "group order last order pay not submit"
            end
          end
        end
      end
    end
  end

  describe "participant" do
    context "--> you pay" do
      let(:checkout_return_hash) do
        { lead_times_array: [],
          accepted_payment_types: [],
          tip_array: [],
          grand_total: "7.30",
          order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                          item_price: "6.89",
                                          item_quantity: "1",
                                          item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                          order_detail_id: "6082053",
                                          note: "" }],
                           order_data_as_ids_for_cart_update: { merchant_id: merchant.merchant_id,
                                                                user_id: "4777193",
                                                                items: [{ item_id: "931",
                                                                          size_id: "1",
                                                                          quantity: "1",
                                                                          order_detail_id: "6082053",
                                                                          external_detail_id: 92391731240,
                                                                          status: "saved",
                                                                          mods: [{ modifier_item_id: "2",
                                                                                   mod_quantity: "1" }] }] },
                           receipt_items: [{ title: "Subtotal",
                                             amount: "$6.89" },
                                           { title: "Tax",
                                             amount: "$0.41" },
                                           { title: "Tip",
                                             amount: "$0.00" },
                                           { title: "Total",
                                             amount: "$7.30" }] } }
      end

      before do
        order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                          body: { cart_ucid: "9705-j069h-ce8w3-425di",
                                  user_id: user_data["user_id"],
                                  requested_time: nil,
                                  delivery_time: "Thu 01-01 12:00 AM" },
                          return: { tip_amt: 0,
                                    order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                    item_price: "6.89",
                                                                    item_quantity: "1",
                                                                    item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                    order_detail_id: "6082053",
                                                                    note: "" }],
                                                    receipt_items: [{ title: "Subtotal",
                                                                      amount: "$6.89" },
                                                                    { title: "Tax",
                                                                      amount: "$0.41" },
                                                                    { title: "Total",
                                                                      amount: "$7.30" }] } })

        order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                          body: { cart_ucid: "9705-j069h-ce8w3-425di",
                                  user_id: user_data["user_id"],
                                  requested_time: nil },
                          return: { tip_amt: 0,
                                    order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                    item_price: "6.89",
                                                                    item_quantity: "1",
                                                                    item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                    order_detail_id: "6082053",
                                                                    note: "" }],
                                                     receipt_items: [{ title: "Subtotal",
                                                                       amount: "$6.89" },
                                                                     { title: "Tax",
                                                                       amount: "$0.41" },
                                                                     { title: "Total",
                                                                       amount: "$7.30" }] } })

        merchant_find_stub(merchant_id: merchant.merchant_id,
                           auth_token: user_data["splickit_authentication_token"],
                           return: merchant.as_json(root: false))
      end

      context "#GO Error" do
        before do
          group_order_find_stub(auth_token: { email: "admin", password: "welcome" },
                                error: { error: "GO error", error_type: "group_order" })

          visit merchant_path(id: merchant.merchant_id, group_order_token: "9109-nyw5d-g8225-irawz", order_type: "pickup")
        end

        it "should render error message" do
          expect(URI.parse(current_url).request_uri).to eq(merchant_path(id: merchant.merchant_id, order_type: "pickup"))
          expect(page).to have_content("GO error")
        end
      end

      context "#pickup" do
        let (:order_type) { "pickup" }

        let(:return_data) {
          { merchant_menu_type: order_type,
            order_summary: { cart_items: [{ order_detail_id: 1,
                                           item_name: "test",
                                           item_price: "10.00",
                                           item_description: "test description",
                                           item_note: "test_note" }] } }
        }

        before do
          checkout_stubs(body: checkout_group_order_items_body, return: checkout_return_hash)

          group_order_find_stub(auth_token: { email: "admin", password: "welcome" }, return: return_data)

          visit merchant_path(id: merchant.merchant_id, group_order_token: "9109-nyw5d-g8225-irawz", order_type: order_type)
        end

        context "add items to cart" do
          before do
            allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)

            first("article").click
            first("button.add.cash").click
          end

          it_behaves_like "group order add items"

          context "#GO Error" do
            before do
              checkout_stubs(body: checkout_group_order_items_body,
                             error: { error: "GO error", error_type: "group_order" })

              checkout_stubs(body: checkout_group_order_items_body.merge!(group_order_token: nil),
                             return: checkout_return_hash)

              find(".my-order-link").click
              first("button.submit-order").click
            end

            it "should render dialog and reset event" do
              within "#group-order-error" do
                expect(page).to have_content("Sorry, this group order has already been submitted. If you want to continue, your order will be placed individually.")
                expect(page).to have_css("button.reset", text: "Cancel")
                expect(page).to have_css("button", text: "Continue")

                find("button.reset").click
              end

              expect(URI.parse(current_url).request_uri).to eq(root_path)
            end

            it "should bind continue event" do
              expect(URI.parse(current_url).request_uri).to eq(new_checkout_path(merchant_id: merchant.merchant_id,
                                                                                 reset_dialog: "1",
                                                                                 order_type: order_type))

              within "#group-order-error" do
                expect(page).to have_content("Sorry, this group order has already been submitted. If you want to continue, your order will be placed individually.")
                expect(page).to have_css("button.reset", text: "Cancel")
                expect(page).to have_css("button", text: "Continue")

                all("button").first.click
              end

              expect(page).to_not have_css("#group-order-error")
            end
          end

          context "checkout" do
            before do
              find(".my-order-link").click
              first('button.submit-order').click
            end

            it_behaves_like "group order checkout page #title pickup"

            it_behaves_like "group order checkout page #checkout summary"

            it_behaves_like "group order checkout page #checkout summary 'promo code' you pay"

            it_behaves_like "group order checkout page #checkout detail 'notes'"

            it_behaves_like "group order checkout page #checkout detail you pay"

            it "last order page " do
              find_button("Submit to Group Order").click
              expect(URI.parse(current_url).request_uri).to eq("/last_order")
            end
          end
        end
      end

      context "#delivery" do
        let(:order_type) { "delivery" }

        let(:return_data) {
          { delivery_address: { business_name: "Sherman Company",
                                address1: "350 Sherman Ave",
                                address2: "",
                                city: "Coeur d'Ham",
                                state: "ID",
                                zip: "83814" },
            merchant_menu_type: order_type,
            order_summary: { cart_items: [{ order_detail_id: 1,
                                            item_name: "test",
                                            item_price: "10.00",
                                            item_description: "test description",
                                            item_note: "test_note" }] }
          }
        }

        before do
          order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                            body: { cart_ucid: "9705-j069h-ce8w3-425di",
                                    user_id: user_data["user_id"],
                                    requested_time: nil,
                                    delivery_time: nil
                            },
                            return: { tip_amt: 0,
                                      order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                      item_price: "6.89",
                                                                      item_quantity: "1",
                                                                      item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                      order_detail_id: "6082053",
                                                                      note: "" }],
                                                       receipt_items: [{ title: "Subtotal",
                                                                         amount: "$6.89" },
                                                                       { title: "Tax",
                                                                         amount: "$0.41" },
                                                                       { title: "Total",
                                                                         amount: "$7.30" }] } })
          checkout_stubs(body: checkout_group_order_items_body.merge(submitted_order_type: order_type),
                         return: checkout_return_hash)

          merchant_find_stub(auth_token: user_data["splickit_authentication_token"],
                             delivery: true,
                             return: merchant.as_json(root: false),
                             merchant_id: merchant.merchant_id)

          group_order_find_stub(auth_token: { email: "admin", password: "welcome" }, return: return_data)

          visit merchant_path(id: merchant.merchant_id, group_order_token: "9109-nyw5d-g8225-irawz", order_type: order_type)
        end


        context "add items to cart" do
          before do
            allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)

            first("article").click
            first("button.add.cash").click
          end

          it_behaves_like "group order add items"

          context "checkout" do
            before do
              find(".my-order-link").click
              first('button.submit-order').click
            end

            it_behaves_like "group order checkout page #title delivery"

            it_behaves_like "group order checkout page #checkout summary"

            it_behaves_like "group order checkout page #checkout summary 'promo code' you pay"

            it_behaves_like "group order checkout page #checkout detail 'notes'"

            it_behaves_like "group order checkout page #checkout detail you pay"

            it "last order page " do
              find_button("Submit to Group Order").click
              expect(URI.parse(current_url).request_uri).to eq("/last_order")
            end

            context "group order last order page" do
              before do
                user_find_stub(auth_token: "ASNDKASNDAS", return: user_data.merge("group_order_token" => "9109-nyw5d-g8225-irawz"))
                find_button("Submit to Group Order").click
              end

              it_behaves_like "group order last order page common content"

              it_behaves_like "group order last order pay not submit"
            end
          end
        end
      end
    end

    context "--> invitees pay" do
      let(:checkout_return_hash) do
        { lead_times_array: [1415823683],
          grand_total: "7.30",
          accepted_payment_types: [{ merchant_payment_type_map_id: "1000",
                                     name: "Credit Card",
                                     splickit_accepted_payment_type_id: "2000",
                                     billing_entity_id: nil }],
          order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                          item_price: "6.89",
                                          item_quantity: "1",
                                          item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                          order_detail_id: "6082053",
                                          note: "" }],
                           order_data_as_ids_for_cart_update: { merchant_id: merchant.merchant_id,
                                                                user_id: "4777193",
                                                                items: [{ item_id: "931",
                                                                          size_id: "1",
                                                                          quantity: "1",
                                                                          order_detail_id: "6082053",
                                                                          external_detail_id: 92391731240,
                                                                          status: "saved",
                                                                          mods: [{ modifier_item_id: "2",
                                                                                   mod_quantity: "1" }] }] },
                           receipt_items: [{ title: "Subtotal",
                                             amount: "$6.89" },
                                           { title: "Tax",
                                             amount: "$0.41" },
                                           { title: "Tip",
                                             amount: "$0.00" },
                                           { title: "Total",
                                             amount: "$7.30" }] } }
      end

      before do
        order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                          body: { cart_ucid: "9705-j069h-ce8w3-425di",
                                  user_id: user_data["user_id"],
                                  requested_time: "1415823683",
                                  tip: "0.69",
                                  note: "Something with bacon, please.",
                                  delivery_time: "Wed 11-12 08:21 PM",
                                  merchant_payment_type_map_id: "1000" },
                          message: "Your order to Pita Pit will be ready for pickup at 10:00am",
                          return: { tip_amt: 0.69,
                                    requested_time_string: "10:00 AM",
                                    order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                    item_price: "6.89",
                                                                    item_quantity: "1",
                                                                    item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                    order_detail_id: "6082053",
                                                                    note: "" }],
                                                    receipt_items: [{ title: "Subtotal",
                                                                      amount: "$6.89"},
                                                                    { title: "Tax",
                                                                      amount: "$0.41"},
                                                                    { title: "Total",
                                                                      amount: "$7.99" }] } })

        order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                          body: { cart_ucid: "9705-j069h-ce8w3-425di",
                                  user_id: user_data["user_id"],
                                  requested_time: "1415823683",
                                  tip: "0.69",
                                  note: "Something with bacon, please.",
                                  merchant_payment_type_map_id: "1000" },
                          message: "Your order to Pita Pit will be ready for pickup at 10:00am",
                          return: { tip_amt: 0.69,
                                    requested_time_string: "10:00 AM",
                                    order_summary: { cart_items: [{ item_name: "Ham n' Eggs",
                                                                    item_price: "6.89",
                                                                    item_quantity: "1",
                                                                    item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                    order_detail_id: "6082053",
                                                                    note: "" }],
                                                     receipt_items: [{ title: "Subtotal",
                                                                       amount: "$6.89"},
                                                                     { title: "Tax",
                                                                       amount: "$0.41"},
                                                                     { title: "Total",
                                                                       amount: "$7.99" }] } })
      end

      context "#pickup" do
        let(:order_type) { "pickup" }

        let(:return_data) {
          { merchant_menu_type: order_type,
            group_order_type: "2",
            order_summary: { cart_items: [{ order_detail_id: 1,
                                            item_name: "test",
                                            item_price: "10.00",
                                            item_description: "test description",
                                            item_note: "test_note" }] } }
        }

        before do
          checkout_stubs(body: checkout_group_order_items_body, return: checkout_return_hash)

          merchant_find_stub(merchant_id: merchant.merchant_id,
                             auth_token: user_data["splickit_authentication_token"],
                             return: merchant.as_json(root: false))

          group_order_find_stub(auth_token: { email: "admin", password: "welcome" }, return: return_data)

          visit merchant_path(id: merchant.merchant_id, group_order_token: "9109-nyw5d-g8225-irawz", order_type: order_type)
        end

        context "add items to cart" do
          before do
            allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)

            first("article").click
            first("button.add.cash").click
          end

          it_behaves_like "group order add items"

          context "checkout" do
            before do
              find(".my-order-link").click
              first('button.submit-order').click
            end

            it_behaves_like "group order checkout page #title pickup"

            it_behaves_like "group order checkout page #checkout summary"

            it_behaves_like "group order checkout page #checkout summary 'promo code' invitees pay"

            it_behaves_like "group order checkout page #checkout detail 'notes'"

            it_behaves_like "group order checkout page #checkout detail invitees pay"

            it "last order page " do
              find("#tip #tip").find(:xpath, "option[3]").select_option
              fill_in("Order notes", with: "Something with bacon, please.")

              find_button("Submit to Group Order").click
              expect(URI.parse(current_url).request_uri).to eq("/last_order")
            end

            context "group order last order page" do
              before do
                user_find_stub(auth_token: "ASNDKASNDAS", return: user_data.merge("group_order_token" => nil))
                find("#tip #tip").find(:xpath, "option[3]").select_option
                fill_in("Order notes", with: "Something with bacon, please.")
                find_button("Submit to Group Order").click
              end

              it_behaves_like "group order last order page common content"

              it_behaves_like "group order last order pay not submit"

              it_behaves_like "group order last order invitee pay"
            end
          end
        end
      end

      context "#delivery" do
        let (:order_type) { "delivery" }

        let(:return_data) {
          { delivery_address: { business_name: "Sherman Company",
                                address1: "350 Sherman Ave",
                                address2: "",
                                city: "Coeur d'Ham",
                                state: "ID",
                                zip: "83814" },
            merchant_menu_type: "delivery",
            group_order_type: "2",
            total_submitted_orders: "1",
            order_summary: { cart_items: [{ order_detail_id: 1,
                                            item_name: "test",
                                            item_price: "10.00",
                                            item_description: "test description",
                                            item_note: "test_note" }] }
          }
        }

        before do
          checkout_stubs(body: checkout_group_order_items_body.merge(submitted_order_type: order_type),
                         return: checkout_return_hash)

          merchant_find_stub(auth_token: user_data["splickit_authentication_token"],
                             delivery: true,
                             return: merchant.as_json(root: false),
                             merchant_id: merchant.merchant_id)

          merchant_indeliveryarea_stub(auth_token: user_data["splickit_authentication_token"],
                                       merchant_id: merchant.merchant_id,
                                       delivery_address_id: (user_data["delivery_locations"]).first["user_addr_id"])

          group_order_find_stub(auth_token: { email: "admin", password: "welcome" }, return: return_data)

          visit merchant_path(id: merchant.merchant_id, group_order_token: "9109-nyw5d-g8225-irawz", order_type: order_type)
        end

        context "add items to cart" do
          before do
            allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731240)

            first("article").click
            first("button.add.cash").click
          end

          it_behaves_like "group order add items"

          context "checkout" do
            before do
              find(".my-order-link").click
              first('button.submit-order').click
            end

            it_behaves_like "group order checkout page #title delivery"

            it_behaves_like "group order checkout page #checkout summary"

            it_behaves_like "group order checkout page #checkout summary 'promo code' invitees pay"

            it_behaves_like "group order checkout page #checkout detail 'notes'"

            it_behaves_like "group order checkout page #checkout detail invitees pay"

            it "last order page " do
              find("#tip #tip").find(:xpath, "option[3]").select_option
              fill_in("Order notes", with: "Something with bacon, please.")

              find_button("Submit to Group Order").click
              expect(URI.parse(current_url).request_uri).to eq("/last_order")
            end

            context "group order last order page" do
              before do
                user_find_stub(auth_token: "ASNDKASNDAS", return: user_data.merge("group_order_token" => nil))
                find("#tip #tip").find(:xpath, "option[3]").select_option
                fill_in("Order notes", with: "Something with bacon, please.")
                find_button("Submit to Group Order").click
              end

              it_behaves_like "group order last order page common content"

              it_behaves_like "group order last order pay not submit"
            end
          end
        end
      end
    end
  end
end