require "rails_helper"

describe UserFavorite do
  describe "#new" do
    subject { UserFavorite.new }

    it { is_expected.to respond_to(:favorite_id) }
    it { is_expected.to respond_to(:favorite_name) }
    it { is_expected.to respond_to(:items) }
    it { is_expected.to respond_to(:order_id) }
    it { is_expected.to respond_to(:order_note) }

    describe ".valid" do
      context "favorite item size does not exist in menu item" do
        let(:bad_favorites) do
          UserFavorite.new(
            favorite_order.merge(
              "menu_items" => [MenuItem.initialize(merchant_menu_item.merge(
                                                     "size_prices" => [{ "item_size_id" => "22222",
                                                                         "external_id" => nil,
                                                                         "item_id" => "286604",
                                                                         "size_id" => "70004",
                                                                         "tax_group" => "1",
                                                                         "price" => "4.89",
                                                                         "active" => "Y",
                                                                         "included_merchant_menu_types" => "All",
                                                                         "priority" => "50",
                                                                         "size_name" => "Junior",
                                                                         "enabled" => false },
                                                                       { "item_size_id" => "11111",
                                                                         "external_id" => nil,
                                                                         "item_id" => "286604",
                                                                         "size_id" => "70005",
                                                                         "tax_group" => "1",
                                                                         "price" => "5.89",
                                                                         "active" => "Y",
                                                                         "included_merchant_menu_types" => "All",
                                                                         "priority" => "50",
                                                                         "size_name" => "Regular",
                                                                         "enabled" => true }]
                                                   ))]

            )
          )
        end

        it "should default the first price to enabled" do
          expect(bad_favorites.items[0].size_prices[0]['enabled']).to be_truthy
        end
      end
    end


    describe ".favorite_id" do
      it { expect(UserFavorite.new("favorite_id" => "1").favorite_id).to eq(1) }
    end

    describe ".favorite_name" do
      it "assigns the correct favorite_name" do
        user_favorite = UserFavorite.new("favorite_name" => "Orange Crush")
        expect(user_favorite.favorite_name).to eq("Orange Crush")
      end
    end

    describe ".order_id" do
      it { expect(UserFavorite.new("order_id" => 5).order_id).to eq(5) }
    end

    describe ".items" do
      let(:items) do
        UserFavorite.new(favorite_order.merge("menu_items" => [MenuItem.initialize(merchant_menu_item)])).items
      end

      describe "item attributes" do
        it { expect(items[0]).to be_kind_of(MenuItem) }
        it { expect(items[0].note).to eq("Lots of love!") }
        it { expect(items[0].item_id).to eq(merchant_menu_item["item_id"]) }
        it { expect(items[0].item_name).to eq(merchant_menu_item["item_name"]) }
        it { expect(items[0].description).to eq(merchant_menu_item["description"]) }
        it { expect(items[0].size_prices).to eq([{ "item_size_id" => "1831026", "external_id" => nil, "item_id" => "286604",
                                                   "size_id" => "70004", "tax_group" => "1", "price" => "5.89", "active" => "Y",
                                                   "included_merchant_menu_types" => "All", "priority" => "50", "size_name" => "Regular",
                                                   "enabled" => false },
                                                 { "item_size_id" => "1831025", "external_id" => nil, "item_id" => "286604",
                                                   "size_id" => "70003", "tax_group" => "1", "price" => "4.89", "active" => "Y",
                                                   "included_merchant_menu_types" => "All", "priority" => "50", "size_name" => "Junior",
                                                   "enabled" => true }]) }
      end

      describe "modifier quantities" do
        # [Modifier Group #1] Tortilla
        it { expect(items[0].modifier_groups[0].modifier_items[0].quantity).to eq(1) }
        it { expect(items[0].modifier_groups[0].modifier_items[1].quantity).to eq(0) }

        # [Modifier Group #2] Beans
        it { expect(items[0].modifier_groups[1].modifier_items[0].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[1].modifier_items[1].quantity).to eq(1) }
        it { expect(items[0].modifier_groups[1].modifier_items[2].quantity).to eq(0) }

        # [Modifier Group #3] Fresh Free Ingredients
        it { expect(items[0].modifier_groups[2].modifier_items[0].quantity).to eq(1) }
        it { expect(items[0].modifier_groups[2].modifier_items[1].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[2].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[3].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[4].quantity).to eq(1) }
        it { expect(items[0].modifier_groups[2].modifier_items[5].quantity).to eq(1) }
        it { expect(items[0].modifier_groups[2].modifier_items[6].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[7].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[8].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[9].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[10].quantity).to eq(1) }
        it { expect(items[0].modifier_groups[2].modifier_items[11].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[12].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[13].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[14].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[15].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[16].quantity).to eq(1) }
        it { expect(items[0].modifier_groups[2].modifier_items[17].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[2].modifier_items[18].quantity).to eq(0) }

        # [Modifier Group #4] Guacamole
        it { expect(items[0].modifier_groups[4].modifier_items[0].quantity).to eq(1) }

        # [Modifier Group #5] Make It a Meal
        it { expect(items[0].modifier_groups[5].modifier_items[0].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[5].modifier_items[1].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[5].modifier_items[2].quantity).to eq(1) }
        it { expect(items[0].modifier_groups[5].modifier_items[3].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[5].modifier_items[4].quantity).to eq(0) }
        it { expect(items[0].modifier_groups[5].modifier_items[5].quantity).to eq(0) }

      end
    end

    describe ".order_note" do
      it "assigns the correct order note" do
        user_favorite = UserFavorite.new({"note" => "Extra mayo please."})
        expect(user_favorite.order_note).to eq("Extra mayo please.")
      end
    end
  end

  describe "#create" do
    let (:params) { {order_id: "1234", favorite_name: "bacon lover favorite"} }
    let (:credentials) { "AOSDAS97ASN201ASJ8" }

    context "success" do
      it "calls the API w/ the correct params" do
        expect(API).to receive("post").with("/favorites", params.to_json, credentials)
        UserFavorite.create(params, credentials)
      end
    end

    context "failure" do
      before do
        allow(API).to receive_message_chain(:post, :body) { {error: {error: "Something broke."}}.to_json }
        allow(API).to receive_message_chain(:post, :status) { 500 }
      end

      it "raises an APIError" do
        expect { UserFavorite.create(params, credentials) }.to raise_exception(APIError, "Something broke.")
      end
    end
  end

  describe "#destroy" do
    let (:credentials) { "AOSDAS97ASN201ASJ8" }

    context "success" do
      it "calls the API w/ the correct params" do
        expect(API).to receive("delete").with("/favorites/1234", credentials)
        UserFavorite.destroy("1234", credentials)
      end
    end

    context "failure" do
      before do
        allow(API).to receive_message_chain(:delete, :body) { {error: {error: "Something broke."}}.to_json }
        allow(API).to receive_message_chain(:delete, :status) { 500 }
      end

      it "raises an APIError" do
        expect { UserFavorite.destroy({"favorite_id" => "1234"}, credentials) }.to raise_exception(APIError, "Something broke.")
      end
    end
  end
end

def merchant_menu_item
  {
      "item_id" => "286604",
      "menu_type_id" => "46172",
      "tax_group" => "1",
      "item_name" => "Jr. Art Vandalay (9999 Calories)",
      "item_print_name" => "ART VANDALAY",
      "description" => "Our vegetarian burrito is served in a flour or whole grain tortilla with seasoned rice, beans, all-natural shredded cheese and pico de gallo along with lettuce, all-natural sour cream and handmade guacamole.",
      "active" => "Y",
      "priority" => "50",
      "size_prices" => [
          {
              "item_size_id" => "1831025",
              "external_id" => nil,
              "item_id" => "286604",
              "size_id" => "70003",
              "tax_group" => "1",
              "price" => "4.89",
              "active" => "Y",
              "included_merchant_menu_types" => "All",
              "priority" => "50",
              "size_name" => "Junior",
              "enabled" => false
          },
          {
            "item_size_id" => "1831026",
            "external_id" => nil,
            "item_id" => "286604",
            "size_id" => "70004",
            "tax_group" => "1",
            "price" => "5.89",
            "active" => "Y",
            "included_merchant_menu_types" => "All",
            "priority" => "50",
            "size_name" => "Regular",
            "enabled" => true
          }
      ],
      "modifier_groups" => [
          {
              "modifier_group_display_name" => "Tortilla",
              "modifier_group_credit" => "0.00",
              "modifier_group_max_price" => "88888.00",
              "modifier_group_max_modifier_count" => "1",
              "modifier_group_min_modifier_count" => "1",
              "modifier_group_display_priority" => "100",
              "modifier_items" => [
                  {
                      "modifier_item_name" => "Flour Tortilla",
                      "modifier_item_priority" => "1000",
                      "modifier_item_id" => "1602019",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => "0",
                      "modifier_item_pre_selected" => "yes",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Whole Grain Tortilla",
                      "modifier_item_priority" => "1000",
                      "modifier_item_id" => "1602021",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  }
              ]
          },
          {
              "modifier_group_display_name" => "Beans",
              "modifier_group_credit" => "0.00",
              "modifier_group_max_price" => "88888.00",
              "modifier_group_max_modifier_count" => "1",
              "modifier_group_min_modifier_count" => "1",
              "modifier_group_display_priority" => "90",
              "modifier_items" => [
                  {
                      "modifier_item_name" => "Black Beans",
                      "modifier_item_priority" => "800",
                      "modifier_item_id" => "1602037",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "yes",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Pinto Beans",
                      "modifier_item_priority" => "800",
                      "modifier_item_id" => "1602035",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "No Beans",
                      "modifier_item_priority" => "799",
                      "modifier_item_id" => "2305238",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  }
              ]
          },
          {
              "modifier_group_display_name" => "Fresh Free Ingredients",
              "modifier_group_credit" => "0.00",
              "modifier_group_max_price" => "88888.00",
              "modifier_group_max_modifier_count" => "20",
              "modifier_group_min_modifier_count" => "0",
              "modifier_group_display_priority" => "70",
              "modifier_items" => [
                  {
                      "modifier_item_name" => "Rice",
                      "modifier_item_priority" => "900",
                      "modifier_item_id" => "1602053",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => "0",
                      "modifier_item_pre_selected" => "yes",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Grilled Mushrooms",
                      "modifier_item_priority" => "500",
                      "modifier_item_id" => "1602185",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Grilled Onions",
                      "modifier_item_priority" => "500",
                      "modifier_item_id" => "1602183",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Grilled Peppers",
                      "modifier_item_priority" => "500",
                      "modifier_item_id" => "1602181",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Shredded Cheese",
                      "modifier_item_priority" => "200",
                      "modifier_item_id" => "1602055",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => "0",
                      "modifier_item_pre_selected" => "yes",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Pico de Gallo",
                      "modifier_item_priority" => "195",
                      "modifier_item_id" => "1602149",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => "0",
                      "modifier_item_pre_selected" => "yes",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Roasted Corn Salsa",
                      "modifier_item_priority" => "190",
                      "modifier_item_id" => "1602179",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Sour Cream",
                      "modifier_item_priority" => "185",
                      "modifier_item_id" => "1602157",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => "0",
                      "modifier_item_pre_selected" => "yes",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Lettuce",
                      "modifier_item_priority" => "180",
                      "modifier_item_id" => "1602039",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => "0",
                      "modifier_item_pre_selected" => "yes",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Tomatoes",
                      "modifier_item_priority" => "175",
                      "modifier_item_id" => "1602041",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Diced Onions",
                      "modifier_item_priority" => "170",
                      "modifier_item_id" => "1602045",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Cucumbers",
                      "modifier_item_priority" => "160",
                      "modifier_item_id" => "1602049",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Cilantro",
                      "modifier_item_priority" => "155",
                      "modifier_item_id" => "1602043",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Pickled Jalapenos",
                      "modifier_item_priority" => "150",
                      "modifier_item_id" => "1602051",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Black Olives",
                      "modifier_item_priority" => "145",
                      "modifier_item_id" => "1602047",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Fresh Jalapenos",
                      "modifier_item_priority" => "140",
                      "modifier_item_id" => "1602187",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Chipotle Ranch",
                      "modifier_item_priority" => "135",
                      "modifier_item_id" => "1602083",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Hard Rock & Roll Sauce",
                      "modifier_item_priority" => "130",
                      "modifier_item_id" => "1602057",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Southwest Vinaigrette",
                      "modifier_item_priority" => "125",
                      "modifier_item_id" => "1602191",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "0.00"
                          }
                      ]
                  }
              ]
          },
          {
              "modifier_group_display_name" => "Add-Ons",
              "modifier_group_credit" => "0.00",
              "modifier_group_max_price" => "88888.00",
              "modifier_group_max_modifier_count" => "3",
              "modifier_group_min_modifier_count" => "0",
              "modifier_group_display_priority" => "60",
              "modifier_items" => [
                  {
                      "modifier_item_name" => "Queso Inside Your Item",
                      "modifier_item_priority" => "500",
                      "modifier_item_id" => "1602065",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "1.00"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Chili Con Queso Inside",
                      "modifier_item_priority" => "490",
                      "modifier_item_id" => "2307642",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "1.30"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Bacon",
                      "modifier_item_priority" => "165",
                      "modifier_item_id" => "1602063",
                      "modifier_item_max" => "2",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "1.00"
                          }
                      ]
                  }
              ]
          },
          {
              "modifier_group_display_name" => "Guacamole",
              "modifier_group_credit" => "999.00",
              "modifier_group_max_price" => "88888.00",
              "modifier_group_max_modifier_count" => "1",
              "modifier_group_min_modifier_count" => "0",
              "modifier_group_display_priority" => "60",
              "modifier_items" => [
                  {
                      "modifier_item_name" => "Guacamole",
                      "modifier_item_priority" => "170",
                      "modifier_item_id" => "1602155",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => "0",
                      "modifier_item_pre_selected" => "yes",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "1.00"
                          }
                      ]
                  }
              ]
          },
          {
              "modifier_group_display_name" => "Make It a Meal",
              "modifier_group_credit" => "0.00",
              "modifier_group_max_price" => "88888.00",
              "modifier_group_max_modifier_count" => "1",
              "modifier_group_min_modifier_count" => "0",
              "modifier_group_display_priority" => "50",
              "modifier_items" => [
                  {
                      "modifier_item_name" => "Reg. Drink and Queso",
                      "modifier_item_priority" => "180",
                      "modifier_item_id" => "1602101",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "2.49"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Reg. Drink and Guac",
                      "modifier_item_priority" => "170",
                      "modifier_item_id" => "1602103",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "2.49"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Reg. Drink and Cookie",
                      "modifier_item_priority" => "160",
                      "modifier_item_id" => "1602111",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "2.49"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Lg. Drink and Queso",
                      "modifier_item_priority" => "80",
                      "modifier_item_id" => "2304874",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "3.29"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Lg. Drink and Guac",
                      "modifier_item_priority" => "70",
                      "modifier_item_id" => "2304873",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "3.29"
                          }
                      ]
                  },
                  {
                      "modifier_item_name" => "Lg. Drink and Cookie",
                      "modifier_item_priority" => "60",
                      "modifier_item_id" => "2304872",
                      "modifier_item_max" => "1",
                      "modifier_item_min" => 0,
                      "modifier_item_pre_selected" => "no",
                      "modifier_prices_by_item_size_id" => [
                          {
                              "size_id" => "70003",
                              "modifier_price" => "3.29"
                          }
                      ]
                  }
              ]
          }
      ],
      "photos" => [
          {
              "id" => "20031",
              "item_id" => "286604",
              "url" => "https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.moes/menu-item-images/small/1x/286604.jpg",
              "width" => "79",
              "height" => "79"
          },
          {
              "id" => "20032",
              "item_id" => "286604",
              "url" => "https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.moes/menu-item-images/small/2x/286604.jpg",
              "width" => "158",
              "height" => "158"
          },
          {
              "id" => "20033",
              "item_id" => "286604",
              "url" => "https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.moes/menu-item-images/large/1x/286604.jpg",
              "width" => "320",
              "height" => "210"
          },
          {
              "id" => "20034",
              "item_id" => "286604",
              "url" => "https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.moes/menu-item-images/large/2x/286604.jpg",
              "width" => "640",
              "height" => "420"
          }
      ]
  }
end

def favorite_order
  {
      "favorite_name" => "The Shalom",
      "favorite_order" => {
          "note" => "",
          "items" => [
              {
                  "quantity" => 1,
                  "note" => "Lots of love!",
                  "size_id" => "70003",
                  "item_id" => "286604",
                  "sizeprice_id" => "1831025",
                  "mods" => [
                      {
                          "mod_sizeprice_id" => "6797851",
                          "mod_quantity" => 1,
                          "quantity" => 1,
                          "modifier_item_id" => "1602019",
                          "mod_item_id" => "1602019"
                      },
                      {
                          "mod_sizeprice_id" => "6797917",
                          "mod_quantity" => 1,
                          "quantity" => 1,
                          "modifier_item_id" => "1602035",
                          "mod_item_id" => "1602035"
                      },
                      {
                          "mod_sizeprice_id" => "6797926",
                          "mod_quantity" => 1,
                          "quantity" => 1,
                          "modifier_item_id" => "1602053",
                          "mod_item_id" => "1602053"
                      },
                      {
                          "mod_sizeprice_id" => "6797927",
                          "mod_quantity" => 1,
                          "quantity" => 1,
                          "modifier_item_id" => "1602055",
                          "mod_item_id" => "1602055"
                      },
                      {
                          "mod_sizeprice_id" => "6797947",
                          "mod_quantity" => 1,
                          "quantity" => 1,
                          "modifier_item_id" => "1602149",
                          "mod_item_id" => "1602149"
                      },
                      {
                          "mod_sizeprice_id" => "6797922",
                          "mod_quantity" => 1,
                          "quantity" => 1,
                          "modifier_item_id" => "1602045",
                          "mod_item_id" => "1602045"
                      },
                      {
                          "mod_sizeprice_id" => "6797937",
                          "mod_quantity" => 1,
                          "quantity" => 1,
                          "modifier_item_id" => "1602083",
                          "mod_item_id" => "1602083"
                      },
                      {
                          "mod_sizeprice_id" => "6797948",
                          "mod_quantity" => 1,
                          "quantity" => 1,
                          "modifier_item_id" => "1602155",
                          "mod_item_id" => "1602155"
                      },
                      {
                          "mod_sizeprice_id" => "6797942",
                          "mod_quantity" => 1,
                          "quantity" => 1,
                          "modifier_item_id" => "1602111",
                          "mod_item_id" => "1602111"
                      }
                  ]
              }
          ]
      }
  }
end
