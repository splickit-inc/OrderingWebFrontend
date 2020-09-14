describe("DialogController", function() {
  var dialog, dialog2;
  afterEach(function () {
    // Dialogs from the tests stay open if we don't do this
    Dialog.close_all();
  });

  describe("#open", function() {
    afterEach(function() {
      dialog.close();
    });

    it("should close all other open dialogs", function() {
      dialog = new Dialog({id: "eins"});
      dialog.open();

      expect($("#eins")).toBeInDOM();

      dialog2 = new Dialog({id: "zwei"});
      dialog2.open();

      expect($("#eins")).not.toBeInDOM();
      expect($("#zwei")).toBeInDOM();
    });

    it("should set the height based on the content", function() {
      dialog = new Dialog();
      var contentHeightSpy = spyOn(dialog, "setContentHeight");
      dialog.open();
      expect(contentHeightSpy).toHaveBeenCalled();
    });

    it("should append the dialog overlay to the DOM", function() {
      dialog = new Dialog({title: "Computer Love"});
      dialog.open();
      expect($("body")).toContainText('Computer Love');
    });

    it("should append the dialog content to the DOM", function() {
      dialog = new Dialog({content: "I'm The Operator With My Pocket Calculator"});
      dialog.open();
      expect($("body")).toContainText("I'm The Operator With My Pocket Calculator");
    });

    it("should bind event to keypress", function() {
      dialog = new Dialog({ title: "Computer Love" });
      var onSpy = spyOn(dialog.dialog, "on");
      dialog.open();
      expect(onSpy).toHaveBeenCalledWith("keydown", Dialog.closeKeyEvent);
    });
  });

  describe("#openMultiple", function() {
    it("should bind all Close events", function() {
      dialog = new Dialog({ title: "Computer Love" });
      var bindSpy = spyOn(dialog, "bindCloseEvents");
      dialog.openMultiple();
      expect(bindSpy).toHaveBeenCalled();
    });

    it("should getZIndexForNew and change ZIndex for overlay and dialog for second dialog", function() {
      dialog = new Dialog({ title: "Computer Love" });
      dialog2 = new Dialog({ title: "New Dialog" });
      var getZIndexSpy = spyOn(Dialog, "zIndexForNewDialog").and.callThrough();
      var overlaySpy = spyOn(dialog2.overlay, "zIndex");
      var dialogSpy = spyOn(dialog2.dialog, "zIndex");
      dialog.openMultiple();
      dialog2.openMultiple();
      expect(getZIndexSpy).toHaveBeenCalled();
      expect(overlaySpy).toHaveBeenCalledWith(50);
      expect(dialogSpy).toHaveBeenCalledWith(60);
    });

    it("should set the height based on the content", function() {
      dialog = new Dialog();
      var contentHeightSpy = spyOn(dialog, "setContentHeight");
      dialog.openMultiple();
      expect(contentHeightSpy).toHaveBeenCalled();
    });

    it("should append the dialog overlay to the DOM", function() {
      dialog = new Dialog({title: "Computer Love"});
      dialog.openMultiple();
      expect($("body")).toContainText('Computer Love');
    });

    it("should append the dialog content to the DOM", function() {
      dialog = new Dialog({content: "I'm The Operator With My Pocket Calculator"});
      dialog.openMultiple();
      expect($("body")).toContainText("I'm The Operator With My Pocket Calculator");
    });
  });

  describe("#close", function() {
    it("should unbind all Close events", function() {
      dialog = new Dialog({ title: "Computer Love" });
      var unbindSpy = spyOn(dialog, "unbindCloseEvents");
      dialog.open();
      dialog.close();
      expect(unbindSpy).toHaveBeenCalled();
    });

    it("should remove the dialog overlay from the DOM", function() {
      var dialog = new Dialog({id: "drei"});
      dialog.open();
      dialog.close();
      expect($("#drei")).not.toBeInDOM();
    });

    it("should remove the dialog content from the DOM", function() {
      var dialog = new Dialog({content: "I program my home computer"});
      dialog.open();
      dialog.close();
      expect($("body")).not.toContainText("I program my home computer");
    });
  });

  describe("#closeKeyEvent", function() {
    afterEach(function() {
      Dialog.close_all();
    });

    it("shouldn't call close", function() {
      dialog = new Dialog({ title: "Computer Close" });
      dialog.open();
      dialog.close();
      var closeSpy = spyOn(dialog, "close").and.callThrough();
      keyPress(dialog.body, 27);
      expect(closeSpy).not.toHaveBeenCalled();
    });
  });

  describe("#bindCloseEvents", function() {
    it("should bind event to keypress", function() {
      dialog = new Dialog({ title: "Computer Love" });
      var onSpy = spyOn(dialog.dialog, "on");
      dialog.open();
      expect(onSpy).toHaveBeenCalledWith("keydown", Dialog.closeKeyEvent);
    });

    it("should bind event to overlay click", function() {
      dialog = new Dialog({ title: "Computer Love" });
      var clickSpy = spyOn(dialog.overlay, "click");
      dialog.open();
      expect(clickSpy).toHaveBeenCalledWith(dialog.close);
    });

    it("should bind event to [data-dialog-close] elements", function() {
      dialog = new Dialog({ title: "Computer Love" });
      var onSpy = spyOn(dialog.dialog, "on");
      dialog.open();
      expect(onSpy).toHaveBeenCalledWith("click", "[data-dialog-close]", dialog.close);
    });
  });

  describe("#unbindCloseEvents", function() {
    it("should unbind event to keypress", function() {
      dialog = new Dialog({ title: "Computer Love" });
      var offSpy = spyOn(dialog.dialog, "off");
      dialog.open();
      dialog.close();
      expect(offSpy).toHaveBeenCalledWith("keydown", Dialog.closeKeyEvent);
    });

    it("should unbind event to overlay click", function() {
      dialog = new Dialog({ title: "Computer Love" });
      var offSpy = spyOn(dialog.overlay, "off");
      dialog.open();
      dialog.close();
      expect(offSpy).toHaveBeenCalledWith("click", dialog.close);
    });

    it("should unbind event to [data-dialog-close] elements", function() {
      dialog = new Dialog({ title: "Computer Love" });
      var offSpy = spyOn(dialog.dialog, "off");
      dialog.open();
      dialog.close();
      expect(offSpy).toHaveBeenCalledWith("click", "[data-dialog-close]", dialog.close);
    });
  });

  describe("#close_all", function() {
    // TODO: tests; currently untested.
  });

  describe("#zIndexForNewDialog", function() {
    beforeEach(function() {
      Dialog.opened = [];
    });

    it("should return max ZIndex", function() {
      Dialog.opened.push(new Dialog({ title: "Computer Love" }));
      Dialog.opened.push(new Dialog({ title: "Computer Love 2" }));
      expect(Dialog.zIndexForNewDialog()).toEqual(40);
    });
  });

  describe("#setContentHeight", function() {
    // TODO: tests; currently untested.
  });

  describe("#addToOrder", function() {
    var item, itemModifiers;

    beforeEach(function() {
      itemModifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Les Paul",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          size_prices: [{size_id: 1, modifier_price: "0"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Fender",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          size_prices: [{size_id: 1, modifier_price: "0"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Neal Peart",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          size_prices: [{size_id: 1, modifier_price: "0"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Tommy Aldridge",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          size_prices: [{size_id: 1, modifier_price: "0"}]
        })
      ];

      item = new MenuItem({
        id: 1,
        name: "Lenny Kravitz Sandwich",
        description: "",
        modifier_groups: [
          new ModifierGroup({
            name: "Guitars",
            modifiers: [itemModifiers[0], itemModifiers[1]]
          }),
          new ModifierGroup({
            name: "Drum Solos",
            modifiers: [itemModifiers[2], itemModifiers[3]]
          })
        ],
        size_prices: [{
          size_id: 1,
          price: "8.99",
          points: "97",
          enabled: true
        }],
        point_range: "97"
      });

      dialog = new Dialog();
    });

    it("should call order service, specifying price_string in points if the caller specifies 'points'", function() {
      var orderServiceSpy = spyOn(dialog.orderService, "createItem");
      dialog.addToOrder([item], 'points');
      expect(orderServiceSpy.calls.mostRecent().args[0][0].price_string).toMatch(/97 pts/);
    });

    it("should call order service, setting points attribute", function() {
      var orderServiceSpy = spyOn(dialog.orderService, "createItem");
      dialog.addToOrder([item], 'points');
      expect(orderServiceSpy.calls.mostRecent().args[0][0].price_string).toMatch(/97/);
    });

    it("should call order service, specifying price_string in dollars if the caller specifies 'cash'", function() {
      var orderServiceSpy = spyOn(dialog.orderService, "createItem");
      dialog.addToOrder([item], 'cash');
      expect(orderServiceSpy.calls.mostRecent().args[0][0].price_string).toEqual('$8.99');
    });

    it("should call order service, setting cash attribute", function() {
      var orderServiceSpy = spyOn(dialog.orderService, "createItem");
      dialog.addToOrder([item], 'cash');
      expect(orderServiceSpy.calls.mostRecent().args[0][0].cash).toMatch(/8.99/);
    });

    it("should default the price_string to dollars", function() {
      var orderServiceSpy = spyOn(dialog.orderService, "createItem");
      dialog.addToOrder([item]);
      expect(orderServiceSpy.calls.mostRecent().args[0][0].price_string).toEqual('$8.99');
    });

    it("should pass in the add item callback", function() {
      var orderServiceSpy = spyOn(dialog.orderService, "createItem");
      dialog.addToOrder([item]);
      expect(orderServiceSpy).toHaveBeenCalledWith(jasmine.any(Object), Dialog.addItemCallback);
    });
  });

  describe("#addItemCallback", function() {
    beforeEach(function() {
      loadFixtures('dialog.html');
    });

    it("displays the 'add item' popup", function() {
      spyOn(Dialog, "updateCounter");
      var displayAddConfirmationPopupSpy = spyOn(Dialog, "displayAddConfirmationPopup");
      Dialog.addItemCallback({order: {items: [1, 2, 3]}});
      expect(displayAddConfirmationPopupSpy).toHaveBeenCalled();
    });

    it("updates the counter", function() {
      var updateCounterSpy = spyOn(Dialog, "updateCounter");
      Dialog.addItemCallback({order: {items: [1, 2, 3]}});
      expect(updateCounterSpy).toHaveBeenCalled();
    });
  });

  describe("#updateCounter", function() {
    it("should update the item count based on returned order", function() {
      loadFixtures('dialog_view.html');
      var order = {"order": {items: [
        {"itemId": "1"},
        {"itemId": "2"},
        {"itemId": "3"}
      ]}};
      expect($('header div.order').attr('data-item-count')).toEqual("2");
      Dialog.updateCounter(order);
      expect($('header div.order').attr('data-item-count')).toEqual("3");
    });
  });

  describe("#displayAddConfirmationPopup", function() {
    beforeEach(function() {
      loadFixtures('dialog.html');
    });

    it("appends the popup to the header", function() {
      var appendSpy = spyOn($.fn, "append");
      Dialog.displayAddConfirmationPopup();
      expect(appendSpy).toHaveBeenCalled();
    });

    describe("group order", function() {
      beforeEach(function() {
        loadFixtures('dialog_group_order.html');
      });

      it("compiles the correct handlebars template", function() {
        var compileSpy = spyOn(Handlebars, "compile");
        Dialog.displayAddConfirmationPopup();
        expect(compileSpy).toHaveBeenCalledWith(HandlebarsTemplates['merchants/item_added_popup']({
          item_added_popup_title: "Item Added to My Cart",
          popupClass: "group-order",
          checkoutURL: "/checkouts/new?group_order_token=MAGIC-TOKEN&merchant_id=1234&order_type=pickup",
          checkoutText: "Submit to Group Order"
        }));
      });
    });

    describe("normal order", function() {
      it("compiles the correct handlebars template", function() {
        var compileSpy = spyOn(Handlebars, "compile");
        Dialog.displayAddConfirmationPopup();
        expect(compileSpy).toHaveBeenCalledWith(HandlebarsTemplates['merchants/item_added_popup']({
          item_added_popup_title: "Item successfully added",
          checkoutURL: "/checkouts/new?merchant_id=1234&order_type=pickup",
          checkoutText: "Checkout"
        }));
      });
    });


    it("fades in the popup dialog", function() {
      var fadeInSpy = spyOn($.fn, "fadeIn");
      Dialog.displayAddConfirmationPopup();
      expect(fadeInSpy).toHaveBeenCalledWith("fast");
    });

    it("removes dialog from DOM on blur", function() {
      var removeSpy = spyOn($.fn, "remove");
      Dialog.displayAddConfirmationPopup();
      $("body").click();
      expect(removeSpy).toHaveBeenCalled();
    });

    it("redirects to checkout", function() {
      var bindDisplayMyOrderSpy = spyOn(Dialog, "bindDisplayMyOrder");
      Dialog.displayAddConfirmationPopup();
      expect(bindDisplayMyOrderSpy).toHaveBeenCalled();
    });
  });

  describe("#updateCheckoutTotal", function() {
    // TODO: tests; currently untested.
  });

  describe("#submitToGroupOrder", function() {
    it("should redirect with  the correct group order token + merchant ID", function() {
      loadFixtures('dialog_view.html');
      redirectSpy = spyOn(Dialog, 'redirect');
      Dialog.submitToGroupOrder({group_order_token: "1X4U-BACON", merchant_id: "100029", order_type: "pickup"});
      expect(redirectSpy).toHaveBeenCalledWith("/checkouts/new?group_order_token=1X4U-BACON&merchant_id=100029&order_type=pickup")
    });

    it("should redirect with the delivery param if it exists", function() {
      loadFixtures('dialog_view_delivery.html');
      redirectSpy = spyOn(Dialog, 'redirect');
      Dialog.submitToGroupOrder({group_order_token: "1X4U-BACON", merchant_id: "100029", order_type: "delivery"});
      expect(redirectSpy).toHaveBeenCalledWith("/checkouts/new?group_order_token=1X4U-BACON&merchant_id=100029&order_type=delivery")
    });
  });

  describe("#checkout", function() {
    it("should redirect with to /order/checkout", function() {
      loadFixtures('dialog_view.html');
      redirectSpy = spyOn(Dialog, 'redirect');
      Dialog.checkout();
      expect(redirectSpy).toHaveBeenCalledWith("/order/checkout")
    });
  });

  describe("#removeItem", function() {
    var dialog;

    beforeEach(function() {
      dialog = new Dialog();
    });

    it("should call order service with item id and callback", function() {
      var orderServiceSpy = spyOn(OrderService.prototype, "deleteItem");
      mockCallback = jasmine.createSpy("callback")
      Dialog.removeItem("1234", mockCallback)
      expect(orderServiceSpy).toHaveBeenCalledWith("1234", mockCallback);
    });
  });
});

function keyPress(element, key) {
  var event = $.Event("keydown");
  event.which = key;
  element.trigger(event);
}