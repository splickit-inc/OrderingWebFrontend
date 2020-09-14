require 'support/feature_spec_helper'

describe 'nested modifiers', js: true do
  let(:modifier_item_1) do
    {"modifier_item_id" => "228135000",
     "modifier_item_name" => "Virgin",
     "modifier_item_max" => "0",
     "modifier_item_min" => "0",
     "modifier_item_pre_selected" => "no",
     "modifier_prices_by_item_size_id" => nil,
     "nested_items" => [{"modifier_item_id" => "2299351",
                         "modifier_item_name" => "No Flavor",
                         "modifier_item_max" => "1",
                         "modifier_item_min" => "0",
                         "modifier_item_pre_selected" => "yes",
                         "modifier_prices_by_item_size_id" => [{"modifier_price" => "0.00",
                                                                "size_id" => "1"}]},
                        {"modifier_item_id" => "2299352",
                         "modifier_item_name" => "SUPER HOT",
                         "modifier_item_max" => "1",
                         "modifier_item_min" => "0",
                         "modifier_item_pre_selected" => "no",
                         "modifier_prices_by_item_size_id" => [{"modifier_price" => "0.00",
                                                                "size_id" => "1"}]}]}
  end

  let(:modifier_group_1) do
    create_modifier_group("modifier_group_display_name" => "Spice Level",
                          "modifier_group_credit" => "0.00",
                          "modifier_group_credit_by_size" => [[
                                                                  "size_id": "1",
                                                                  "modifier_price": "1.00"
                                                              ],
                                                              [
                                                                  "size_id": "2",
                                                                  "modifier_price": "2.00"
                                                              ],
                                                              [
                                                                  "size_id": "3",
                                                                  "modifier_price": "3.00"
                                                              ]],
                          "modifier_group_max_price" => "999.00",
                          "modifier_group_max_modifier_count" => "1",
                          "modifier_group_min_modifier_count" => "1",
                          "modifier_items" => [modifier_item_1])
  end

  before do
    menu_item_1 = create_menu_item(item_id: 931, modifier_groups: [modifier_group_1], item_name: "Pastrami Salad",
                                   description: "A bed of fresh pastrami topped with cool ranch pastrami.")
    menu_type_1 = create_menu_type(menu_type_name: "Frozen Salads", menu_items: [menu_item_1])

    menu = Menu.new
    menu.menu_id = 3300
    menu.name = "Salads in Bowls"
    menu.menu_types = [menu_type_1]
    menu.menu_types.first.menu_items.first.size_prices[0]["price"] = "6.65"
    menu.menu_types.first.menu_items.first.size_prices.delete_at(2)
    menu.menu_types.first.menu_items.first.size_prices.delete_at(1)

    @merchant = Merchant.new("merchant_id" => "4000",
                             "menu_id" => "#{ menu.menu_id }",
                             "menu_key" => "1122334455",
                             "name" => "East Coast Wings",
                             "address1" => "1234 Wingit St.",
                             "city" => "Chicken",
                             "state" => "CO",
                             "phone_no" => "2224448899",
                             "brand" => "Spicy Wings",
                             "trans_fee_rate" => "5.00",
                             "show_tip" => "Y",
                             "time_zone_offset" => "-5")

    @merchant.menu = menu
    @merchant_json = {data: @merchant}.to_json

    # GET /merchants/:id
    merchant_find_stub(merchant_id: @merchant.merchant_id, return: @merchant.as_json(root: false))

    # visit merchant page #
    visit merchant_path(@merchant.merchant_id)
  end

  it "works correctly" do
    # open item #
    first('article').click

    # select nested modifier (item level) #
    click_button('Edit')

    # select nested modifier (nested level) #
    find("dd[data-id='2299352'] label").click

    # add nested modifier change #
    click_button('Done')

    # add item to cart #
    first('button.add').click

    # verify added correctly #
    first('.my-order-link').click

    expect(page).to have_content('Pastrami Salad')
    expect(page).to have_content('Small SUPER HOT')
  end

  describe "nested size prices" do
    before do
      modifier_item_1["nested_items"].each do |nested_item|
        nested_item["modifier_prices_by_item_size_id"] << {modifier_price: "2.00", size_id: "2"}
      end

      @merchant.menu.menu_types.first.menu_items.first.size_prices.concat([{size_name: "Large",
                                                                            size_id: "2",
                                                                            price: "7.95"},
                                                                           {size_name: "None",
                                                                            size_id: "3",
                                                                            price: "0.00"}])

      merchant_find_stub(merchant_id: @merchant.merchant_id,
                         return: {merchant_id: @merchant.merchant_id,
                                  menu_id: @merchant.menu.menu_id,
                                  menu: @merchant.menu})

      visit merchant_path(@merchant.merchant_id, order_type: "pickup")

      first("article").click
    end

    context "size with none nested price available" do
      before {page.find("label[for='None']").click}

      it "should disable the nested button" do
        virgin_dt = find("dt", text: "Virgin")
        virgin_dd = find("dd[data-id='#{ virgin_dt["data-id"] }']")

        expect(virgin_dt).to have_xpath("//dt[@class='disabled']")
        expect(virgin_dd).to have_xpath("//dd[@class='disabled']")
      end
    end

    context "size with some nested prices available" do
      before {page.find("label[for='Large']").click}

      it "should not disable the nested button" do
        virgin_dt = find("dt", text: "Virgin")
        virgin_dd = find("dd[data-id='#{ virgin_dt["data-id"] }']")

        expect(virgin_dt).not_to have_xpath("//dt[@class='disabled']")
        expect(virgin_dd).not_to have_xpath("//dd[@class='disabled']")
      end
    end

    context "item with different nested size prices" do
      before {page.find("label[for='Small']").click}

      it "should update nested prices label according to sizes" do
        click_button("Edit")

        no_flavor_dt = find("dt", text: "No Flavor")

        expect(no_flavor_dt).not_to have_content("2.00")

        click_button("Done")

        # Change size
        page.find("label[for='Large']").click

        click_button("Edit")

        expect(no_flavor_dt.find("span")).to have_content("2.00")

        click_button("Done")
      end
    end
  end

  context "with other non-nested modifiers" do
    let(:modifier_item_2) do
      {"modifier_item_id" => "1234567890",
       "modifier_item_name" => "Bone In",
       "modifier_item_max" => "9",
       "modifier_item_min" => "0",
       "modifier_item_pre_selected" => "no",
       "modifier_prices_by_item_size_id" => [{"modifier_price" => "0.00",
                                              "size_id" => "1"}],
       "nested_items" => nil
      }
    end

    let(:modifier_item_3) do
      {"modifier_item_id" => "1234567891",
       "modifier_item_name" => "Bone Out",
       "modifier_item_max" => "9",
       "modifier_item_min" => "0",
       "modifier_item_pre_selected" => "no",
       "modifier_prices_by_item_size_id" => [{"modifier_price" => "0.00",
                                              "size_id" => "1"}],
       "nested_items" => nil}
    end

    let(:modifier_group_2) do
      create_modifier_group("modifier_group_display_name" => "Bones",
                            "modifier_group_credit" => "0.00",
                            "modifier_group_credit_by_size" => [[
                                                                    "size_id": "1",
                                                                    "modifier_price": "1.00"
                                                                ],
                                                                [
                                                                    "size_id": "2",
                                                                    "modifier_price": "2.00"
                                                                ],
                                                                [
                                                                    "size_id": "3",
                                                                    "modifier_price": "3.00"
                                                                ]],
                            "modifier_group_max_price" => "999.00",
                            "modifier_group_max_modifier_count" => "15",
                            "modifier_group_min_modifier_count" => "15",
                            "modifier_items" => [modifier_item_2, modifier_item_3])
    end

    before do
      menu_item_1 = create_menu_item(item_id: 931,
                                     modifier_groups: [modifier_group_1, modifier_group_2],
                                     item_name: "Pastrami Salad",
                                     description: "A bed of fresh pastrami topped with cool ranch pastrami.")
      menu_type_1 = create_menu_type(menu_type_name: "Frozen Salads", menu_items: [menu_item_1])

      menu = Menu.new
      menu.menu_id = 3300
      menu.name = "Salads in Bowls"
      menu.menu_types = [menu_type_1]
      menu.menu_types.first.menu_items.first.size_prices[0]["price"] = "6.65"
      menu.menu_types.first.menu_items.first.size_prices.delete_at(2)
      menu.menu_types.first.menu_items.first.size_prices.delete_at(1)

      @merchant = Merchant.new("merchant_id" => "4000",
                               "menu_id" => "#{menu.menu_id}",
                               "menu_key" => "1122334455",
                               "name" => "East Coast Wings",
                               "address1" => "1234 Wingit St.",
                               "city" => "Chicken",
                               "state" => "CO",
                               "phone_no" => "2224448899",
                               "brand" => "Spicy Wings",
                               "trans_fee_rate" => "5.00",
                               "show_tip" => "Y",
                               "time_zone_offset" => "-5")

      @merchant.menu = menu
      @merchant_json = {data: @merchant}.to_json

      merchant_find_stub(merchant_id: @merchant.merchant_id, return: @merchant.as_json(root: false))

      # visit merchant page #
      visit merchant_path(@merchant.merchant_id)
    end

    it "only increments/decrements basic modifier items by 1 after editing modifier items" do
      # open item #
      first('article').click

      # Validate initial quantity of bone-in wings
      bone_in_dd = find("dd[data-id='1234567890']")
      expect(bone_in_dd).to_not have_selector 'span[data-quantity]'

      # select nested modifier (item level) #
      click_button('Edit')

      # select nested modifier (nested level) #
      find("dd[data-id='2299352'] label").click

      # add nested modifier change #
      click_button('Done')

      bone_in_dd.find('a.add').click
      expect(bone_in_dd.find 'span[data-quantity]').to have_content "1"

      bone_in_dd.find('a.subtract').click
      expect(bone_in_dd).to_not have_selector 'span[data-quantity]'
    end
  end

  context "with modifiers interedependents" do
    let(:modifier_group_interdependent1) do
      modifier_item_1["nested_items"].first["modifier_item_pre_selected"] = "no"
      create_modifier_group({modifier_group_credit: "0.99",
                             modifier_group_credit_by_size: [[
                                                                 "size_id": "1",
                                                                 "modifier_price": "1.00"
                                                             ],
                                                             [
                                                                 "size_id": "2",
                                                                 "modifier_price": "2.00"
                                                             ],
                                                             [
                                                                 "size_id": "3",
                                                                 "modifier_price": "3.00"
                                                             ]],
                             modifier_group_display_name: "Interdependent1",
                             modifier_group_min_modifier_count: "0",
                             modifier_group_max_modifier_count: "3",
                             modifier_group_type: "I2",
                             modifier_items: [modifier_item_1]})
    end

    let(:modifier_group_interdependent2) do
      modifier_item_1["nested_items"].first["modifier_item_pre_selected"] = "no"
      create_modifier_group({modifier_group_credit: "0.99",
                             modifier_group_credit_by_size: [[
                                                                 "size_id": "1",
                                                                 "modifier_price": "1.00"
                                                             ],
                                                             [
                                                                 "size_id": "2",
                                                                 "modifier_price": "2.00"
                                                             ],
                                                             [
                                                                 "size_id": "3",
                                                                 "modifier_price": "3.00"
                                                             ]],
                             modifier_group_display_name: "Interdependent2",
                             modifier_group_min_modifier_count: "0",
                             modifier_group_max_modifier_count: "3",
                             modifier_group_type: "I2",
                             modifier_items: [modifier_item_1]})
    end

    before do
      @merchant.menu.menu_types.first.menu_items.first.modifier_groups = [modifier_group_interdependent1,
                                                                          modifier_group_interdependent2]

      merchant_find_stub(merchant_id: @merchant.merchant_id,
                         return: {merchant_id: @merchant.merchant_id,
                                  menu_id: @merchant.menu.menu_id,
                                  menu: @merchant.menu})

      visit merchant_path(@merchant.merchant_id, order_type: "pickup")

      first("article").click
    end

    it "should display the alert when one interdependant is selected and other doesn't" do
      # Select 1 interdependent1
      interdependent1 = first(:xpath, "//h4[contains(text(),'Interdependent1')]/following-sibling::dl")
      virgin_dt = interdependent1.find("dt", text: "Virgin")
      virgin_dd = interdependent1.find("dd[data-id='#{ virgin_dt["data-id"] }']")
      virgin_dd.find("button").click

      virgin_modifier = first(:xpath, "//h1[contains(text(),'Virgin')]/following-sibling::dl")
      no_flavor_dt = virgin_modifier.find("dt", text: "No Flavor")
      no_flavor_dd = virgin_modifier.find("dd[data-id='#{ no_flavor_dt["data-id"] }']")
      no_flavor_dd.find("label").click

      click_button("Done")

      # Add Item
      first("button.add").click

      # Alert
      alert = page.driver.browser.switch_to.alert
      # This seems to be the only way to check the content of the popup window.
      alert.dismiss if alert.text == "Please select from Interdependent2"
    end

    it "shouldn't display alert when the two interdependent are selected" do
      # Select 1 interdependent1
      interdependent1 = first(:xpath, "//h4[contains(text(),'Interdependent1')]/following-sibling::dl")
      virgin_dt = interdependent1.find("dt", text: "Virgin")
      virgin_dd = interdependent1.find("dd[data-id='#{ virgin_dt["data-id"] }']")
      virgin_dd.find("button").click

      virgin_modifier = first(:xpath, "//h1[contains(text(),'Virgin')]/following-sibling::dl")
      no_flavor_dt = virgin_modifier.find("dt", text: "No Flavor")
      no_flavor_dd = virgin_modifier.find("dd[data-id='#{ no_flavor_dt["data-id"] }']")
      no_flavor_dd.find("label").click

      click_button("Done")

      # Select 1 interdependent2
      interdependent2 = first(:xpath, "//h4[contains(text(),'Interdependent2')]/following-sibling::dl")
      virgin_dt = interdependent2.find("dt", text: "Virgin")
      virgin_dd = interdependent2.find("dd[data-id='#{ virgin_dt["data-id"] }']")
      virgin_dd.find("button").click

      virgin_modifier = first(:xpath, "//h1[contains(text(),'Virgin')]/following-sibling::dl")
      no_flavor_dt = virgin_modifier.find("dt", text: "No Flavor")
      no_flavor_dd = virgin_modifier.find("dd[data-id='#{ no_flavor_dt["data-id"] }']")
      no_flavor_dd.find("label").click

      click_button("Done")

      # Add Item
      first("button.add").click

      expect(page).to have_css("div#item-added-popup")
    end

    it "shouldn't display alert when no modifier interdependent is selected" do
      # Add Item
      first("button.add").click

      expect(page).to have_css("div#item-added-popup")
    end
  end
end
