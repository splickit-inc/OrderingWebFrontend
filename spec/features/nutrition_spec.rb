require "support/feature_spec_helper"

describe "Nutrition", js: true do
  let(:menu_data) { get_default_menu }
  let(:menu) { menu_data[:menu] }
  let(:modifier_item_1) { menu_data[:modifier_item_1] }

  let(:merchant) do
    menu[:menu_types].first.menu_items.first.calories = 10

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

  before do
    merchant_find_stub(merchant_id: merchant.merchant_id, return: merchant.as_json(root: false))

    visit merchant_path(merchant.merchant_id, order_type: "pickup")
  end

  context "Moes" do
    before do
      skin_where_stub(return: { skin_name: "Moes" })

      visit merchant_path(merchant.merchant_id, override_skin: "moes", order_type: "pickup")
    end

    it "Nutrition information should open a new tab and redirect" do
      first("article.item").click

      click_link("Nutrition Information")

      expect(page.driver.browser.window_handles.size).to eq(2)
      # Changed from https://www.moes.com/food/nutrition/burritos/ because of browser deprecation
      expect(page.driver.find_window("https://www.moes.com/nutrition")).not_to be_nil

      page.windows.last.close
    end

    context "Punchh" do
      before do
        user_authenticate_stub(punch_header: "test_token", return: { email: "test_email@mail.com" })
        merchant_find_stub(merchant_id: merchant.merchant_id, auth_token: "ASNDKASNDAS", return: merchant.as_json(root: false))

        page.driver.browser.manage.window.resize_to 500, 700
        visit merchant_path(merchant.merchant_id, override_skin: "moes", order_type: "pickup", security_token: "test_token")
      end

      after { reset_browser_window_size }

      it "Nutrition information should not be displayed" do
        first("article.item").click

        expect(page).not_to have_content("Nutrition Information")

        expect(page).not_to have_css("a.calories.nutrition-info")
      end
    end
  end
end