describe("MyOrderController", function () {
  var response;

  beforeEach(function() {
    window.upsellItems = {};
    var upsellItemParams = {
      item_id: "212013",
      item_name: "Black Forest Ham",
      description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
      large_image: "https://image.com/large/2x/212013.jpg",
      small_image: "https://image.com/small/2x/212013.jpg",
      modifier_groups: [],
      size_prices: [
        { size_id: 1, price: "8.99", enabled: true },
        { size_id: 2, price: "8.99", enabled: true }
      ],
      point_range: 90,
      notes: "Hold teh lettuce, please."
    };
    window.upsellItems["212013"] = new UpsellItem(upsellItemParams);

    response = {
      order: {
        items: [{
          item_id: 288218,
          item_name: "Chili Con Queso Burrito",
          large_image: "https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.moes/menu-item-images/large/2x/288218.jpg",
          small_image: "https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.moes/menu-item-images/small/1x/288218.jpg",
          description: "Served in a flour or whole grain tortilla with seasoned rice, beans, all-natural shredded cheese, pico de gallo and Chili Con Queso. Protein options include grass-fed steak, all-natural chicken, grain-fed pulled pork, 100% ground beef or organic tofu.",
          size_prices:[{
            size_id: "70001",
            price: "7.78",
            size_name: "Original",
            enabled: true
          }],
          notes:"",
          point_range:[],
          modifier_groups:[{
            modifier_group_display_name: "Tortilla",
            modifier_items:[{
              modifier_item_id: 1602019,
              modifier_item_name: "Flour Tortilla",
              modifier_item_max: 1,
              modifier_item_min: 0,
              modifier_item_pre_selected: true,
              modifier_prices_by_item_size_id: [{
                size_id: "70001",
                modifier_price: "0.00"
              }],
              basePrice: "0.00",
              netPrice:0,
              quantity:1,
              exclusive: true
            }, {
              modifier_item_id: 1602021,
              modifier_item_name: "Whole Grain Tortilla",
              modifier_item_max: 1,
              modifier_item_min: 0,
              modifier_item_pre_selected: false,
              modifier_prices_by_item_size_id:[{
                size_id: "70001",
                modifier_price: "0.00"
              }],
              basePrice: "0.00",
              netPrice: 0,
              quantity: 0,
              exclusive: true
            }],
            modifier_group_max_modifier_count: "1",
            modifier_group_min_modifier_count: "1",
            remainingCredit: "0.00"
          }]
        }],
        meta: {
          group_order_token: false,
          skin_name: "moes",
          merchant_name: "name",
          merchant_id: 123,
          order_type: "pickup"
        }
      }
    };
  });

  describe("getSubtotalString", function () {
    it("should return an empty string for subtotal and points < 0", function () {
      expect(MyOrderController.getSubtotalString(-1, -1)).toEqual("");
    });

    it("should return a string with $ if subtotal > 0", function () {
      expect(MyOrderController.getSubtotalString(12, -1)).toEqual(" - $12.00");
    });

    it("should return a string with pts if totalPoints > 0", function () {
      expect(MyOrderController.getSubtotalString(-1, 44)).toEqual(" - 44 pts");
    });

    it("should return a string with $ and pts if subtotal and totalPoints > 0", function () {
      expect(MyOrderController.getSubtotalString(33, 33)).toEqual(" - 33 pts + $33.00");
    });
  });

  describe("removeItemCallback", function () {
    beforeEach(function () {
      loadFixtures('my_order_dialog.html');
    });

    afterEach(function () {
      $("#my-order").remove();
    });

    it("should disable the checkout button if no items are left in the order", function () {
      MyOrderController.removeItemCallback({order: {items: []}}, {target: "[data-item-id='1414427562919']"});
      expect($("button.checkout").prop("disabled")).toBe(true);
    });

    it("should remove the chosen item from the dialog", function () {
      expect($("[data-item-id='1414427562919']")).toExist();
      MyOrderController.removeItemCallback({order: {items: []}}, {target: "[data-item-id='1414427562919']"});
      expect($("[data-item-id='1414427562919']")).not.toExist();
    });

    it("should update the dialog counter", function () {
      var dialogSpy = spyOn(Dialog, "updateCounter");
      MyOrderController.removeItemCallback({order: {items: []}}, {target: "[data-item-id='1414427562919']"});
      expect(dialogSpy).toHaveBeenCalledWith({order: {items: []}});
    });

    it("should update the dialog checkout total string", function () {
      var dialogSpy = spyOn(Dialog, "updateCheckoutTotal");
      spyOn(MyOrderController, "getSubtotalString").and.returnValue(" - 4 pints of Regis Philbin's blood");
      MyOrderController.removeItemCallback({order: {items: []}}, {target: "[data-item-id='1414427562919']"});
      expect(dialogSpy).toHaveBeenCalledWith(" - 4 pints of Regis Philbin's blood");
    });
  });

  describe("#merchantMenuPath", function() {
    var orderMetaData = {};

    describe("with group_order_token", function() {
      beforeEach(function() {
        orderMetaData = {
          group_order_token: "456",
          skin_name: "moes",
          merchant_name: "name",
          merchant_id: 123,
          order_type: "pickup"
        };
      });

      it("should return correct merchant menu page", function() {
        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup&group_order_token=456")
      });
    });

    describe("catering order", function () {
      beforeEach(function() {
        orderMetaData = {
          group_order_token: null,
          skin_name: "moes",
          merchant_name: "name",
          merchant_id: 123,
          order_type: "pickup",
          catering: true
        };
      });

      it("should return correct merchant menu page", function() {
        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup&catering=1")
      });
    });

    describe("standard order", function() {
      beforeEach(function() {
        orderMetaData = {
          skin_name: "moes",
          merchant_name: "name",
          merchant_id: 123,
          order_type: "pickup"
        };
      });

      it("should return correct merchant menu page without group order token", function() {
        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup");
      });

      it("should return correct merchant menu page without group order token when it is undefined", function() {
        orderMetaData = {
          group_order_token: undefined,
          skin_name: "moes",
          merchant_name: "name",
          merchant_id: 123,
          order_type: "pickup"
        };

        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup");
      });

      it("should return correct merchant menu page without group order token when it is undefined", function() {
        orderMetaData = {
          group_order_token: null,
          skin_name: "moes",
          merchant_name: "name",
          merchant_id: 123,
          order_type: "pickup"
        };

        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup");
      });

      it("should return correct merchant menu page without group order token when it is undefined", function() {
        orderMetaData = {
          group_order_token: false,
          skin_name: "moes",
          merchant_name: "name",
          merchant_id: 123,
          order_type: "pickup"
        };

        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup");
      });

      it("should return correct merchant menu page without group order token when it is undefined", function() {
        orderMetaData = {
          group_order_token: "",
          skin_name: "moes",
          merchant_name: "name",
          merchant_id: 123,
          order_type: "pickup"
        };

        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup");
      });

      it("should return correct merchant menu page without group order and catering", function() {
        orderMetaData.catering = "";

        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup");

        orderMetaData.catering = undefined;

        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup");

        orderMetaData.catering = null;

        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup");

        orderMetaData.catering = false;

        var url = MyOrderController.merchantMenuPath(orderMetaData);
        expect(url).toEqual("/merchants/123?order_type=pickup");
      });
    });
  });

  describe("#subtitleHTML", function () {
    var validParams = {
      skin_name: "Bacon Pit",
      merchant_name: "Coeur d'Alene, 320 Sherman Ave",
      merchant_id: "182738",
      order_type: "delivery"
    };

    describe("valid order meta data", function() {
      it("returns a valid subtitle", function() {
        var validSubtitle = "Bacon Pit: <a href=\"/merchants/182738?order_type=delivery\">Coeur d'Alene, 320 Sherman Ave</a>"
        expect(MyOrderController.subtitleHTML(validParams)).toEqual(validSubtitle);
      });
    });

    describe("invalid order meta data", function() {
      it("returns false when missing a skinName", function() {
        var invalidParams = {
          merchant_name: "Coeur d'Alene, 320 Sherman Ave",
          merchant_id: "182738"
        };

        expect(MyOrderController.subtitleHTML(invalidParams)).toEqual(false);
      });

      it("returns false when missing a merchantName", function() {
        var invalidParams = {
          skin_name: "Bacon Pit",
          merchant_id: "182738"
        };

        expect(MyOrderController.subtitleHTML(invalidParams)).toEqual(false);
      });

      it("returns false when missing a merchantID", function() {
        var invalidParams = {
          skin_name: "Bacon Pit",
          merchant_name: "Coeur d'Alene, 320 Sherman Ave"
        };

        expect(MyOrderController.subtitleHTML(invalidParams)).toEqual(false);
      });

      it("returns false when there is no meta data", function() {
        expect(MyOrderController.subtitleHTML(undefined)).toEqual(false);
      });
    });
  });

  describe("#openMyOrder", function() {
    it("should render items partial", function() {
      MyOrderController.openMyOrder(response);
      expect($("section#items-section article").length).toEqual(1);
    });

    it("should render upsell partial item", function() {
      MyOrderController.openMyOrder(response);
      var articles = $("section#upsell-items-section article");
      expect(articles.length).toEqual(1);
      expect($("section#upsell-items-section h4").text()).toContain("Would you like to:");
      expect(articles.find("span.price").text()).toEqual("$8.99");
      expect(articles.find("div.details h3").text()).toContain("Add Black Forest Ham");
    });

    it("should not render upsell partial item if it is in cart", function() {
      window.upsellItems["288218"] = window.upsellItems["212013"];
      window.upsellItems["288218"].item_id = 288218;
      delete window.upsellItems["212013"]

      MyOrderController.openMyOrder(response);
      var articles = $("section#upsell-items-section article");
      expect(articles.length).toEqual(0);
    });

    it("should not render upsell partial item if there are no items in cart", function() {
      response.order.items = [];

      MyOrderController.openMyOrder(response);
      var articles = $("section#upsell-items-section article");
      expect(articles.length).toEqual(0);
    });
  });

  describe("#bindMenuItemClickEvents", function() {
    it("should call delete and edit", function() {
      var deleteSpy = spyOn(MyOrderController, "bindDeleteItem");
      var editSpy = spyOn(MyOrderController, "bindEditItem");
      MyOrderController.bindMenuItemsClickEvents();
      expect(deleteSpy).toHaveBeenCalled();
      expect(editSpy).toHaveBeenCalled();
    });
  });

  describe("#bindAddUpsell", function() {
    describe("it has modifiers", function() {
      beforeEach(function() {
        window.user = new User({ points: 50 });

        var modifierGroupParams = {
          modifier_group_display_name: "meat",
          modifier_items: [
            new ModifierItem({
              modifier_item_id: 1,
              modifier_item_name: "Bender",
              modifier_item_max: 1,
              modifier_item_min: 0,
              modifier_item_pre_selected: true,
              quantity: 1,
              size_prices: [{size_id: 1, modifier_price: "1.00"}]
            })
          ],
          modifier_group_credit: 0.99,
          modifier_group_max_modifier_count: 4,
          modifier_group_min_modifier_count: 1,
          modifier_group_max_price: 4.00
        };

        window.upsellItems["212013"].modifier_groups = [new ModifierGroup(modifierGroupParams)];
        MyOrderController.openMyOrder(response);
      });

      it("should call Item show", function() {
        var menuItemsControllerShowSpy = spyOn(MenuItemsController, "show");
        MyOrderController.openMyOrder(response);
        $("section#upsell-items-section .add-item").first().trigger("click");
        expect(menuItemsControllerShowSpy).toHaveBeenCalled();
      });

      it("should open Item modal", function() {
        spyOn(MenuItemsController, "show").and.callThrough();
        MyOrderController.openMyOrder(response);
        $("section#upsell-items-section .add-item").first().trigger("click");
        expect($("#add-to-order").length).toEqual(1);
        expect($("#add-to-order section#details h4").text()).toContain("Black Forest Ham");
        expect($("#add-to-order section#details p").text()).toContain("Black Forest Ham, Shredded Lettuce, Tomatoes");
      });
    });

    describe("it doesn't have modifiers", function() {
      beforeEach(function() {
        MyOrderController.openMyOrder(response);
      });

      it("should call AddToOrder", function() {
        var addToOrderSpy = spyOn(MenuItems.prototype, "addToOrder");
        $("section#upsell-items-section .add-item").first().trigger("click");
        expect(addToOrderSpy).toHaveBeenCalled();
      });
    });
  });

  describe("#renderItemSection", function() {
    it("should render items partial", function() {
      MyOrderController.openMyOrder(response);
      var order = response.order;
      order.items.push(order.items[0]);
      MyOrderController.renderItemSection(order);
      expect($("section#items-section article").length).toEqual(2);
    });

    it("should call bindMenuItemsClickEvents", function() {
      var bindMenuItemsClickEventsSpy = spyOn(MyOrderController, "bindMenuItemsClickEvents");
      MyOrderController.renderItemSection(response.order);
      expect(bindMenuItemsClickEventsSpy).toHaveBeenCalled();
    });
  });

  describe("#renderUpsellSection", function() {
    it("should render upsell partial", function() {
      var upsellItemParams = {
        item_id: "212014",
        item_name: "Black Forest Ham2",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/2x/212013.jpg",
        modifier_groups: [],
        size_prices: [
          { size_id: 1, price: "8.99", enabled: true },
          { size_id: 2, price: "8.99", enabled: true }
        ],
        point_range: 90,
        notes: "Hold teh lettuce, please."
      };
      window.upsellItems["212014"] = new UpsellItem(upsellItemParams);

      MyOrderController.openMyOrder(response);
      var articles = $("section#upsell-items-section article");
      expect(articles.length).toEqual(2);

      // Change orders to contain a Upsell Item
      var order = response.order;
      order.items.push(order.items[0]);
      order.items[1].item_id = 212014;

      MyOrderController.renderUpsellSection(order);
      articles = $("section#upsell-items-section article");
      expect(articles.length).toEqual(1);
      expect($("section#upsell-items-section h4").text()).toContain("Would you like to:");
      expect(articles.find("span.price").text()).toEqual("$8.99");
      expect(articles.find("div.details h3").text()).toContain("Add Black Forest Ham");
    });
  });

  describe("#addUpsellItemCallback", function() {
    it("should call render ItemSection", function(){
      var renderItemSectionSpy = spyOn(MyOrderController, "renderItemSection");
      MyOrderController.addUpsellItemCallback(response, { target: $(".add-item") });
      expect(renderItemSectionSpy).toHaveBeenCalledWith(response.order);
    });

    it("should call render updateCheckoutButtons", function(){
      var updateCheckoutButtonSpy = spyOn(MyOrderController, "updateCheckoutButtons");
      MyOrderController.addUpsellItemCallback(response, { target: $(".add-item") });
      expect(updateCheckoutButtonSpy).toHaveBeenCalledWith(response);
    });

    it("should clear the upsell items if available upsell items is 0", function() {
      response.order.items[0].item_id = 212013;
      MyOrderController.addUpsellItemCallback(response, { target: $(".add-item") });
      expect($("div#my_order_upsell_items").children().length).toEqual(0);
    });

    it("should remove the article", function() {
      MyOrderController.addUpsellItemCallback(response, { target: $(".add-item") });
      expect($("add-item").length).toEqual(0);
    });
  });

  describe("#availableUpsellItem", function() {
    var order;

    beforeEach(function() {
      var upsellItemParams = {
        item_id: "212014",
        item_name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/2x/212013.jpg",
        modifier_groups: [],
        size_prices: [
          { size_id: 1, price: "8.99", enabled: true },
          { size_id: 2, price: "8.99", enabled: true }
        ],
        point_range: 90,
        notes: "Hold teh lettuce, please."
      };
      window.upsellItems["212014"] = new UpsellItem(upsellItemParams);
    });

    it("should return all upsell items, because none is in the order", function() {
      expect(MyOrderController.availableUpsellItems(response.order).length).toEqual(2);
    });

    it("should return an array without items that are in the order", function() {
      response.order.items[0].item_id = 212014;
      expect(MyOrderController.availableUpsellItems(response.order).length).toEqual(1);
    });

    it("should return an empty array because all items are in the order", function() {
      response.order.items[0].item_id = 212014;
      delete window.upsellItems["212013"]
      expect(MyOrderController.availableUpsellItems(response.order).length).toEqual(0);
    });
  });
});
