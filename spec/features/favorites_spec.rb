require "support/feature_spec_helper"

describe "favorites", js: true do
  let(:menu_data) {get_default_menu}
  let(:menu) {menu_data[:menu]}
  let(:modifier_item_1) {menu_data[:modifier_item_1]}

  before do
    merchant_find_stub(return: {trans_fee_rate: "0.00",
                                menu: menu})
    visit merchant_path(id: 4000)
  end

  context "logged in, 2 Pastrami salad favorite added" do
    let(:order_summary) do
      {grand_total: "16.89",
       order_summary: {cart_items: [{item_name: "Pastrami Salad",
                                     item_price: "8.24",
                                     item_quantity: "1",
                                     item_description: "Spicy Club Sauce",
                                     order_detail_id: "6082053",
                                     note: ""},
                                    {item_name: "Pastrami Salad",
                                     item_price: "8.24",
                                     item_quantity: "1",
                                     item_description: "Spicy Club Sauce",
                                     order_detail_id: "6082053",
                                     note: ""}],
                       receipt_items: [{title: "Subtotal",
                                        amount: "$16.48"},
                                       {title: "Tax",
                                        amount: "$0.41"},
                                       {title: "Total",
                                        amount: "$16.89"}]}}
    end

    before do
      merchant_find_stub(auth_token: "ASNDKASNDAS",
                         trans_fee_rate: "0.00",
                         return: {menu: menu,
                                  user_favorites: [{favorite_id: "270237",
                                                    favorite_name: "breakfast ",
                                                    favorite_order: {note: "breakfast",
                                                                     items: [{quantity: "1",
                                                                              note: "",
                                                                              size_id: "1",
                                                                              item_id: "931",
                                                                              sizeprice_id: "1",
                                                                              mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                                                      mod_sizeprice_id: "1",
                                                                                      quantity: "1",
                                                                                      mod_quantity: "1"}]},
                                                                             {quantity: "1",
                                                                              note: "",
                                                                              size_id: "1",
                                                                              item_id: "931",
                                                                              sizeprice_id: "1",
                                                                              mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                                                      mod_sizeprice_id: "1",
                                                                                      quantity: "1",
                                                                                      mod_quantity: "1"}]}]}}]})

      feature_sign_in
      first("div#user-items-section h3").click
      first("div.order").click
    end

    it "should show favorites" do
      within("div.my-order") do
        expect(page).to have_content("Pastrami Salad", count: 2)
      end
    end

    it "should add favorites" do
      # Body requires 2 Pastrami Salads
      items = cart_session_items

      checkout_stubs(body: {items: [{item_id: 931,
                                     quantity: 1,
                                     mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                             name: "Spicy Club Sauce",
                                             mod_quantity: 1}],
                                     size_id: "1",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     order_detail_id: nil,
                                     external_detail_id: items.first["uuid"],
                                     status: "new",
                                     note: nil},
                                    {item_id: 931,
                                     quantity: 1,
                                     mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                             name: "Spicy Club Sauce",
                                             mod_quantity: 1}],
                                     size_id: "1",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     order_detail_id: nil,
                                     external_detail_id: items.last["uuid"],
                                     status: "new",
                                     note: nil}]},
                     return: order_summary)

      first("button.checkout").click

      expect(page).to have_content("Pastrami Salad", count: 2)
      find("#tip #tip").find(:xpath, "option[2]").select_option

      order_submit_stub(auth_token: "ASNDKASNDAS",
                        body: {user_id: "2",
                               cart_ucid: "9705-j069h-ce8w3-425di",
                               tip: "0",
                               note: "",
                               merchant_payment_type_map_id: "1000",
                               requested_time: "1415823383"},
                        return: order_summary.merge(tip_amt: "0"))

      find_button("Place order ($16.89)").click

      expect(page).to have_content("Pastrami Salad", count: 2)

      #Validations for favorite field with empty favorite's name
      find("#addFavorites").click

      expect(find('#error-message')).to have_content('Please name your favorite')
    end
  end
end

describe "Delete Favorite", js: true do
  let(:menu_data) {get_default_menu}
  let(:menu) {menu_data[:menu]}
  let(:modifier_item_1) {menu_data[:modifier_item_1]}

  before do
    merchant_find_stub(return: {trans_fee_rate: "0.00", menu: menu})
    merchant_find_stub(
        auth_token: "ASNDKASNDAS",
        trans_fee_rate: "0.00",
        return: {
            menu: menu,
            user_favorites: [
                {
                    favorite_id: "270237",
                    favorite_name: "breakfast ",
                    favorite_order: {
                        note: "breakfast",
                        items: [
                            {quantity: "1",
                             note: "",
                             size_id: "1",
                             item_id: "931",
                             sizeprice_id: "1",
                             mods: [
                                 {
                                     modifier_item_id: modifier_item_1.modifier_item_id,
                                     mod_sizeprice_id: "1",
                                     quantity: "1",
                                     mod_quantity: "1"
                                 }
                             ]
                            }, {
                                quantity: "1",
                                note: "",
                                size_id: "1",
                                item_id: "931",
                                sizeprice_id: "1",
                                mods: [
                                    {
                                        modifier_item_id: modifier_item_1.modifier_item_id,
                                        mod_sizeprice_id: "1",
                                        quantity: "1",
                                        mod_quantity: "1"
                                    }
                                ]
                            }
                        ]
                    }
                }
            ]
        }
    )
  end

  context "Delete favorite in Menu section" do
    before do
      visit merchant_path(id: 4000)
      feature_sign_in
    end

    it "should show the FAVORITES in Menu page" do
      expect(page).to have_content("FAVORITES")
      expect(page).to have_selector('.remove-favorite')
    end

    it "should delete favorite" do
      delete_favorite_stub(favorite_id: "270237")
      find('.remove-favorite').click
      expect(page).to have_content "Delete Favorite"
      first('button.modal-btn-remove-favorite-yes').click

      expect(page).to have_content('Your favorite was successfully deleted');
      expect(URI.parse(current_url).request_uri).to eq merchant_path(id: 4000)
    end
  end
end

describe "last orders into favorite section", js: true do
  let(:menu_data) {get_default_menu}
  let(:menu) {menu_data[:menu]}
  let(:modifier_item_1) {menu_data[:modifier_item_1]}

  before do
    merchant_find_stub(return: {trans_fee_rate: "0.00", menu: menu})
    merchant_find_stub(
        auth_token: "ASNDKASNDAS",
        trans_fee_rate: "0.00",
        return: {
            menu: menu,
            user_favorites: [
                {
                    favorite_id: "270237",
                    favorite_name: "breakfast ",
                    favorite_order: {
                        note: "breakfast",
                        items: [
                            {quantity: "1",
                             note: "",
                             size_id: "1",
                             item_id: "931",
                             sizeprice_id: "1",
                             mods: [
                                 {
                                     modifier_item_id: modifier_item_1.modifier_item_id,
                                     mod_sizeprice_id: "1",
                                     quantity: "1",
                                     mod_quantity: "1"
                                 }
                             ]
                            }, {
                                quantity: "1",
                                note: "",
                                size_id: "1",
                                item_id: "931",
                                sizeprice_id: "1",
                                mods: [
                                    {
                                        modifier_item_id: modifier_item_1.modifier_item_id,
                                        mod_sizeprice_id: "1",
                                        quantity: "1",
                                        mod_quantity: "1"
                                    }
                                ]
                            }
                        ]
                    }
                }
            ]
        }
    )
  end

  context "user is not logged" do
    before do
      visit merchant_path(id: 4000)
    end
    it "not favorite secction if user is not logged" do
      expect(page).to_not have_content("FAVORITES")
    end

  end

  context "user is logged without last orders" do
    it "should show favorites without last orders " do
      visit merchant_path(id: 4000)
      feature_sign_in

      expect(page).to have_content("FAVORITES")

      within("div#user-items-section") do
        expect(page).to_not have_selector(".user-lastorder")
      end
    end
  end

  context "user is logged with last orders" do
    let(:order_summary) do
      {grand_total: "8.24",
       order_summary: {cart_items: [{item_name: "Pastrami Salad",
                                     item_price: "8.24",
                                     item_quantity: "1",
                                     item_description: "Spicy Club Sauce",
                                     order_detail_id: "6082053",
                                     note: ""}],
                       receipt_items: [{title: "Subtotal",
                                        amount: "$16.48"},
                                       {title: "Tax",
                                        amount: "$0.41"},
                                       {title: "Total",
                                        amount: "$8.24"}]}}
    end

    before do |example|
      unless example.metadata[:skip_before]
        merchant_find_stub(auth_token: "ASNDKASNDAS",
                           trans_fee_rate: "0.00",
                           return: {menu: menu,
                                    user_favorites: [{favorite_id: "270237",
                                                      favorite_name: "breakfast ",
                                                      favorite_order: {note: "breakfast",
                                                                       items: [{quantity: "1",
                                                                                note: "",
                                                                                size_id: "1",
                                                                                item_id: "931",
                                                                                sizeprice_id: "1",
                                                                                mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                                                        mod_sizeprice_id: "1",
                                                                                        quantity: "1",
                                                                                        mod_quantity: "1"}]},
                                                                               {quantity: "1",
                                                                                note: "",
                                                                                size_id: "1",
                                                                                item_id: "931",
                                                                                sizeprice_id: "1",
                                                                                mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                                                        mod_sizeprice_id: "1",
                                                                                        quantity: "1",
                                                                                        mod_quantity: "1"}]}]}}],
                                    user_last_orders: [{order_id: "11650492",
                                                        label: "Last Order placed on 02-10-2016",
                                                        order: {note: "test",
                                                                items: [{quantity: "1",
                                                                         note: "",
                                                                         size_id: "1",
                                                                         item_id: "931",
                                                                         sizeprice_id: "1",
                                                                         mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                                                 mod_sizeprice_id: "1",
                                                                                 quantity: "1",
                                                                                 mod_quantity: "1"}]}]}}]})

        visit merchant_path(id: 4000)
        feature_sign_in
      end
    end

    it "should show favorites with last orders " do
      expect(page).to have_content("FAVORITES")
      within("div#user-items-section") do
        expect(page).to have_selector(".user-lastorder")
        expect(page).to have_content("Last order placed on 02-10-2016")
        expect(page).to_not have_selector(".user-lastorder.remove-lastorder") #not contain remove icon for last order
        expect(page).to_not have_selector(".user-favorite img")
        expect(page).to_not have_selector(".user-lastorder img")
      end
    end

    it "should show favorites and last orders with images", skip_before: true do
      merchant_find_stub(auth_token: "ASNDKASNDAS",
                         trans_fee_rate: "0.00",
                         return: {menu: menu,
                                  user_favorites: [{favorite_id: "270237",
                                                    favorite_name: "breakfast ",
                                                    favorite_order: {note: "breakfast",
                                                                     items: [{quantity: "1",
                                                                              note: "",
                                                                              size_id: "1",
                                                                              item_id: "931",
                                                                              sizeprice_id: "1",
                                                                              mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                                                      mod_sizeprice_id: "1",
                                                                                      quantity: "1",
                                                                                      mod_quantity: "1"}]},
                                                                             {quantity: "1",
                                                                              note: "",
                                                                              size_id: "1",
                                                                              item_id: "931",
                                                                              sizeprice_id: "1",
                                                                              mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                                                      mod_sizeprice_id: "1",
                                                                                      quantity: "1",
                                                                                      mod_quantity: "1"}]}]}}],
                                  user_last_orders: [{order_id: "11650492",
                                                      label: "Last Order placed on 02-10-2016",
                                                      order: {note: "test",
                                                              items: [{quantity: "1",
                                                                       note: "",
                                                                       size_id: "1",
                                                                       item_id: "931",
                                                                       sizeprice_id: "1",
                                                                       mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                                               mod_sizeprice_id: "1",
                                                                               quantity: "1",
                                                                               mod_quantity:
                                                                                   "1"}]}]}}],
                                  favorite_img_2x: "https://image.ibb.co/hRqXhv/favorite.png",
                                  favorite_img_small_2x: "https://image.ibb.co/bVMSFF/favorite_small.png",
                                  last_order_img_2x: "https://image.ibb.co/hQXTNv/last_order.png",
                                  last_order_img_small_2x: "https://image.ibb.co/iZ7Opa/last_order_small.png"})

      visit merchant_path(id: 4000)
      feature_sign_in
      expect(page).to have_content("FAVORITES")
      within("div#user-items-section") do
        expect(page).to have_selector(".user-lastorder")
        expect(page).to have_content("Last order placed on 02-10-2016")
        expect(page).to_not have_selector(".user-lastorder.remove-lastorder") #not contain remove icon for last order
        expect(page).to have_selector(".user-favorite img")
        expect(page).to have_selector(".user-lastorder img")
      end
    end

    it "should add last order to cart" do
      first("div#user-items-section .user-lastorder h3").click
      first("div.order").click

      items = cart_session_items

      # Body requires 2 Pastrami Salads
      checkout_stubs(body: {user_id: "2",
                            merchant_id: "4000",
                            user_addr_id: nil,
                            items: [{item_id: 931,
                                     quantity: 1,
                                     mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                             mod_quantity: 1,
                                             name: "Spicy Club Sauce"}],
                                     size_id: "1",
                                     order_detail_id: nil,
                                     external_detail_id: items.first["uuid"],
                                     status: "new",
                                     points_used: nil,
                                     brand_points_id: nil,
                                     note: nil}],
                            total_points_used: 0},
                     return: order_summary)

      first("button.checkout").click

      expect(page).to have_content("Pastrami Salad", count: 1)
      find("#tip #tip").find(:xpath, "option[2]").select_option

      order_submit_stub(auth_token: "ASNDKASNDAS",
                        body: {user_id: "2",
                               cart_ucid: "9705-j069h-ce8w3-425di",
                               tip: "0",
                               note: "",
                               merchant_payment_type_map_id: "1000",
                               requested_time: "1415823383"},
                        return: order_summary.merge(tip_amt: "0"))

      find_button("Place order ($8.24)").click

      expect(page).to have_content("Pastrami Salad", count: 1)
    end
  end
end

describe "last orders without favorite section", js: true do
  let(:menu_data) {get_default_menu}
  let(:menu) {menu_data[:menu]}
  let(:modifier_item_1) {menu_data[:modifier_item_1]}

  before do |example|
    unless example.metadata[:skip_before]
      merchant_find_stub(return: {trans_fee_rate: "0.00", menu: menu})
      merchant_find_stub(
          auth_token: "ASNDKASNDAS",
          trans_fee_rate: "0.00",
          return: {
              menu: menu,
              user_last_orders: [
                  {
                      order_id: "11650492",
                      label: "Last Order placed on 02-10-2016",
                      order: {
                          note: "test",
                          items: [
                              {
                                  quantity: "1",
                                  note: "",
                                  size_id: "1",
                                  item_id: "931",
                                  sizeprice_id: "1",
                                  mods: [
                                      {
                                          modifier_item_id: modifier_item_1.modifier_item_id,
                                          mod_sizeprice_id: "1",
                                          quantity: "1",
                                          mod_quantity: "1"
                                      }
                                  ]
                              }
                          ]
                      }
                  }
              ]
          }
      )
    end
  end

  context "user is not logged" do
    before do
      visit merchant_path(id: 4000)
    end

    it "not favorite and lastest order secction if user is not logged" do
      expect(page).to_not have_content("FAVORITES")
      expect(page).to_not have_content("LATEST ORDER")
    end
  end

  context "user is logged with last orders" do
    let(:order_summary) do
      {grand_total: "8.24",
       order_summary: {cart_items: [{item_name: "Pastrami Salad",
                                     item_price: "8.24",
                                     item_quantity: "1",
                                     item_description: "Spicy Club Sauce",
                                     order_detail_id: "6082053",
                                     note: ""}],
                       receipt_items: [{title: "Subtotal",
                                        amount: "$16.48"},
                                       {title: "Tax",
                                        amount: "$0.41"},
                                       {title: "Total",
                                        amount: "$8.24"}]}}
    end

    before do |example|
      unless example.metadata[:skip_before]
        visit merchant_path(id: 4000)
        feature_sign_in
      end
    end

    it "should show latest order section" do
      expect(page).to_not have_content("FAVORITES")
      expect(page).to have_content("LATEST ORDER")

      within("div#user-items-section") do
        expect(page).to have_selector(".user-lastorder")
        expect(page).to have_content("Last order placed on 02-10-2016")
        expect(page).to_not have_selector(".user-lastorder.remove-lastorder") #not contain remove icon for last order
        expect(page).to_not have_selector(".user-lastorder img")
      end

    end

    it "should add last order to cart" do
      first("div#user-items-section .user-lastorder h3").click
      first("div.order").click

      items = cart_session_items

      # Body requires 2 Pastrami Salads
      checkout_stubs(
          body: {
              user_id: "2",
              merchant_id: "4000",
              user_addr_id: nil,
              items: [
                  {
                      item_id: 931,
                      quantity: 1,
                      mods: [
                          {
                              modifier_item_id: modifier_item_1.modifier_item_id,
                              mod_quantity: 1,
                              name: "Spicy Club Sauce"
                          }
                      ],
                      size_id: "1",
                      order_detail_id: nil,
                      external_detail_id: items.first["uuid"],
                      status: "new",
                      points_used: nil,
                      brand_points_id: nil,
                      note: nil
                  }
              ],
              total_points_used: 0
          },
          return: order_summary
      )

      first("button.checkout").click

      expect(page).to have_content("Pastrami Salad", count: 1)
      find("#tip #tip").find(:xpath, "option[2]").select_option

      order_submit_stub(
          auth_token: "ASNDKASNDAS",
          body: {
              user_id: "2",
              cart_ucid: "9705-j069h-ce8w3-425di",
              tip: "0",
              note: "",
              merchant_payment_type_map_id: "1000",
              requested_time: "1415823383"
          },
          return: order_summary.merge(tip_amt: "0"))

      find_button("Place order ($8.24)").click

      expect(page).to have_content("Pastrami Salad", count: 1)
    end

    it "should add last order to cart by clicking image", skip_before: true do
      merchant_find_stub(return: {trans_fee_rate: "0.00", menu: menu})
      merchant_find_stub(
          auth_token: "ASNDKASNDAS",
          trans_fee_rate: "0.00",
          return: {
              menu: menu,
              user_last_orders: [
                  {
                      order_id: "11650492",
                      label: "Last Order placed on 02-10-2016",
                      order: {
                          note: "test",
                          items: [
                              {
                                  quantity: "1",
                                  note: "",
                                  size_id: "1",
                                  item_id: "931",
                                  sizeprice_id: "1",
                                  mods: [
                                      {
                                          modifier_item_id: modifier_item_1.modifier_item_id,
                                          mod_sizeprice_id: "1",
                                          quantity: "1",
                                          mod_quantity: "1"
                                      }
                                  ]
                              }
                          ]
                      }
                  }
              ],
              favorite_img_2x: "https://image.ibb.co/hRqXhv/favorite.png",
              favorite_img_small_2x: "https://image.ibb.co/bVMSFF/favorite_small.png",
              last_order_img_2x: "https://image.ibb.co/hQXTNv/last_order.png",
              last_order_img_small_2x: "https://image.ibb.co/iZ7Opa/last_order_small.png"

          }
      )
      visit merchant_path(id: 4000)
      feature_sign_in
      expect(page).to have_selector("div#user-items-section .user-lastorder img")
      first("div#user-items-section .user-lastorder img").click
      expect(page).to have_content("Item successfully added")
    end
  end
end