require "support/feature_spec_helper"

describe "merchant menu details page", js: true do
  let!(:sizes) {[{size_id: "1", modifier_price: "1.00"}, {size_id: "2", modifier_price: "2.00"},
                 {size_id: "3", modifier_price: "3.00"}]}

  let!(:modifier_item_1) {
    create_modifier_item({
                             "modifier_item_name" => "Spicy Club Sauce",
                             "modifier_prices_by_item_size_id" => sizes,
                             "modifier_item_pre_selected" => "yes"
                         })
  }

  let!(:modifier_item_2) {
    create_modifier_item({
                             "modifier_item_name" => "Vegetarian Club Sauce",
                             "modifier_prices_by_item_size_id" => sizes
                         })
  }

  let!(:modifier_item_3) {
    create_modifier_item({
                             "modifier_item_name" => "Lutefisk Club Sauce",
                             "modifier_prices_by_item_size_id" => sizes
                         })
  }

  let!(:modifier_item_4) {
    create_modifier_item({
                             "modifier_item_name" => "Shredded Cardboard",
                             "modifier_prices_by_item_size_id" => sizes,
                         })
  }

  let!(:modifier_item_5) {
    create_modifier_item({
                             "modifier_item_name" => "Metamucil",
                             "modifier_prices_by_item_size_id" => sizes
                         })
  }

  let!(:modifier_item_6) {
    create_modifier_item({
                             "modifier_item_name" => "Just A Pile Of Beans",
                             "modifier_prices_by_item_size_id" => sizes,
                             "modifier_item_pre_selected" => 'yes'
                         })
  }

  let!(:modifier_item_7) {
    create_modifier_item({
                             "modifier_item_name" => "Octopus Jerky",
                             "modifier_item_max" => 3,
                             "modifier_prices_by_item_size_id" => sizes,
                             "modifier_item_pre_selected" => "yes"
                         })
  }

  let!(:modifier_item_8) {
    create_modifier_item({
                             "modifier_item_name" => "Bushmeat",
                             "modifier_item_max" => 3,
                             "modifier_prices_by_item_size_id" => sizes
                         })
  }

  let!(:modifier_item_9) {
    create_modifier_item(
        "modifier_item_name" => "Drink=Blood Wine",
        "modifier_prices_by_item_size_id" => sizes
    )
  }
  let!(:modifier_item_10) {
    create_modifier_item(
        "modifier_item_name" => "Drink=Romulan Ale",
        "modifier_prices_by_item_size_id" => sizes
    )
  }
  let!(:modifier_item_11) {
    create_modifier_item(
        "modifier_item_name" => "Drink=Synthehol",
        "modifier_prices_by_item_size_id" => sizes
    )
  }
  let!(:modifier_item_12) {
    create_modifier_item({
                             "modifier_item_name" => "Kangaroo",
                             "modifier_item_max" => 3,
                             "modifier_prices_by_item_size_id" => [{
                                                                       "size_id" => "1", "modifier_price" => "3.00"
                                                                   }]
                         })
  }

  let!(:modifier_group_1) {
    create_modifier_group({
                              :modifier_group_credit => "0.99",
                              :modifier_group_credit_by_size => [[
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
                              :modifier_group_display_name => "Club Sauce",
                              :modifier_group_min_modifier_count => "1",
                              :modifier_group_max_modifier_count => "3",
                              :modifier_items => [
                                  modifier_item_1,
                                  modifier_item_2,
                                  modifier_item_3,
                                  modifier_item_12
                              ]
                          })
  }
  let!(:modifier_group_2) {
    create_modifier_group({
                              :modifier_group_credit => "1.01",
                              :modifier_group_credit_by_size => [[
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
                              :modifier_group_display_name => "Fiber Additives",
                              :modifier_items => [
                                  modifier_item_4,
                                  modifier_item_5,
                                  modifier_item_6
                              ]
                          })
  }
  let!(:modifier_group_3) {
    create_modifier_group({
                              :modifier_group_max_modifier_count => 4,
                              :modifier_group_credit => "0.51",
                              :modifier_group_credit_by_size => [[
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
                              :modifier_group_display_name => "Exotic Jerky Toppings",
                              :modifier_items => [
                                  modifier_item_7,
                                  modifier_item_8
                              ]
                          })
  }
  let!(:modifier_group_4) {
    {
        "modifier_group_display_name" => "Drinks",
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
        "modifier_group_max_price" => "2.00",
        "modifier_group_max_modifier_count" => "1",
        "modifier_group_min_modifier_count" => "0",
        "modifier_items" => [
            modifier_item_9,
            modifier_item_10,
            modifier_item_11
        ]
    }
  }

  let!(:size_prices) {
    [{
         item_size_id: "1",
         item_id: "932",
         size_id: "1",
         tax_group: "1",
         price: "8.00",
         active: "Y",
         priority: "100",
         points: "99"
     }]
  }

  let!(:menu_item_1) {
    create_menu_item({
                         "item_id" => 931,
                         "modifier_groups" => [modifier_group_1, modifier_group_2, modifier_group_3, modifier_group_4],
                         "item_name" => "Pastrami Salad",
                         "description" => "A bed of fresh pastrami topped with cool ranch pastrami."
                     })
  }
  let!(:menu_item_2) {
    create_menu_item({
                         "item_id" => 932,
                         "size_prices" => size_prices,
                         "modifier_groups" => [modifier_group_1, modifier_group_2, modifier_group_3],
                         "item_name" => "Wasabi Salad",
                         "description" => "A bed of fresh wasabi topped with cool ranch wasabi."
                     })
  }
  let!(:menu_item_3) {
    create_menu_item({
                         "item_id" => 932,
                         "size_prices" => size_prices,
                         "modifier_groups" => [modifier_group_1, modifier_group_2, modifier_group_3],
                         "item_name" => "Wasabi Salad",
                         "description" => "A bed of fresh wasabi topped with cool ranch wasabi."
                     })
  }

  let!(:menu_item_4) {create_menu_item({"item_id" => 933,
                                        "size_prices" => size_prices,
                                        "modifier_groups" => [modifier_group_1, modifier_group_2, modifier_group_3],
                                        "item_name" => "Upsell Item",
                                        "description" => "Upsell description"})}

  let!(:menu_item_5) {create_menu_item({"item_id" => 934,
                                        "size_prices" => size_prices,
                                        "modifier_groups" => [],
                                        "item_name" => "Upsell Item 2",
                                        "description" => "Upsell description 2"})}

  let!(:merchant) do
    menu_type_1 = create_menu_type({"menu_type_name" => "Frozen Salads",
                                    "menu_items" => [menu_item_1]})
    menu_type_2 = create_menu_type({"menu_type_name" => "Boiled Salads",
                                    "menu_items" => [menu_item_2]})
    menu_type_3 = create_menu_type({"menu_type_name" => "Roasted Salads",
                                    "menu_items" => []})
    menu_type_4 = create_menu_type({"menu_type_name" => "Deep Fried Salads",
                                    "menu_items" => []})
    menu_type_5 = create_menu_type({"menu_type_name" => "Smashed Salads",
                                    "menu_items" => []})

    menu = Menu.new
    menu.menu_id = 3300
    menu.name = "Salads in Bowls"
    menu.charge_modifiers_loyalty_purchase = "1"
    menu.menu_types = [menu_type_1, menu_type_2, menu_type_3, menu_type_4, menu_type_5]

    merchant = Merchant.new
    merchant.merchant_id = 4000
    merchant.name = "Bob's house of pancakes"
    merchant.address1 = "1111 First St"
    merchant.city = "Whoville"
    merchant.state = "CO"
    merchant.phone_no = "2224448899"
    merchant.menu = menu
    merchant.brand = "Bob's house of pancakes"
    merchant
  end

  before do
    allow_any_instance_of(OrdersController).to receive(:uuid).and_return(2391731239)

    # Stubs for non authenticated user
    merchant_find_stub(merchant_id: merchant.merchant_id,
                       return: merchant.as_json(root: false))

    visit merchant_path(merchant.merchant_id, order_type: "pickup")
  end

  it "should display message if exist" do
    merchant_find_stub(merchant_id: merchant.merchant_id,
                       return: merchant.as_json(root: false),
                       message: "System message !!!")

    visit merchant_path(merchant.merchant_id, order_type: "pickup")

    expect(page).to have_content "System message !!!"
  end

  it "should still display a menu if an item lacks modifiers" do
    menu = Menu.initialize("menu_id" => 3300,
                           "name" => "Salads in Bowls",
                           "menu_types" => [get_menu_type_data.merge(
                               {"menu_type_name" => "Frozen Salads",
                                "menu_items" => [get_menu_item_data.merge(
                                    {"modifier_groups" => [],
                                     "size_prices" => size_prices,
                                     "item_name" => "Pastrami&nbsp;Salad",
                                     "description" => "A bed of fresh pastrami topped with cool ranch pastrami."}
                                )]}),
                                            get_menu_type_data.merge(
                                                {"menu_type_name" => "Boiled Salads",
                                                 "menu_items" => [get_menu_item_data.merge(
                                                     {"modifier_groups" => [],
                                                      "size_prices" => size_prices,
                                                      "item_name" => "Wasabi&nbsp;Salad",
                                                      "description" => "A bed of fresh wasabi topped with cool ranch wasabi."}
                                                 )]})
                           ])

    merchant = Merchant.new
    merchant.merchant_id = 4000
    merchant.menu = menu

    merchant_find_stub(merchant_id: merchant.merchant_id,
                       return: merchant.as_json(root: false))

    visit merchant_path(merchant.merchant_id, order_type: "pickup")
    expect(all("article").size).to eq(2)
  end

  it "should display size options, and modifier groups in the order returned from the API" do

    expect(all("article").size).to eq(2)
    expect(first("article img")['src']).to eq("https://www.placehold.it/1x/640x420")
    first("article").click

    within '#add-to-order' do
      expect(page.find("#details img")['src']).to eq("https://www.placehold.it/2x/158x158")
      expect(page.find("#size")).to have_text("Size")
      expect(page.find("#size")).to have_text("Choose 1")
      sizes = page.all("#size dt")
      expect(sizes.size).to eq(3)
      expect(sizes[0]).to have_text("Large")
      expect(sizes[1]).to have_text("Medium")
      expect(sizes[2]).to have_text("Small")

      modifiers_section = find '#modifiers'
      modifier_groups = all("#modifiers dl")

      expect(modifier_groups.size).to eq(4)
      expect(modifiers_section.text).to have_text("Club Sauce")
      expect(modifiers_section.text).to have_text("Fiber Additives")
      expect(modifiers_section.text).to have_text("Exotic Jerky Toppings")

      expect(modifiers_section.text).to have_text("Choose up to 2 more")
      expect(modifiers_section.text).to have_text("Choose up to 1 more")

      modifier_items = all("#modifiers dt")
      expect(modifier_items.size).to eq(12)

      groups = all("#modifiers dl")
      descriptions = all("#modifiers p")

      club_sauces = groups[0].all("dt")
      expect(club_sauces.size).to eq(4)
      expect(club_sauces[0]).to have_content "Spicy Club Sauce"
      expect(club_sauces[1]).to have_content "Vegetarian Club Sauce"
      expect(club_sauces[2]).to have_content "Lutefisk Club Sauce"
      expect(club_sauces[3]).to have_content "Kangaroo"
      expect(descriptions[0]).to have_content "Choose up to 2 more"

      fiber_mods = groups[1].all("dt")
      expect(fiber_mods.size).to eq(3)
      expect(fiber_mods[0]).to have_content "Shredded Cardboard"
      expect(fiber_mods[1]).to have_content "Metamucil"
      expect(fiber_mods[2]).to have_content "Just A Pile Of Beans"

      jerky_mods = groups[2].all("dt")
      expect(jerky_mods.size).to eq(2)
      expect(jerky_mods[0]).to have_content "Octopus Jerky"
      expect(jerky_mods[1]).to have_content "Bushmeat"

      drink_modifiers = groups[3].all 'dt'
      expect(drink_modifiers.size).to eq(3)
      expect(drink_modifiers[0]).to have_content "Blood Wine"

      expect(page.find("dt[data-id='#{modifier_item_7.modifier_item_id}'] span")).to have_content("3.00")
      first(".add").click()
      expect(page.find("dt[data-id='#{modifier_item_7.modifier_item_id}'] span")).to have_content("3.00")
      first(".subtract").click()
      expect(page.find("dt[data-id='#{modifier_item_7.modifier_item_id}'] span")).to have_content("3.00")
    end
  end

  it "should not display size options if the item only has one size" do
    all('article')[1].click
    expect(page).not_to have_text("Size")
  end

  it "has the correct menu content" do
    expect(page).to_not have_content "LOYALTY"

    page.find(:xpath, "//article[@data-menu-item-id=\"#{ menu_item_1.item_id }\"]").click

    within("#add-to-order") do
      expect(page).to have_content "Drink, Blood Wine"
      expect(page).to have_content "Special requests"
      expect(page).to have_selector("input[placeholder='Extra ingredients may result in additional charges']")
      expect(page).to have_content "Add item & checkout"
    end
  end

  it "shows items and modifiers in the order dialog" do
    first('article').click
    page.find("label[for='Small']").click

    first('button.add').click
    find('.my-order-link').click

    expect(find('header div.order')['data-item-count']).to eq "1"

    within '#my-order' do
      expect(page).to have_content "Small"
      expect(page).not_to have_content "Medium"
      expect(page).not_to have_content "Large"
      expect(page).to have_content "Pastrami Salad"
      expect(page).to have_content "Just A Pile Of Beans"
      expect(page).to have_content "$8.74"

      within '[data-dialog-footer]' do
        expect(page).to have_content "Checkout - $8.74"
      end

      first('.remove-item').click
      expect(page).not_to have_content "Small"
      expect(page).not_to have_content "Medium"
      expect(page).not_to have_content "Large"
      expect(page).not_to have_content "Pastrami Salad"
      expect(page).not_to have_content "Just A Pile Of Beans"
      expect(page).not_to have_content "$8.74"
    end

    expect(find('header div.order')['data-item-count']).to eq "0"
  end

  it "should display merchant info" do
    expect(page).to have_content("1111 First St")
    expect(page).to have_content("Whoville")
    expect(page).to have_content("CO")
  end

  it "should not display a map in the 'our store' section" do
    expect(page).not_to have_css("#our-store")
  end

  it "sizes the dialog content correctly" do
    first('article').click
    dialog_height = page.evaluate_script "$('[data-dialog-element]:visible').outerHeight()"
    header_height = page.evaluate_script "$('[data-dialog-header]:visible').outerHeight()"
    footer_height = page.evaluate_script "$('[data-dialog-footer]:visible').outerHeight()"
    content_height = page.evaluate_script "$('[data-dialog-content]:visible').outerHeight()"

    expect(content_height).to eq dialog_height.to_i - header_height.to_i - footer_height.to_i + 1
  end

  it 'should display the correct price based off of size and modifiers' do
    first('article').click

    within ".add-to-order" do
      page.find("label[for='Small']").click

      view_hidden_elements do
        expect(find("input#Small")).to be_checked
        expect(find("input#Medium")).not_to be_checked
        expect(find("input#Large")).not_to be_checked
      end

      expect(find("button.add")).to have_content("Add item - $8.74")
      page.find("label[for='modifier_item_#{ modifier_item_1.modifier_item_id }']").click
      expect(find("button.add")).to have_content("Add item - $8.73")
      page.find("label[for='modifier_item_#{ modifier_item_1.modifier_item_id }']").click
      expect(find("button.add")).to have_content("Add item - $8.74")

      octopus_jerky_dt = find 'dt', text: "Octopus Jerky"
      octopus_jerky_dd = find "dd[data-id='#{ octopus_jerky_dt['data-id'] }']"
      bushmeat_dt = find 'dt', text: "Bushmeat"
      bushmeat_dd = find "dd[data-id='#{ bushmeat_dt['data-id'] }']"

      #octopus jerky - 1, bushmeat - 0
      expect(octopus_jerky_dd.find 'span[data-quantity]').to have_content "1"
      expect(bushmeat_dd).to have_no_selector("span[data-quantity]")

      expect(octopus_jerky_dt).not_to have_content "0.49"
      expect(bushmeat_dt).not_to have_content "0.49"
      expect(octopus_jerky_dt).to have_content "1.00"
      expect(bushmeat_dt).to have_content "1.00"

      octopus_jerky_dd.find('a.add').click #octopus jerky - 2, bushmeat - 0

      expect(octopus_jerky_dd).to have_css('.add.active')
      expect(octopus_jerky_dd).to have_css('.subtract.active')
      expect(find 'button.add').to have_content "Add item - $9.74"
      expect(octopus_jerky_dd.find 'span[data-quantity]').to have_content "2"
      expect(octopus_jerky_dt).to have_content "1"
      expect(bushmeat_dt).to have_content "1"

      octopus_jerky_dd.find('a.add').click #octopus jerky - 3, bushmeat - 0

      expect(find 'button.add').to have_content "Add item - $10.74"
      expect(octopus_jerky_dd.find 'span[data-quantity]').to have_content "3"
      expect(octopus_jerky_dt).to have_content "1"
      expect(bushmeat_dt).to have_content "1"

      octopus_jerky_dd.find('a.add').click #octopus jerky - 3, bushmeat - 0

      expect(find 'button.add').to have_content "Add item - $10.74"
      expect(octopus_jerky_dd.find 'span[data-quantity]').to have_content "3"
      expect(octopus_jerky_dt).to have_content "1"
      expect(bushmeat_dt).to have_content "1"

      octopus_jerky_dd.find('a.add').click # octopus jerky - 3, bushmeat - 0

      expect(find 'button.add').to have_content "Add item - $10.74"
      expect(octopus_jerky_dd.find 'span[data-quantity]').to have_content "3"
      expect(octopus_jerky_dt).to have_content "1"
      expect(bushmeat_dt).to have_content "1"

      bushmeat_dd.find('a.add').click # octopus jerky - 3, bushmeat - 1

      expect(find 'button.add').to have_content "Add item - $11.74"
      expect(bushmeat_dd.find 'span[data-quantity]').to have_content "1"
      expect(octopus_jerky_dt).to have_content "1"
      expect(bushmeat_dt).to have_content "1"

      bushmeat_dd.find('a.add').click # octopus jerky - 3, bushmeat - 1

      expect(find 'button.add').to have_content "Add item - $11.74"
      expect(bushmeat_dd.find 'span[data-quantity]').to have_content "1"
      expect(octopus_jerky_dt).to have_content "1"
      expect(bushmeat_dt).to have_content "1"
      expect(bushmeat_dd).to have_css('.add.active')
      expect(bushmeat_dd).to have_css('.subtract.active')

      bushmeat_dd.find('a.subtract').click # octopus jerky - 3, bushmeat - 0

      expect(bushmeat_dd).not_to have_css('.add.active')
      expect(bushmeat_dd).not_to have_css('.subtract.active')
      expect(find 'button.add').to have_content "Add item - $10.74"
      expect(bushmeat_dd).to_not have_selector 'span[data-quantity]'
      expect(octopus_jerky_dt).to have_content "1"
      expect(bushmeat_dt).to have_content "1"

      bushmeat_dd.find('a.subtract').click # octopus jerky - 3, bushmeat - 0
      expect(find 'button.add').to have_content "Add item - $10.74"
      expect(octopus_jerky_dd.find 'span[data-quantity]').to have_content "3"
      expect(find 'button.add').to have_content "Add item - $10.74"
      expect(bushmeat_dt).to_not have_selector 'span[data-quantity]'
      expect(octopus_jerky_dt).to have_content "1"
      expect(bushmeat_dt).to have_content "1"

      octopus_jerky_dd.find('a.subtract').click # octopus jerky - 2, bushmeat - 0
      expect(find 'button.add').to have_content "Add item - $9.74"
      expect(octopus_jerky_dd.find 'span[data-quantity]').to have_content "2"
      expect(octopus_jerky_dt).to have_content "1"
      expect(bushmeat_dt).to have_content "1"

      octopus_jerky_dd.find('a.subtract').click # octopus jerky - 1, bushmeat - 0
      expect(find 'button.add').to have_content "Add item - $8.74"
      expect(octopus_jerky_dd.find 'span[data-quantity]').to have_content "1"
      expect(octopus_jerky_dt).to have_content "1"
      expect(bushmeat_dt).to have_content "1"

      octopus_jerky_dd.find('a.subtract').click # octopus jerky - 0, bushmeat - 0
      expect(find 'button.add').to have_content "Add item - $8.25"
      expect(octopus_jerky_dd).to have_no_selector('span[data-quantity]')
      expect(bushmeat_dd).to have_no_selector('span[data-quantity]')

      expect(octopus_jerky_dt).to_not have_content "1.00"
      expect(bushmeat_dt).to_not have_content "1.00"
      expect(octopus_jerky_dt).to have_content "0.49"
      expect(bushmeat_dt).to have_content "0.49"
    end
  end

  it "expands the menu nav to full width above 40rem window width" do
    page.driver.browser.manage.window.resize_to 800, 700
    expect(page).to have_content "FROZEN SALADS "
    expect(page).to have_content "BOILED SALADS"
    reset_browser_window_size
  end

  it "pre-selects modifiers" do
    first('article').click

    view_hidden_elements do
      expect(page).to_not have_css "[name='Metamucil'][checked]"
      expect(page).to have_css "[name='Just A Pile Of Beans'][checked]"
    end
  end

  it "doesn't charge extra for pre-selected modifiers" do
    first('article').click
    modifier = find "dd[data-id='#{ modifier_item_6.modifier_item_id }']"
    checkbox = modifier.find("label")
    button = find "button.add"
    expect(button).to have_content "$16.73"
    checkbox.click
    expect(button).to have_content "$14.74"
    checkbox.click
    expect(button).to have_content "$16.73"
  end

  it "doesn't charge more than a modifier group's maximum price" do
    first('article').click
    first_modifier = find "[data-id='#{ modifier_item_9.modifier_item_id }'] label"
    second_modifier = find "[data-id='#{ modifier_item_10.modifier_item_id }'] label"
    third_modifier = find "[data-id='#{ modifier_item_11.modifier_item_id }'] label"
    button = find 'button.add'
    expect(button).to have_content "$16.73"
    first_modifier.click
    expect(button).to have_content "$18.73"
    second_modifier.click
    expect(button).to have_content "$18.73"
    third_modifier.click
    expect(button).to have_content "$18.73"
  end

  it 'should allow a user to increment and decrement modifiers' do
    first('article').click

    octopus_jerky = find('dt', :text => "Octopus Jerky")
    actions = find "dd[data-id='#{ octopus_jerky['data-id'] }']"
    expect(actions).to_not have_selector '.quantity'
    actions.find("a.add").click

    first('button.add').click

    find('.my-order-link').click

    within '#my-order' do
      expect(page).to have_content "Large"
      expect(page).to have_content "Pastrami Salad"
      expect(page).to have_content "Just A Pile Of Beans"
      expect(page).to have_content "Octopus Jerky"
      expect(page).to have_content "$19.73"
    end
  end

  it "hides the modifier quantity when it's zero" do
    first('article').click
    modifier = find 'dt', text: "Octopus Jerky"
    actions = find "dd[data-id='#{ modifier['data-id'] }']"
    expect(actions).to_not have_content "0"
  end

  it "displays the modifier quantity when it's not zero" do
    first('article').click
    modifier = find 'dt', text: "Octopus Jerky"
    actions = find "dd[data-id='#{ modifier['data-id'] }']"
    actions.find('a.add').click

    expect(actions).to have_content "2"
  end

  it "continues to show the site and menu navigation when scrolled down" do
    page.execute_script 'window.scrollTo(0, 500)'
    site_nav = find 'header nav.primary'
    menu_nav = find 'header nav.secondary'
    expect(site_nav).to be_visible
    expect(menu_nav).to be_visible
  end

  it "includes the merchant address in the page title" do
    expect(page.title).to eq "Test — Whoville, 1111 First St"
  end

  it "collapses the menu nav if it wraps to two lines" do
    find("nav.secondary", visible: false).set(true)
    page.driver.browser.manage.window.resize_to 400, 700
    within 'nav.secondary' do
      expect(page).to have_text "Frozen Salads"
      # boiled salads is visible to capybara but not the user which is why this is being tested differently
      boiled_salads_link = find('a', text: "Boiled Salads")
      expect(boiled_salads_link[:class]).not_to include 'current'
      expect(page).to_not have_text "Roasted Salads"
      expect(page).to_not have_text "Deep Fried Salads"
      expect(page).to_not have_text "Smashed Salads"
    end
    reset_browser_window_size
  end

  it "does not collapse the menu nav if it's a single line" do
    within 'nav.secondary' do
      expect(page).to have_text "Frozen Salads"
      expect(page).to have_text "Boiled Salads"
      expect(page).to have_text "Roasted Salads"
      expect(page).to have_text "Deep Fried Salads"
      expect(page).to have_text "Smashed Salads"
    end
  end

  it "allows a user to edit their item [on different pages]" do
    # may view empty My Order dialog
    find('.my-order-link').click
    expect(page).to have_content("No items yet.")
    page.find(:xpath, "//span[@data-dialog-close]").click

    # add item
    first("article").click

    expect(page).to have_text("100")
    page.find("#requests input").set "stir the mayoz!"
    expect(page).to have_text("85")
    page.find("#requests input").set "stir the mayo"
    expect(page).to have_text("87")

    first("button.add").click

    click_link("View order")
    find(".edit-item").click

    expect(page).to have_selector("#requests input[value='stir the mayo']")

    # change some things (merchants show page)
    expect(page).to have_text("87")
    page.find("#requests input").set "stir the mayo and mustard"
    page.find("label[for='Small']").click
    expect(page).to have_text("75")

    first("button.add").click

    # change some things (index page)
    visit root_path

    find(".my-order-link").click
    find(".edit-item").click

    find("[data-id='#{ modifier_item_5.modifier_item_id }'] label").click # remove metamucil
    find("[data-id='#{ modifier_item_6.modifier_item_id }'] label").click # remove beans
    find("dd[data-id='#{ modifier_item_7.modifier_item_id }'] a.add").click # add octo-jerky
    find("[data-id='#{ modifier_item_9.modifier_item_id }'] label").click # add drink

    first("button.add").click

    # inspect my order
    find(".my-order-link").click

    expect(page).to have_text("Small Spicy Club Sauce Metamucil Octopus Jerky (2x) Drink, Blood Wine Note: stir the mayo and mustard")

    click_link("Bob's house of pancakes")

    # inspect item dialog on merchant's page
    find(".my-order-link").click
    find(".edit-item").click

    view_hidden_elements do
      expect(find("input#Small")).to be_checked
      expect(find("input#Medium")).not_to be_checked
      expect(find("input#Large")).not_to be_checked

      expect(find("[id='modifier_item_#{ modifier_item_1.modifier_item_id }']")).to be_checked
      expect(find("[id='modifier_item_#{ modifier_item_2.modifier_item_id }']")).not_to be_checked
      expect(find("[id='modifier_item_#{ modifier_item_3.modifier_item_id }']")).not_to be_checked

      expect(find("[id='modifier_item_#{ modifier_item_4.modifier_item_id }']")).not_to be_checked
      expect(find("[id='modifier_item_#{ modifier_item_5.modifier_item_id }']")).to be_checked
      expect(find("[id='modifier_item_#{ modifier_item_6.modifier_item_id }']")).not_to be_checked
    end

    expect(page).to have_selector("#requests input[value='stir the mayo and mustard']")
  end

  it "displays the correct size price for premium modifiers" do
    first("article").click

    page.find("label[for='Small']").click
    expect(find("dt[data-id='#{ modifier_item_7.modifier_item_id }'] span")).to have_text("1.00")
    expect(find("button.add")).to have_content "$8.74"

    page.find("label[for='Medium']").click
    expect(find("dt[data-id='#{ modifier_item_7.modifier_item_id }'] span")).to have_text("2.00")
    expect(find("button.add")).to have_content "$12.73"

    page.find("label[for='Large']").click
    expect(find("dt[data-id='#{ modifier_item_7.modifier_item_id }'] span")).to have_text("3.00")
    expect(find("button.add")).to have_content "$16.73"
  end

  it "shows and hides the premium modifier size prices correctly" do
    first("article").click

    expect(page).to have_selector("dt[data-id='#{ modifier_item_4.modifier_item_id }'] span", visible: false)
    page.find("dd[data-id='#{ modifier_item_4.modifier_item_id }'] span").click
    expect(page).to have_selector("dt[data-id='#{ modifier_item_4.modifier_item_id }'] span", visible: true)
    page.find("dd[data-id='#{ modifier_item_4.modifier_item_id }'] span").click
    expect(page).to have_selector("dt[data-id='#{ modifier_item_4.modifier_item_id }'] span", visible: false)
  end

  it "ensure that exclusive modifiers are selected / unselected properly" do
    first("article").click

    view_hidden_elements do
      expect(page.find("dd[data-id='#{ modifier_item_9.modifier_item_id }'] input")).to_not be_checked
      expect(page.find("dd[data-id='#{ modifier_item_10.modifier_item_id }'] input")).to_not be_checked
      expect(page.find("dd[data-id='#{ modifier_item_11.modifier_item_id }'] input")).to_not be_checked
    end

    expect(page.find("button.add")).to have_content("$16.73")

    # choose first drink
    page.find("dd[data-id='#{ modifier_item_9.modifier_item_id }'] label").click

    view_hidden_elements do
      expect(page.find("dd[data-id='#{ modifier_item_9.modifier_item_id }'] input")).to be_checked
      expect(page.find("dd[data-id='#{ modifier_item_10.modifier_item_id }'] input")).to_not be_checked
      expect(page.find("dd[data-id='#{ modifier_item_11.modifier_item_id }'] input")).to_not be_checked
    end

    expect(page.find("button.add")).to have_content("$18.73")

    # choose second drink
    page.find("[data-id='#{ modifier_item_10.modifier_item_id }'] label").click

    view_hidden_elements do
      expect(page.find("[data-id='#{ modifier_item_9.modifier_item_id }'] input")).to_not be_checked
      expect(page.find("[data-id='#{ modifier_item_10.modifier_item_id }'] input")).to be_checked
      expect(page.find("[data-id='#{ modifier_item_11.modifier_item_id }'] input")).to_not be_checked
    end

    expect(page.find("button.add")).to have_content("$18.73")

    # choose second drink
    page.find("[data-id='#{ modifier_item_11.modifier_item_id }'] label").click

    view_hidden_elements do
      expect(page.find("[data-id='#{ modifier_item_9.modifier_item_id }'] input")).to_not be_checked
      expect(page.find("[data-id='#{ modifier_item_10.modifier_item_id }'] input")).to_not be_checked
      expect(page.find("[data-id='#{ modifier_item_11.modifier_item_id }'] input")).to be_checked
    end

    expect(page.find("button.add")).to have_content("$18.73")

    # nothing selected (all unselected)
    page.find("[data-id='#{ modifier_item_11.modifier_item_id }'] label").click

    view_hidden_elements do
      expect(page.find("[data-id='#{ modifier_item_9.modifier_item_id }'] input")).to_not be_checked
      expect(page.find("[data-id='#{ modifier_item_10.modifier_item_id }'] input")).to_not be_checked
      expect(page.find("[data-id='#{ modifier_item_11.modifier_item_id }'] input")).to_not be_checked
    end

    expect(page.find("button.add")).to have_content("$16.73")
  end

  it 'does not allow to add an item that is underselected' do
    first("article").click

    find("[data-id='#{ modifier_item_1.modifier_item_id }'] label span").click
    page.find("button.add").click

    alert = page.driver.browser.switch_to.alert
    # This seems to be the only way to check the content of the popup window.
    alert.dismiss if alert.text == "Please select from Club Sauce"

    page.find("button.checkout").click

    alert = page.driver.browser.switch_to.alert
    alert.dismiss if alert.text == "Please select from Club Sauce"

    expect(find("[data-id='#{ modifier_item_1.modifier_item_id }'] label span")).to_not be_nil
  end

  it "should reset item modifiers if you add the item" do
    first("article").click

    page.find("label[for='Small']").click

    2.times do |n|
      find("[data-id='#{ modifier_item_12.modifier_item_id }'] a.add").click
    end

    find("[data-id='#{ modifier_item_11.modifier_item_id }'] label span").click

    page.find("button.add").click

    first("article").click

    view_hidden_elements do
      expect(page).to have_css("[data-id='#{ modifier_item_12.modifier_item_id }'] span.modifier-quantity[data-quantity='0']")
      expect(find("[data-id='#{ modifier_item_9.modifier_item_id }'] input")[:checked]).to be_falsey
      expect(find("[data-id='#{ modifier_item_10.modifier_item_id }'] input")[:checked]).to be_falsey
      expect(find("[data-id='#{ modifier_item_11.modifier_item_id }'] input")[:checked]).to be_falsey
    end
  end

  it "should not reset item modifiers if you don't add the item" do
    first("article").click

    page.find("label[for='Small']").click

    2.times do |n|
      find("[data-id='#{ modifier_item_12.modifier_item_id }'] a.add").click
    end

    find("[data-id='#{ modifier_item_11.modifier_item_id }'] label span").click

    find(:xpath, "//span[@data-dialog-close]").click

    first("article").click

    expect(page).to have_css("[data-id='#{ modifier_item_12.modifier_item_id }'] span.modifier-quantity[data-quantity='2']")

    view_hidden_elements do
      expect(find("[data-id='#{ modifier_item_9.modifier_item_id }'] input")[:checked]).to be_falsey
      expect(find("[data-id='#{ modifier_item_10.modifier_item_id }'] input")[:checked]).to be_falsey
      expect(find("[data-id='#{ modifier_item_11.modifier_item_id }'] input")[:checked]).to be_truthy
    end
  end

  context "with modifier items which max above 9" do
    let(:modifier_group_1) do
      create_modifier_group(modifier_group_credit: "0.99",
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
                            modifier_group_min_modifier_count: "1",
                            modifier_group_max_modifier_count: "20",
                            modifier_items: [modifier_item_1])
    end

    let(:modifier_item_1) do
      create_modifier_item("modifier_item_name" => "Spicy Club Sauce",
                           "modifier_prices_by_item_size_id" => sizes,
                           "modifier_item_max" => 15,
                           "modifier_item_min" => 1,
                           "modifier_item_pre_selected" => "yes")
    end

    before do
      merchant.menu.menu_types.first.menu_items.first.modifier_groups = [modifier_group_1]

      merchant_find_stub(merchant_id: merchant.merchant_id,
                         return: {merchant_id: merchant.merchant_id,
                                  menu_id: merchant.menu.menu_id,
                                  menu: merchant.menu})

      visit merchant_path(merchant.merchant_id, order_type: "pickup")

      first("article").click
    end

    it "should render new spinner elem" do
      within "dd[data-id='#{ modifier_item_1.modifier_item_id }']" do
        expect(page).to have_css("a.ui-spinner-button", count: 2)
      end

      #should update add item text
      within "dd[data-id='#{ modifier_item_1.modifier_item_id }']" do
        find("a.ui-spinner-up").click
      end

      expect(find("button.add").text).to eq("Add item - $15.25")

      within "dd[data-id='#{ modifier_item_1.modifier_item_id }']" do
        find("a.ui-spinner-down").click
      end

      expect(find("button.add").text).to eq("Add item - $12.25")

      within "dd[data-id='#{ modifier_item_1.modifier_item_id }']" do
        fill_in "modifier_item_#{ modifier_item_1.modifier_item_id }", with: "2"
      end

      expect(find("button.add").text).to eq("Add item - $15.25")
    end
  end

  context "with modifiers interdependents" do
    let!(:modifier_group_interdependent1) {
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
                             modifier_items: [modifier_item_2,
                                              modifier_item_3,
                                              modifier_item_12]})
    }

    let!(:modifier_group_interdependent2) {
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
                             modifier_items: [modifier_item_2,
                                              modifier_item_3,
                                              modifier_item_12]})
    }

    before do
      merchant.menu.menu_types.first.menu_items.first.modifier_groups = [modifier_group_interdependent1,
                                                                         modifier_group_interdependent2]

      merchant_find_stub(merchant_id: merchant.merchant_id,
                         return: {merchant_id: merchant.merchant_id,
                                  menu_id: merchant.menu.menu_id,
                                  menu: merchant.menu})

      visit merchant_path(merchant.merchant_id, order_type: "pickup")

      first("article").click
    end

    it "should display the alert when one interdependant is selected and other doesn't" do
      # Select 1 interdependent1
      interdependent1 = first(:xpath, "//h4[contains(text(),'Interdependent1')]/following-sibling::dl")
      vegetarian_dt = interdependent1.find("dt", text: "Vegetarian Club Sauce")
      vegetarian_dd = interdependent1.find("dd[data-id='#{ vegetarian_dt["data-id"] }']")
      vegetarian_dd.find("label").click

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
      vegetarian_dt = interdependent1.find("dt", text: "Vegetarian Club Sauce")
      vegetarian_dd = interdependent1.find("dd[data-id='#{ vegetarian_dt["data-id"] }']")
      vegetarian_dd.find("label").click

      # Select 1 interdependent2
      interdependent2 = first(:xpath, "//h4[contains(text(),'Interdependent2')]/following-sibling::dl")
      vegetarian_dt = interdependent2.find("dt", text: "Vegetarian Club Sauce")
      vegetarian_dd = interdependent2.find("dd[data-id='#{ vegetarian_dt["data-id"] }']")
      vegetarian_dd.find("label").click

      # Add Item
      first("button.add").click

      expect(page).to have_css('div#item-added-popup')
    end

    it "shouldn't display alert when no modifier interdependent is selected" do
      # Add Item
      first("button.add").click

      expect(page).to have_css('div#item-added-popup')
    end
  end

  context "with quantity modifiers" do
    let(:quantity_modifier_group) {
      create_modifier_group({modifier_group_credit: "0.00",
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
                             modifier_group_display_name: "Quantity",
                             modifier_group_min_modifier_count: "1",
                             modifier_group_max_modifier_count: "3",
                             modifier_group_type: "Q",
                             modifier_items: [create_modifier_item({"modifier_item_name" => "Item",
                                                                    "modifier_item_max" => 3,
                                                                    "modifier_prices_by_item_size_id" => [{"size_id" => "1", "modifier_price" => "0.00"}]})]})
    }

    before do
      menu_item = merchant.menu.menu_types.first.menu_items.first
      menu_item.modifier_groups = [quantity_modifier_group]
      menu_item.size_prices = [{item_size_id: "1",
                                item_id: "932",
                                size_id: "1",
                                tax_group: "1",
                                price: "5.00",
                                active: "Y",
                                enabled: true,
                                priority: "100",
                                points: "99"}]

      merchant_find_stub(merchant_id: merchant.merchant_id,
                         return: {merchant_id: merchant.merchant_id,
                                  menu_id: merchant.menu.menu_id,
                                  menu: merchant.menu})

      visit merchant_path(merchant.merchant_id, order_type: "pickup")

      first("article").click
    end

    it "should update item's total when Quantity modifier is increased" do
      expect(find("button.add").text).to eq("Add item - $5.00")

      first("a.add").click # Quantity 1
      expect(find("button.add").text).to eq("Add item - $5.00")

      first("a.add").click # Quantity 2
      expect(find("button.add").text).to eq("Add item - $10.00")

      first("a.add").click # Quantity 3
      expect(find("button.add").text).to eq("Add item - $15.00")
    end
  end

  describe "user signed in" do
    let!(:cart_body) do
      {user_id: "2",
       merchant_id: "4000",
       user_addr_id: nil,
       items: [{item_id: 931,
                quantity: 1,
                mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                        mod_quantity: 1,
                        name: "Spicy Club Sauce"},
                       {modifier_item_id: modifier_item_6.modifier_item_id,
                        mod_quantity: 1,
                        name: "Just A Pile Of Beans"},
                       {modifier_item_id: modifier_item_7.modifier_item_id,
                        mod_quantity: 1,
                        name: "Octopus Jerky"}],
                size_id: "3",
                order_detail_id: nil,
                external_detail_id: 2391731239,
                status: "new",
                points_used: nil,
                brand_points_id: nil,
                note: "hank dank"}],
       total_points_used: 0}
    end

    let!(:checkout_return) do
      {time_zone_string: "America/Los_Angeles",
       time_zone_offset: -8,
       user_message: nil,
       lead_times_array: [1415823383, 1415823443, 1415823503, 1415823563, 1415823623,
                          1415823683, 1415823743, 1415823803, 1415823863, 1415823923,
                          1415823983, 1415824043, 1415824103, 1415824163, 1415824223,
                          1415824283, 1415824583, 1415824883, 1415825183, 1415825483,
                          1415825783, 1415826083, 1415826383, 1415826683, 1415826983,
                          1415827283, 1415827583, 1415827883, 1415828183, 1415828483,
                          1415828783, 1415829083, 1415829983, 1415830883, 1415831783,
                          1415832683, 1415833583, 1415834483, 1415835383, 1415836283,
                          1415837183],
       promo_amt: "0.00",
       order_amt: "6.89",
       tip_array: [],
       total_tax_amt: "0.41",
       convenience_fee: "0.00",
       user_info: {last_four: "1111"},
       grand_total: "7.30",
       accepted_payment_types: [{merchant_payment_type_map_id: "2000",
                                 name: "Cash",
                                 splickit_accepted_payment_type_id: "1000",
                                 billing_entity_id: nil},
                                {merchant_payment_type_map_id: "2000",
                                 name: "Credit Card",
                                 splickit_accepted_payment_type_id: "2000",
                                 billing_entity_id: nil},
                                {merchant_payment_type_map_id: "2000",
                                 name: "Loyalty Card",
                                 splickit_accepted_payment_type_id: "3000",
                                 billing_entity_id: nil}],
       order_summary: {cart_items: [{item_name: "Ham n' Eggs",
                                     item_price: "$6.89",
                                     item_quantity: "1",
                                     item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                     order_detail_id: "6082053",
                                     note: ""}],
                       order_data_as_ids_for_cart_update: {items: cart_body[:items]},
                       receipt_items: [{title: "Subtotal", amount: "$6.89"},
                                       {title: "Tax", amount: "$0.41"},
                                       {title: "Total", amount: "$7.30"}]},
       cart_ucid: "9705-j069h-ce8w3-425di"}
    end

    before do
      # Stubs for authenticated user
      merchant_find_stub(auth_token: "ASNDKASNDAS",
                         merchant_id: merchant.merchant_id,
                         return: merchant.as_json(root: false))

      checkout_stubs(body: cart_body, return: checkout_return)
    end

    context "loyalty user signed in" do
      before do
        feature_sign_in(user_return: get_loyal_user_data.merge("brand_loyalty" => {"loyalty_number" => "140105420000001793",
                                                                                   "pin" => "9189",
                                                                                   "points" => "5000",
                                                                                   "usd" => "25"}))
      end

      it "should allow a user to place an order from the my order dialog" do
        first('article').click

        page.find("#requests input").set("hank dank")

        first('button.add.cash').click
        find('.my-order-link').click

        expect(page).to have_content("Note: hank dank")

        find('button.checkout').click

        expect(URI.parse(current_url).request_uri).to eq(new_checkout_path(merchant_id: merchant.merchant_id,
                                                                           order_type: "pickup"))
        expect(page).to have_content("Place order")

        expect(first('.item-counter')).to_not have_content("0")

        within("#amounts #subtotal") do
          expect(page).to have_content("Subtotal")
          expect(page).to have_content("$6.89")
        end

        within("#amounts #tax") do
          expect(page).to have_content("Tax")
          expect(page).to have_content("$0.41")
        end

        expect(page).not_to have_content("Tip")

        within("#amounts #promo-discount") do
          expect(page).to have_content("Promo Discount")
        end

        expect(find('table#total')).to have_content("Total")
        expect(find('table#total')).to have_content("$7.30")

        expect(page).to have_content "8:16 PM 8:17 PM 8:18 PM"
        expect(page).not_to have_content "No Tip 10% 15%"

        view_hidden_elements do
          expect(page).to have_content "Payment information"
          # 9862 When the session is saved. 9861 When there is another call to Alice
          expect(page).to have_content("••••1111")
          expect(page).to have_css ".credit-card input[type=radio]"
          expect(page).to have_content "Loyalty"
          expect(page).to have_css ".loyalty input[type=radio]"
          expect(page).to have_content "Cash"
          expect(page).to have_css ".cash input[type=radio]"
        end
      end

      it "disables the add with items button" do
        page.find(:xpath, "//article[@data-menu-item-id=\"#{ menu_item_1.item_id }\"]").click

        expect(page).to have_css(".add.points.primary[disabled]")
      end

      it "enables the add with items button" do


        visit merchant_path(merchant.merchant_id, order_type: "pickup")

        page.find(:xpath, "//article[@data-menu-item-id=\"#{ menu_item_1.item_id }\"]").click

        expect(page).to have_css(".add.points.primary")
      end

      it "has the correct menu content" do

        expect(page).to have_content "5000 POINTS"

        # verify first item's contents #
        within(:xpath, "//article[@data-menu-item-id=\"#{ menu_item_1.item_id }\"]") do
          expect(page).to have_content "$10.24 or 88pts"
        end

        page.find(:xpath, "//article[@data-menu-item-id=\"#{ menu_item_1.item_id }\"]").click

        within("#add-to-order") do
          expect(page).to have_content "Drink, Blood Wine"
          expect(page).to have_content "Special requests"
          expect(page).to have_selector("input[placeholder='Extra ingredients may result in additional charges']")
          expect(page).to_not have_content "Add item & checkout"
          expect(page).to have_content "Item not redeemable"
        end

        page.find(:xpath, "//span[@data-dialog-close]").click

        # verify second modal contents #
        within(:xpath, "//article[@data-menu-item-id=\"#{ menu_item_2.item_id }\"]") do
          expect(page).to have_content "$8.00 or 99pts"
        end

        page.find(:xpath, "//article[@data-menu-item-id=\"#{ menu_item_2.item_id }\"]").click

        within("#add-to-order") do
          expect(page).to_not have_content "Add item & checkout"
          expect(page).to have_content "Add item - 99 pts + $0.50"
        end

        page.find(:xpath, "//span[@data-dialog-close]").click
      end
    end

    context "non loyalty user signed in" do
      before do
        feature_sign_in
      end

      it "should display message if exist" do
        merchant_find_stub(auth_token: "ASNDKASNDAS",
                           merchant_id: merchant.merchant_id,
                           return: merchant.as_json(root: false),
                           message: "System message !!!")

        visit merchant_path(merchant.merchant_id, order_type: "pickup")

        expect(page).to have_content "System message !!!"
      end

      it "should allow a user to place an order from the menu item dialog" do
        checkout_stubs(body: cart_body.merge(items: [{item_id: 931,
                                                      quantity: 1,
                                                      mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                              mod_quantity: 1,
                                                              name: "Spicy Club Sauce"},
                                                             {modifier_item_id: modifier_item_6.modifier_item_id,
                                                              mod_quantity: 1,
                                                              name: "Just A Pile Of Beans"},
                                                             {modifier_item_id: modifier_item_7.modifier_item_id,
                                                              mod_quantity: 1,
                                                              name: "Octopus Jerky"}],
                                                      size_id: "3",
                                                      order_detail_id: nil,
                                                      external_detail_id: 2391731239,
                                                      status: "new",
                                                      points_used: nil,
                                                      brand_points_id: nil,
                                                      note: ""}]),
                       return: checkout_return.merge(order_summary: {cart_items: [{item_name: "Ham n' Eggs",
                                                                                   item_price: "$6.89",
                                                                                   item_quantity: "1",
                                                                                   item_description: "Cheddar,Onions,Green Peppers,Eggs,Hashbrowns",
                                                                                   order_detail_id: "6082053",
                                                                                   note: ""}],
                                                                     receipt_items: [{title: "Subtotal",
                                                                                      amount: "$6.89"},
                                                                                     {title: "Tax",
                                                                                      amount: "$0.41"},
                                                                                     {title: "Total",
                                                                                      amount: "$7.30"}]}))

        first('article').click
        first('button.checkout').click

        sleep 1 # local session was acting sluggish - this let it "catch it's breath"

        expect(URI.parse(current_url).request_uri).to eq(new_checkout_path(merchant_id: merchant.merchant_id,
                                                                           order_type: "pickup"))

        expect(page).to have_content("Place order")
        expect(first('.item-counter')).to_not have_content("0")
      end

      it "should allow a user to place an order from the my order dialog" do
        first('article').click

        page.find("#requests input").set("hank dank")

        first('button.add.cash').click
        find('.my-order-link').click

        expect(page).to have_content("Note: hank dank")

        find('button.checkout').click

        expect(URI.parse(current_url).request_uri).to eq(new_checkout_path(merchant_id: merchant.merchant_id,
                                                                           order_type: "pickup"))
        expect(page).to have_content("Place order")

        expect(first('.item-counter')).to_not have_content("0")

        within("#amounts #subtotal") do
          expect(page).to have_content("Subtotal")
          expect(page).to have_content("$6.89")
        end

        within("#amounts #tax") do
          expect(page).to have_content("Tax")
          expect(page).to have_content("$0.41")
        end

        expect(page).not_to have_content("Tip")

        within("#amounts #promo-discount") do
          expect(page).to have_content("Promo Discount")
        end

        expect(find('table#total')).to have_content("Total")
        expect(find('table#total')).to have_content("$7.30")

        expect(page).to have_content "8:16 PM 8:17 PM 8:18 PM"
        expect(page).not_to have_content "No Tip 10% 15%"

        view_hidden_elements do
          expect(page).to have_content "Payment information"
          expect(page).to have_content("••••1111")
          expect(page).to have_css ".credit-card input[type=radio]"
          expect(page).to have_content "Cash"
          expect(page).to have_css ".cash input[type=radio]"
        end
      end

      it "has the correct menu content" do
        expect(page).to have_content "LOYALTY"

        # verify first item's contents #
        within(:xpath, "//article[@data-menu-item-id=\"#{menu_item_1.item_id}\"]") do
          expect(page).to have_content "$10.24 or 88pts"
        end

        page.find(:xpath, "//article[@data-menu-item-id=\"#{menu_item_1.item_id}\"]").click

        within("#add-to-order") do
          expect(page).to have_content "Drink, Blood Wine"
          expect(page).to have_content "Special requests"
          expect(page).to have_selector("input[placeholder='Extra ingredients may result in additional charges']")
          expect(page).to have_content "Add item & checkout"
          expect(page).to_not have_content "Add item - 88 points"
        end

        page.find(:xpath, "//span[@data-dialog-close]").click

        # verify second modal contents #
        within(:xpath, "//article[@data-menu-item-id=\"#{menu_item_2.item_id}\"]") do
          expect(page).to have_content "$8.00 or 99pts"
        end

        page.find(:xpath, "//article[@data-menu-item-id=\"#{menu_item_2.item_id}\"]").click

        within("#add-to-order") do
          expect(page).to have_content "Add item & checkout"
          expect(page).to_not have_content "Add item - 99 points"
        end
      end

      it "disables modifiers on size change for check and radio buttons" do
        merchant.menu.menu_items.first.modifier_groups.first.modifier_items.last.modifier_item_max = 1

        merchant_find_stub(merchant_id: merchant.merchant_id,
                           return: {merchant_id: merchant.merchant_id,
                                    menu_id: merchant.menu.menu_id,
                                    menu: merchant.menu})

        merchant_find_stub(auth_token: "ASNDKASNDAS",
                           merchant_id: merchant.merchant_id,
                           return: {merchant_id: merchant.merchant_id,
                                    menu_id: merchant.menu.menu_id,
                                    menu: merchant.menu})

        visit merchant_path(merchant.merchant_id, order_type: "pickup")

        first("article").click

        kangaroo_dt = find("dt", text: "Kangaroo")
        kangaroo_dd = find("dd[data-id='#{ kangaroo_dt["data-id"] }']")

        # small size / kangaroo enabled
        page.find("label[for='Small']").click
        expect(kangaroo_dt).not_to have_xpath("//dt[@class='disabled']")
        kangaroo_dd.find("label").click

        # medium size / kangaroo disabled
        page.find("label[for='Medium']").click

        expect(kangaroo_dt).to have_xpath("//dt[@class='disabled']")
        expect(kangaroo_dd.find("input", visible: false)).not_to be_checked

        # large size / kangaroo disabled
        page.find("label[for='Large']").click
        expect(kangaroo_dt).to have_xpath("//dt[@class='disabled']")
        expect(kangaroo_dd.find("input", visible: false)).not_to be_checked

        spicy_dt = find("dt", text: "Spicy Club Sauce")
        spicy_dd = find("dd[data-id='#{ spicy_dt["data-id"] }']")
        spicy_dd.find("label").click
        page.find("label[for='Medium']").click

        first("button.checkout").click

        alert = page.driver.browser.switch_to.alert
        # This seems to be the only way to check the content of the popup window.
        alert.dismiss if alert.text == "Please select from Club Sauce"

        # It should not send Kangaroo item if it is not selected
        checkout_stubs(body: {user_id: "2",
                              merchant_id: "4000",
                              user_addr_id: nil,
                              items: [{item_id: 931,
                                       quantity: 1,
                                       mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                               mod_quantity: 1,
                                               name: "Spicy Club Sauce"},
                                              {modifier_item_id: modifier_item_6.modifier_item_id,
                                               mod_quantity: 1,
                                               name: "Just A Pile Of Beans"},
                                              {modifier_item_id: modifier_item_7.modifier_item_id,
                                               mod_quantity: 1,
                                               name: "Octopus Jerky"}],
                                       size_id: "2",
                                       order_detail_id: nil,
                                       external_detail_id: 2391731239,
                                       status: "new",
                                       points_used: nil,
                                       brand_points_id: nil,
                                       note: ""}],
                              total_points_used: 0})

        checkout_stubs(cart_id: "9705-j069h-ce8w3-425di")

        spicy_dd.find("label").click
        first("button.checkout").click

        expect(page).to have_content("Place order")
      end

      it "disables modifiers on size change for +- buttons" do
        first("article").click

        kangaroo_dt = find("dt", text: "Kangaroo")
        kangaroo_dd = find("dd[data-id='#{ kangaroo_dt["data-id"] }']")

        # small size / kangaroo enabled
        page.find("label[for='Small']").click
        expect(kangaroo_dt).not_to have_xpath("//dt[@class='disabled']")

        # medium size / kangaroo disabled
        page.find("label[for='Medium']").click

        expect(kangaroo_dt).to have_xpath("//dt[@class='disabled']")
        expect(kangaroo_dd).not_to have_css("a.active")
        expect(kangaroo_dd).not_to have_css("span")

        # large size / kangaroo disabled
        page.find("label[for='Large']").click
        expect(kangaroo_dt).to have_xpath("//dt[@class='disabled']")
        expect(kangaroo_dd).not_to have_css("a.active")
        expect(kangaroo_dd).not_to have_css("span")

        # Enable kangaroo again
        page.find("label[for='Small']").click
        spicy_dt = find("dt", text: "Spicy Club Sauce")
        spicy_dd = find("dd[data-id='#{ spicy_dt["data-id"] }']")
        spicy_dd.find("label").click
        page.find("label[for='Medium']").click

        first("button.checkout").click

        alert = page.driver.browser.switch_to.alert
        # This seems to be the only way to check the content of the popup window.
        alert.dismiss if alert.text == "Please select from Club Sauce"

        # It should not send Kangaroo item if it is not selected
        checkout_stubs(body: {user_id: "2",
                              merchant_id: "4000",
                              user_addr_id: nil,
                              items: [{item_id: 931,
                                       quantity: 1,
                                       mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                               mod_quantity: 1,
                                               name: "Spicy Club Sauce"},
                                              {modifier_item_id: modifier_item_6.modifier_item_id,
                                               mod_quantity: 1,
                                               name: "Just A Pile Of Beans"},
                                              {modifier_item_id: modifier_item_7.modifier_item_id,
                                               mod_quantity: 1,
                                               name: "Octopus Jerky"}],
                                       size_id: "2",
                                       order_detail_id: nil,
                                       external_detail_id: 2391731239,
                                       status: "new",
                                       points_used: nil,
                                       brand_points_id: nil,
                                       note: ""}],
                              total_points_used: 0})

        checkout_stubs(cart_id: "9705-j069h-ce8w3-425di")

        spicy_dd.find("label").click
        first("button.checkout").click

        expect(page).to have_content("Place order")
      end

      context "with negative amount modifiers" do
        let(:modifier_group_1) do
          create_modifier_group(modifier_group_credit: "0.99",
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
                                modifier_group_display_name: "Negative Amount",
                                modifier_group_min_modifier_count: "1",
                                modifier_group_max_modifier_count: "20",
                                modifier_items: [modifier_item_1])
        end

        let(:modifier_item_1) do
          create_modifier_item("modifier_item_name" => "Spicy Club Sauce",
                               "modifier_prices_by_item_size_id" => [{size_id: "3", modifier_price: "-1.00"}],
                               "modifier_item_max" => 1,
                               "modifier_item_min" => 0,
                               "modifier_item_pre_selected" => "no")
        end

        before do
          merchant.menu.menu_types.first.menu_items.first.modifier_groups = [modifier_group_1]

          merchant_find_stub(merchant_id: merchant.merchant_id,
                             return: {merchant_id: merchant.merchant_id,
                                      menu_id: merchant.menu.menu_id,
                                      menu: merchant.menu})

          visit merchant_path(merchant.merchant_id, order_type: "pickup")

          first("article").click
        end

        it "should display negative price amount" do
          within "dt[data-id='#{ modifier_item_1.modifier_item_id }']" do
            expect(page).to have_css("span.decrease", text: "-1.00")
          end
        end

        it "should update total price" do
          find("label[for='modifier_item_#{ modifier_item_1.modifier_item_id }']").click
          expect(find("button.add.cash").text).to include("$13.72")
        end

        xit "should work on checkout page" do
          ## Waiting button flow
          find("label[for='modifier_item_#{ modifier_item_1.modifier_item_id }']").click

          cart_body[:items].first[:note] = ""
          cart_body[:items].first[:external_detail_id] = 2391731239

          checkout_return[:order_summary][:order_data_as_ids_for_cart_update] = {items: [{external_detail_id: 2391731239,
                                                                                          order_detail_id: "6082053",
                                                                                          status: "saved"}]}

          checkout_stubs(body: cart_body, return: checkout_return)

          find("button.checkout").click

          # Edit item
          # Checkout Page
          first("div.edit-item").click

          within "dt[data-id='#{ modifier_item_1.modifier_item_id }']" do
            expect(page).to have_css("span.decrease", text: "-1.00")
          end

          find("label[for='modifier_item_#{ modifier_item_1.modifier_item_id }']").click
          expect(find("button.add.cash").text).to include("$14.72")

          find("label[for='modifier_item_#{ modifier_item_1.modifier_item_id }']").click
          expect(find("button.add.cash").text).to include("$13.72")
        end
      end

      context "with upsell items" do
        before do
          menu_type_1 = create_menu_type({"menu_type_name" => "Frozen Salads",
                                          "menu_items" => [menu_item_1, menu_item_4, menu_item_5]})
          menu_type_1.upsell_item_ids = [933, 934]
          menu_type_1.menu_items.each {|m_i| m_i.menu_type_id = menu_type_1.menu_type_id}
          merchant.menu.menu_types = [menu_type_1]
          merchant.menu.upsell_item_ids = [933, 934]
          merchant.menu.upsell_items = merchant.menu.get_upsell_items
          merchant.menu.menu_type_upsells = merchant.menu.get_menu_type_upsell_items

          merchant_find_stub(auth_token: "ASNDKASNDAS",
                             merchant_id: merchant.merchant_id,
                             return: {merchant_id: merchant.merchant_id,
                                      menu_id: merchant.menu.menu_id,
                                      menu: merchant.menu})

          visit merchant_path(merchant.merchant_id, order_type: "pickup")
        end
        #region NEW UPSELLS MODAL
        context "New Upsells Modal" do
          context "Adding item" do
            before do
              first("article").click
              first("button.add.cash").click
            end

            it 'should be closed on "No Thanks" option' do
              first("button.no-thanks").click
              expect(page).not_to have_css("div#upsells-info div#upsells-content")
              # no redirection should occur
              expect(URI.parse(current_url).request_uri).not_to include("/checkouts/new?merchant_id=4000")
            end

            context "Upsell Items with modifiers" do
              before do
                first("button.add-item").click
              end

              it "should open item modal" do
                within("div#add-to-order") do
                  expect(page).to have_content("Upsell Item")
                  expect(page).to have_content("Add item - $8.50")
                end
              end

              it "should add upsell item to cart and close dialog" do
                # Add upsell item
                first("button.add.cash").click
                # Dialog is closed
                expect(page).to have_css("div#upsells-info div#upsells-content")
                #View my Order Modal again to review if item is there
                find(".my-order-link").click
                within("section#items-section") do
                  expect(page.all("article div.details h5").last.text).to eq("Upsell Item")
                  expect(page.all("article span.price").last.text).to eq("$8.50")
                end
              end

              it "should add upsell item and redirect to checkout" do
                # Add upsell item
                first("button.checkout").click
                # Dialog is closed
                expect(page).to have_css("div#upsells-info div#upsells-content")
                first("button.no-thanks").click
                # Redirected to checkout
                expect(URI.parse(current_url).request_uri).to include("/checkouts/new?merchant_id=4000")
              end
            end

            context "Upsell Items without modifiers" do
              before do
                all("button.add-item").last.click
              end
              it "should not open item modal" do
                expect(page).not_to have_css("div#add-to-order")
              end

              it "should add upsell item to cart and close modal" do
                # Dialog is closed
                expect(page).not_to have_css("div#upsells-info div#upsells-content")
                #view my Order Modal again to review if item is there
                find(".my-order-link").click
                within("section#items-section") do
                  expect(page.all("article div.details h5").last.text).to eq("Upsell Item 2")
                  expect(page.all("article span.price").last.text).to eq("$8.00")
                end
              end
            end

          end

          context "Adding and checkout item" do
            before do
              first("article").click
              first("button.checkout").click
            end
            it 'should be closed and redirect to checkout "No Thanks" option' do
              first("button.no-thanks").click
              expect(URI.parse(current_url).request_uri).to include("/checkouts/new?merchant_id=4000")
            end

            context "Upsell Items with modifiers" do
              before do
                first("button.add-item").click
              end

              it "should open item modal" do
                within("div#add-to-order") do
                  expect(page).to have_content("Upsell Item")
                  expect(page).to have_content("Add item - $8.50")
                end
              end

              it "should add upsell item to cart and close dialog, without redirecting" do
                # Add upsell item
                first("button.add.cash").click
                all("button.add-item").last.click
                # Not redirected
                expect(URI.parse(current_url).request_uri).not_to include("/checkouts/new?merchant_id=4000")
                # Dialog is closed
                expect(page).not_to have_css("div#upsells-info div#upsells-content")
                #View my Order Modal again to review if item is there
                find(".my-order-link").click
                within("section#items-section") do
                  expect(page.all("article div.details h5").last.text).to eq("Upsell Item 2")
                  expect(page.all("article span.price").last.text).to eq("$8.00")
                end
              end

              it "should add upsell item and redirect to checkout" do
                # Add upsell item
                first("button.checkout").click
                all("button.no-thanks").last.click
                # Redirected to checkout
                expect(URI.parse(current_url).request_uri).to include("/checkouts/new?merchant_id=4000")
              end
            end

            context "Upsell Items without modifiers" do
              before do
                all("button.add-item").last.click
              end
              it "should not open item modal" do
                expect(page).not_to have_css("div#add-to-order")
              end

              it "should add upsell item and redirect to checkout" do
                # Redirected to checkout
                expect(URI.parse(current_url).request_uri).to include("/checkouts/new?merchant_id=4000")
              end
            end
          end
        end

        #endregion NEW UPSELLS MODAL

        it "shouldn't show upsell section when there isn't any item in cart" do
          find(".my-order-link").click
          expect(page).not_to have_css("div.my-order section#upsell-items-section")
        end

        it "should show upsell section in My Order modal when there are items in cart" do
          first("article").click
          first("button.add.cash").click
          first("button.no-thanks").click
          find(".my-order-link").click
          within("section#upsell-items-section") do
            expect(page.all("article").count).to eq(2)
            expect(page.first("article div.details h3").text).to eq("Add Upsell Item")
            expect(page.first("article span.price").text).to eq("$8.50")
            expect(page.first("article")).to have_css("button.add-item")

            expect(page.all("article div.details h3").last.text).to eq("Add Upsell Item 2")
            expect(page.all("article span.price").last.text).to eq("$8.00")
            expect(page.all("article").last).to have_css("button.add-item")
          end
        end

        it "should display only the upsell items that aren't in the cart" do
          first("article").click
          first("button.add.cash").click
          first("button.no-thanks").click
          find(".my-order-link").click

          # Add Upsell item
          first("button.add-item").click
          first("button.add.cash").click

          # Verify if Upsell item 2 is in the upsell section
          find(".my-order-link").click
          within("section#upsell-items-section") do
            expect(page.all("article").count).to eq(1)
            expect(page.first("article div.details h3").text).to eq("Add Upsell Item 2")
            expect(page.first("article span.price").text).to eq("$8.00")
            expect(page.first("article")).to have_css("button.add-item")
          end
        end

        it "shouldn't have upsell section if all upsell items are in cart" do
          first("article").click
          first("button.add.cash").click
          first("button.no-thanks").click
          find(".my-order-link").click

          # Add Upsell item
          first("button.add-item").click
          first("button.add.cash").click

          # Add Upsell item 2
          find(".my-order-link").click
          all("button.add-item").last.click

          # Upsell Item and upsell item 2 are in cart, there is not any other item in upsell item
          expect(page).not_to have_css("section#upsell-items-section")
        end

        it "should have send upsell items to Alice" do
          first("article").click
          first("button.add.cash").click
          first("button.no-thanks").click
          find(".my-order-link").click

          # Add Upsell item
          first("button.add-item").click
          first("button.add.cash").click

          items = cart_session_items

          # Checkout
          # Upsell Item (id: 933) should be in the cart
          checkout_stubs(body: {user_id: "2",
                                merchant_id: "4000",
                                user_addr_id: nil,
                                items: [{item_id: 931,
                                         quantity: 1,
                                         mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                 mod_quantity: 1,
                                                 name: "Spicy Club Sauce"},
                                                {modifier_item_id: modifier_item_6.modifier_item_id,
                                                 mod_quantity: 1,
                                                 name: "Just A Pile Of Beans"},
                                                {modifier_item_id: modifier_item_7.modifier_item_id,
                                                 mod_quantity: 1,
                                                 name: "Octopus Jerky"}],
                                         size_id: "3",
                                         order_detail_id: nil,
                                         external_detail_id: items.first["uuid"],
                                         status: "new",
                                         points_used: nil,
                                         brand_points_id: nil,
                                         note: ""},
                                        {item_id: 933,
                                         quantity: 1,
                                         mods: [{modifier_item_id: modifier_item_1.modifier_item_id,
                                                 mod_quantity: 1,
                                                 name: "Spicy Club Sauce"},
                                                {modifier_item_id: modifier_item_6.modifier_item_id,
                                                 mod_quantity: 1,
                                                 name: "Just A Pile Of Beans"},
                                                {modifier_item_id: modifier_item_7.modifier_item_id,
                                                 mod_quantity: 1,
                                                 name: "Octopus Jerky"}],
                                         size_id: "1",
                                         order_detail_id: nil,
                                         external_detail_id: items.last["uuid"],
                                         status: "new",
                                         points_used: nil,
                                         brand_points_id: nil,
                                         note: ""}],
                                total_points_used: 0})

          find(".my-order-link").click
          first("button.checkout").click

          expect(page).to have_content("Place order")
        end

        context "Upsell Items with modifiers" do
          before do
            first("article").click
            first("button.add.cash").click
            first("button.no-thanks").click
            find(".my-order-link").click
            first("button.add-item").click
          end

          it "should open item modal" do
            within("div#add-to-order") do
              expect(page).to have_content("Upsell Item")
              expect(page).to have_content("Add item - $8.50")
            end
          end

          it "should add upsell item to cart" do
            # Add item
            first("button.add.cash").click

            #View my Order Modal again to review if item is there
            find(".my-order-link").click
            within("section#items-section") do
              expect(page.all("article div.details h5").last.text).to eq("Upsell Item")
              expect(page.all("article span.price").last.text).to eq("$8.50")
            end
          end
        end

        context "Upsell Items without modifiers" do
          before do
            first("article").click
            first("button.add.cash").click
            first("button.no-thanks").click
            find(".my-order-link").click
            all("button.add-item").last.click
          end

          it "should not open item modal" do
            expect(page).not_to have_css("div#add-to-order")
          end

          it "should add upsell item to cart" do
            #The modal shouldn't close
            within("section#items-section") do
              expect(page.all("article div.details h5").last.text).to eq("Upsell Item 2")
              expect(page.all("article span.price").last.text).to eq("$8.00")
            end
          end
        end
      end
    end
  end
end