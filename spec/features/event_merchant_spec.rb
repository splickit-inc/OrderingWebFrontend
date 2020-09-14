require "support/feature_spec_helper"

describe "Event Merchant", js: true do
  let!(:user_data) { get_user_data }

  let(:menu_data) { get_default_menu }
  let(:menu) { menu_data[:menu] }
  let(:modifier_item_1) { menu_data[:modifier_item_1] }

  let(:map_url) { "http://com.splickit.products.s3.amazonaws.com/com.splickit.hollywoodbowl/merchant-location-images/large/HollywoodBowlMap.png" }

  before do
    allow_any_instance_of(OrdersController).to receive(:uuid).and_return(92391731239)

    skin_where_stub(return: { map_url: map_url,
                              event_merchant: "1" })

    merchant_find_stub(merchant_id: "100030",
                       auth_token: user_data["splickit_authentication_token"],
                       return: { merchant_id: "100030", menu: menu })

    visit merchants_path

    feature_sign_in(email: "mr@bean.com", password: "password", user_return: user_data)
  end

  describe "merchant#index page" do
    it "should render the correct map" do
      expect(page).to have_css("#map img[src='#{ map_url }']")
    end
  end

  context "confirmation page" do
    before do
      # MerchantsController#index
      first(".pickup.button").click

      # MerchantsController#show
      first("article").click
      first("button.add.cash").click

      checkout_stubs(body: { merchant_id: "100030",
                             items: [{ item_id: 931,
                                       quantity: 1,
                                       mods: [{ modifier_item_id: modifier_item_1.modifier_item_id,
                                                mod_quantity: 1,
                                                name: "Spicy Club Sauce" }],
                                       size_id: "3",
                                       order_detail_id: nil,
                                       external_detail_id: 92391731239,
                                       status: "new",
                                       points_used: nil,
                                       brand_points_id: nil,
                                       note: "" }] })

      first(".my-order-link").click
      click_button("Checkout")

      # CheckoutController#new
      find("#tip #tip").find(:xpath, "option[4]").select_option

      order_submit_stub(auth_token: user_data["splickit_authentication_token"],
                        body: { user_id: "2",
                                cart_ucid: "9705-j069h-ce8w3-425di",
                                tip: "1.03",
                                merchant_payment_type_map_id: "1000",
                                requested_time: "1415823383" })

      click_button("Place order")
    end

    it "should not display 'Get Directions' button" do
      expect(page).not_to have_content("Get Directions")
    end
  end
end