 describe("MenuItemsController", function () {
  "use strict";

  beforeEach(function() {
    window.skin = new Skin({ skinName: "Pitapit" });
  });

  afterEach(function() {
    Dialog.close_all();
  });

  describe("#show", function () {
    var item = new MenuItem({
      id: "212013",
      name: "Black Forest Ham",
      description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
      large_image: "https://image.com/large/2x/212013.jpg",
      small_image: "https://image.com/small/1x/212013.jpg",
      modifier_groups: [
        new ModifierGroup({name: "Meat"}),
        new ModifierGroup({name: "Cheese"})
      ],
      size_prices: [
        {size_id: 1, price: "1", enabled: true},
        {size_id: 2, price: "2", enabled: false}
      ],
      point_range: 90,
      notes: "Hold teh lettuce, please.",
      points_used: 0
    });

    var params = {
      item: item,
      groupOrder: false,
      loyalUser: false,
      redeemableItem: false,
      itemOneSize: false,
      edit: false,
      showNotes: true
    };

    window.show_notes = true;

    it("should create and open a dialog", function () {
      var handlebarsSpy = spyOn(Handlebars, "compile");
      var dialogSpy = jasmine.createSpyObj("dialog", ["open"]);
      var newDialogSpy = spyOn(window, "Dialog").and.returnValue(dialogSpy);

      MenuItemsController.show(params);

      expect(handlebarsSpy).toHaveBeenCalledWith(HandlebarsTemplates['menu_item'](params));
      expect(newDialogSpy).toHaveBeenCalled();
      expect(dialogSpy.open).toHaveBeenCalled();
    });

    it("should call all show methods", function(){
      var updateItemTotalSpy = spyOn(MenuItemsController, "updateItemTotal");
      var bindSizeChangeEventsSpy = spyOn(MenuItemsController, "bindSizeChangeEvents");
      var bindSubEventsSpy = spyOn(MenuItemsController, "bindSubEvents");
      var bindCheckboxEventsSpy = spyOn(MenuItemsController, "bindCheckboxEvents");
      var bindRadioEventsSpy = spyOn(MenuItemsController, "bindRadioEvents");

      MenuItemsController.show(params);

      expect(updateItemTotalSpy).toHaveBeenCalledWith(params.item, params.user, params.edit);
      expect(bindSizeChangeEventsSpy).toHaveBeenCalledWith(params.item, params.user, params.edit);
      expect(bindSubEventsSpy).toHaveBeenCalledWith(params.item, params.user, params.edit);
      expect(bindCheckboxEventsSpy).toHaveBeenCalledWith(params.item, params.user, params.edit);
      expect(bindRadioEventsSpy).toHaveBeenCalledWith(params.item, params.user, params.edit);
    });

    it("it selects the correct size", function () {
      var _selectCorrectSizeSpy = spyOn(MenuItemsController, 'selectCorrectSize');
      MenuItemsController.show(params);
      expect(_selectCorrectSizeSpy).toHaveBeenCalled()
    });

    describe("Moes", function () {
      beforeEach(function() {
        window.skin = new Skin({ skinName: "moes" });
      });

      it("should not bind Nutrition Events", function () {
        var nutritionSpy = spyOn(MenuItemsController, "bindNutritionEvents");

        expect(nutritionSpy).not.toHaveBeenCalled();
      });
    });
  });

  describe("#getNutritionLink", function (){
    beforeEach(function() {
      window.skin = new Skin({ skinName: "moes" });
    });

    it("should return a link for moes", function () {
      expect(MenuItemsController.getNutritionLink()).toBe("http://www.moes.com/food/nutrition");
    });

    it("should return null for anything besides of moes", function () {
      window.skin = new Skin({ skinName: "PitaPit" });
      expect(MenuItemsController.getNutritionLink()).toBeNull();
    });
  });

  describe("#remove", function (){
    pending("TODO");
  });

  describe("#edit", function (){
    pending("TODO");
  });

  describe("#selectCorrectSize", function () {
    beforeEach(function () {
      loadFixtures('menu_item.html');
    });

    it("enables the correct menu item size", function () {
      expect($("input[value='92918']")).not.toBeChecked();
      MenuItemsController.selectCorrectSize(92918);
      expect($("input[value='92918']")).toBeChecked();
    });
  });

  describe("#resetItem", function() {
    it("should call resetQuantity", function() {
      var menuItem = new MenuItem({
        item_id: "212013",
        name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/1x/212013.jpg",
        modifier_groups: [
          new ModifierGroup({name: "Meat"}),
          new ModifierGroup({name: "Cheese"})
        ],
        size_prices: [
          {size_id: 1, price: "1", enabled: true},
          {size_id: 2, price: "2", enabled: false}
        ],
        point_range: 90,
        notes: "Hold teh lettuce, please."
      });

      window.menuItems = {};
      window.menuItems["212013"] = menuItem;

      var resetSpy = spyOn(MenuItem.prototype, "resetQuantity");

      MenuItemsController.resetItem(menuItem);
      expect(resetSpy).toHaveBeenCalled();
    });
  });

  describe("#bindSelectNestedAnimation", function () {
    beforeEach(function () {
      loadFixtures('nested_menu_item.html');
    });

    var item = new MenuItem({
      id: "212013",
      name: "Black Forest Ham",
      description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
      large_image: "https://image.com/large/2x/212013.jpg",
      small_image: "https://image.com/small/1x/212013.jpg",
      modifier_groups: [
        new ModifierGroup({
          name: "Sauce",
          modifier_items: [
            new ModifierItem({
              modifier_item_id: 443239000,
              modifier_item_name: "Mild",
              nestedItems: [
                new ModifierItem({
                  modifier_item_id: 11,
                  modifier_item_name: "BBQ"
                }),
                new ModifierItem({
                  modifier_item_id: 12,
                  modifier_item_name: "Bleu Cheese"
                })
              ]
            })
          ]
        })
      ],
      size_prices: [
        {size_id: 1, price: "1", enabled: true},
        {size_id: 2, price: "2", enabled: false}
      ],
      point_range: 90,
      notes: "Hold teh lettuce, please."
    });

    describe("selecting nested modifiers", function () {
      it("hides the left pane", function() {
        var hideLeftPaneSpy = spyOn($.fn, 'addClass');
        MenuItemsController.bindSelectNestedAnimation(item);
        $('.nm-select').click();
        expect(hideLeftPaneSpy).toHaveBeenCalledWith('nm-left-hidden');
      });

      it("shows the right pane", function() {
        var hideLeftPaneSpy = spyOn($.fn, 'addClass');
        MenuItemsController.bindSelectNestedAnimation(item);
        $('.nm-select').click();
        expect(hideLeftPaneSpy).toHaveBeenCalledWith('nm-right-visible');
      });
    });

    describe("saving nested modifiers", function () {
      it("shows the left pane", function () {
        spyOn(MenuItemsController, 'setNestedModifierText');
        spyOn(MenuItemsController, 'disableSelectButtons');
        var showLeftPaneSpy = spyOn($.fn, 'removeClass');

        MenuItemsController.bindSelectNestedAnimation(item);

        $('.nm-select').click();
        $('.nm-save').click();

        expect(showLeftPaneSpy).toHaveBeenCalledWith('nm-left-hidden');
      });

      it("hides the right pane", function () {
        spyOn(MenuItemsController, 'setNestedModifierText');
        spyOn(MenuItemsController, 'disableSelectButtons');
        var hideRightPaneSpy = spyOn($.fn, 'removeClass');

        MenuItemsController.bindSelectNestedAnimation(item);

        $('.nm-select').click();
        $('.nm-save').click();

        expect(hideRightPaneSpy).toHaveBeenCalledWith('nm-right-visible');
      });

      it("scrolls the previous location", function () {
        spyOn(MenuItemsController, 'setNestedModifierText');
        spyOn(MenuItemsController, 'disableSelectButtons');
        var scrollToSpy = spyOn($.fn, 'scrollTo');

        MenuItemsController.bindSelectNestedAnimation(item);

        $('.nm-select').click();
        $('.nm-save').click();

        expect(scrollToSpy).toHaveBeenCalledWith(0);
      });

      it("removes old nested modifier views", function () {
        spyOn(MenuItemsController, 'setNestedModifierText');
        spyOn(MenuItemsController, 'disableSelectButtons');
        var removeSpy = spyOn($.fn, 'remove');

        MenuItemsController.bindSelectNestedAnimation(item);

        $('.nm-select').click();
        $('.nm-save').click();

        expect(removeSpy).toHaveBeenCalled();
      });

      it("it calls setNestedModifierText", function () {
        var updateNestedModifierTextSpy = spyOn(MenuItemsController, 'setNestedModifierText');
        spyOn(MenuItemsController, 'disableSelectButtons');

        MenuItemsController.bindSelectNestedAnimation(item);

        $('.nm-select').click();
        $('.nm-save').click();

        expect(updateNestedModifierTextSpy).toHaveBeenCalledWith(443239000, item);
      });

      it("it calls disableSelectButtons", function () {
        spyOn(MenuItemsController, 'setNestedModifierText');
        var disableSelectButtonsSpy = spyOn(MenuItemsController, 'disableSelectButtons');

        MenuItemsController.bindSelectNestedAnimation(item);

        $('.nm-select').click();
        $('.nm-save').click();

        expect(disableSelectButtonsSpy).toHaveBeenCalledWith(
          443239000,
          item.findModifierGroup(item.findModifier(443239000))
        );
      });
    });
  });

  describe("#setNestedModifierText", function () {
    pending("TODO");
  });

  describe("#disableSelectButtons", function () {
    pending("TODO");
  });

  describe("#bindTrackingEvents", function () {
    pending("TODO");
  });

  describe("#bindSizeChangeEvents", function () {
    pending("TODO");
  });

  describe("#bindSubEvents", function () {
    pending("TODO");
  });

  describe("#bindAddEvents", function () {
    pending("TODO");
  });

  describe("#bindCheckboxEvents", function () {
    var item, user;

    beforeEach(function () {
      loadFixtures('menu_item.html');

      item = new MenuItem({
        id: "212013",
        name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/1x/212013.jpg",
        modifier_groups: [
          new ModifierGroup({name: "Meat"}),
          new ModifierGroup({name: "Cheese"})
        ],
        size_prices: [
          {size_id: 1, price: "1", enabled: true},
          {size_id: 2, price: "2", enabled: false}
        ],
        point_range: 90,
        notes: "Hold teh lettuce, please."
      });
    });

    it("updates item price", function () {
      spyOn(item, 'toggleModifier').and.callFake(function () {
        return 1;
      });

      var updateAddItemPriceSpy = spyOn(MenuItemsController, 'updateItemTotal');
      MenuItemsController.bindCheckboxEvents(item, user, true);
      $("dd[data-id='1602787'] input").click();

      expect(updateAddItemPriceSpy).not.toHaveBeenCalledWith(item, undefined, true);
    });

    it("updates modifier prices", function () {
      spyOn(item, 'toggleModifier').and.callFake(function () {
        return 1;
      });

      var updateAddModifierPricesSpy = spyOn(MenuItemsController, 'updateModifierNetPriceText');
      MenuItemsController.bindCheckboxEvents(item, user, true);
      $("dd[data-id='1602787'] input").click();

      expect(updateAddModifierPricesSpy).not.toHaveBeenCalledWith(item);
    });

    describe("no change in modifier quantity", function () {
      beforeEach(function () {
        spyOn(item, 'toggleModifier').and.callFake(function () {
          return 0;
        });
      });

      it("keeps boxes unchecked", function () {
        var attrSpy = spyOn($, "attr").and.callThrough();

        MenuItemsController.bindCheckboxEvents(item, user, false);
        $("dd[data-id='1602787'] input").click();

        expect(attrSpy).toHaveBeenCalled();
      });
    });
  });

  describe("#bindRadioEvents", function () {
    pending("TODO");
  });

  describe("#bindAddToOrderEvents", function () {
    var user, itemModifiers, menuItem;

    beforeEach(function () {
      loadFixtures('menu_item.html');

      user = new User({ points: "12" });

      itemModifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Salt",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          modifier_prices_by_item_size_id: [
            { size_id: 1, modifier_price: "0" }
          ]
        })
      ];

      menuItem = new MenuItem({
        id: 1,
        name: "Lenny Kravitz Sandwich",
        description: "",
        modifier_groups: [
          new ModifierGroup({ name: "Beer Can", modifier_items: [itemModifiers[0]] }),
          new ModifierGroup({ name: "Bacon", modifier_items: [itemModifiers[0]] })
        ],
        size_prices: [{ size_id: 1, price: "8.99", points: "", enabled: true }]
      });
    });

    it("should call reset order", function() {
      var dialog = new Dialog();
      var resetSpy = spyOn(MenuItemsController, "resetItem");

      MenuItemsController.bindAddToOrderEvents(menuItem, user, dialog);

      $("button.add").trigger("click");

      expect(resetSpy).toHaveBeenCalledWith(menuItem);
    });
  });

  describe("#bindCheckoutEvents", function () {
    beforeEach(function () {
      loadFixtures('menu_item.html');
    });

    it("should add item to order", function () {
      var itemModifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Salt",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          modifier_prices_by_item_size_id: [
            {size_id: 1, modifier_price: "0"}
          ]
        })
      ];

      var item = new MenuItem({
        id: 1,
        name: "Lenny Kravitz Sandwich",
        description: "",
        modifier_groups: [
          new ModifierGroup({
            name: "Beer Can",
            modifier_items: [itemModifiers[0]]
          }),
          new ModifierGroup({
            name: "Bacon",
            modifier_items: [itemModifiers[0]]
          })
        ],
        size_prices: [
          {size_id: 1, price: "8.99", points: ""}
        ]
      });

      var dialog = new Dialog();
      var dialogSpy = spyOn(dialog, "addToOrder");

      MenuItemsController.bindCheckoutEvents(item, dialog);

      $("button.checkout").click();
      expect(dialogSpy).toHaveBeenCalledWith([item], null, true, true);
    });
  });

  describe("#__bindNestedModifierEvents", function () {
    pending("TODO");
  });

  describe("#updateModifierNetPriceText", function () {
    it("should add a decrease class when net price is negative", function () {
      var item = new MenuItem({
        id: "212013",
        name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/1x/212013.jpg",
        modifier_groups: [
          new ModifierGroup({
            name: "Meat",
            modifier_items: [
              new ModifierItem({
                modifier_item_id: 1,
                modifier_item_name: "Salt",
                modifier_item_max: 1,
                modifier_item_min: 0,
                modifier_item_pre_selected: false,
                quantity: 0,
                modifier_prices_by_item_size_id: [
                  { size_id: 1, modifier_price: "-1.00" }
                ]
              })
            ]
          })
        ],
        size_prices: [
          { size_id: 1, price: "1", enabled: true },
          { size_id: 2, price: "2", enabled: false }
        ],
        point_range: 90,
        notes: "Hold teh lettuce, please.",
        points_used: 0
      });

      MenuItemsController.show({ item: item });
      MenuItemsController.updateModifierNetPriceText(item);

      expect($("dt[data-id='1'] span.decrease").length).toBe(1);
    })
  });

  describe("#updateItemTotal", function () {
    var itemModifiers = [
      new ModifierItem({
        modifier_item_id: 1,
        modifier_item_name: "Salt",
        modifier_item_max: 1,
        modifier_item_min: 0,
        modifier_item_pre_selected: false,
        quantity: 0,
        modifier_prices_by_item_size_id: [
          {size_id: 1, modifier_price: "0"}
        ]
      })
    ];

    var item = new MenuItem({
      id: 1,
      name: "Lenny Kravitz Sandwich",
      description: "",
      modifier_groups: [
        new ModifierGroup({
          name: "Beer Can",
          modifier_items: [itemModifiers[0]]
        }),
        new ModifierGroup({
          name: "Bacon",
          modifier_items: [itemModifiers[0]]
        })
      ],
      size_prices: [{
        size_id: 1, price: "8.99", points: "", enabled: true
      }]
    });

    describe("edit true", function(){
      describe("item not redeemable in points", function () {
        it("updates the add item (points) button", function () {
          var textSpy = spyOn($.fn, "text");
          var hideSpy = spyOn($.fn, "hide");
          spyOn(MenuItemsController, "_itemRedeemableInPoints").and.returnValue(false);

          MenuItemsController.updateItemTotal(item, undefined, true);

          expect(hideSpy).toHaveBeenCalled();
          expect(textSpy).toHaveBeenCalledWith('Item not redeemable');

        });
      });

      describe("item redeemable in points", function () {
        it("updates the add item (points) button", function () {
          var showSpy = spyOn($.fn, "show");
          spyOn(MenuItemsController, "_itemRedeemableInPoints").and.returnValue(true);

          MenuItemsController.updateItemTotal(item, undefined, true);

          expect(showSpy).toHaveBeenCalled();
        });
      });

      describe("user exists, is loyal", function () {
        var true_item = new MenuItem({
          id: 1,
          name: "Lenny Kravitz Sandwich",
          description: "",
          modifier_groups: [
            new ModifierGroup({
              name: "Beer Can",
              modifier_items: [itemModifiers[0]]
            }),
            new ModifierGroup({
              name: "Bacon",
              modifier_items: [itemModifiers[0]]
            })
          ],
          size_prices: [
            { size_id: 1, price: "8.99", points: "100", enabled: true }
          ]
        });

        it("hide the add item (points) button if user has enough points", function () {
          spyOn(MenuItemsController, "_itemRedeemableInPoints").and.returnValue(true);
          var hideSpy = spyOn($.fn, "hide");
          MenuItemsController.updateItemTotal(true_item, new User({ points: 50 }), true);
          expect(hideSpy).toHaveBeenCalled();
        });
      });
    });

    describe("edit false", function() {
      it("updates the add item (cash) button", function() {
        var textSpy = spyOn($.fn, "text");
        MenuItemsController.updateItemTotal(item);
        expect(textSpy).toHaveBeenCalledWith('Add item - $8.99');
      });

      it("defaults the point button to the correct state", function () {
        var propSpy = spyOn($.fn, "prop");
        MenuItemsController.updateItemTotal(item, new User({ points: 1 }, false));
        expect(propSpy).toHaveBeenCalledWith('disabled', false);
      });

      describe("item not redeemable in points", function () {
        it("updates the add item (points) button", function () {
          var textSpy = spyOn($.fn, "text");
          MenuItemsController.updateItemTotal(item);
          expect(textSpy).toHaveBeenCalledWith('Item not redeemable');
        });
      });

      describe("user exists, is loyal, and has enough points", function () {
        var item = new MenuItem({
          id: 1,
          name: "Lenny Kravitz Sandwich",
          description: "",
          modifier_groups: [
            new ModifierGroup({
              name: "Beer Can",
              modifier_items: [itemModifiers[0]]
            }),
            new ModifierGroup({
              name: "Bacon",
              modifier_items: [itemModifiers[0]]
            })
          ],
          size_prices: [
            {size_id: 1, price: "8.99", points: "100", enabled: true}
          ]
        });

        it("enables the add item (points) button", function () {
          var propSpy = spyOn($.fn, "prop");
          MenuItemsController.updateItemTotal(item, new User({ points: 1000 }, false));
          expect(propSpy).toHaveBeenCalledWith('disabled', false);
        });
      });
    });
  });

  describe("#bindNestedModifierEvents", function () {
    pending("TODO");
  });

  describe("#_updateModifierQuantityText", function () {
    beforeEach(function () {
      loadFixtures('modifier_group_quantity_text.html');
    });

    var item = new MenuItem({
      id: 1,
      name: "Lenny Kravitz Sandwich",
      description: "",
      modifier_groups: [
        new ModifierGroup({
          name: "Beer Can",
          modifier_group_max_modifier_count: "3",
          modifier_group_min_modifier_count: "0",
          modifier_items: [
            new ModifierItem({
              quantity: 0,
              modifier_item_id: 1,
              modifier_item_name: "Salt",
              modifier_item_max: 3,
              modifier_item_min: 0,
              modifier_item_pre_selected: false,
              modifier_prices_by_item_size_id: [
                {size_id: 1, modifier_price: "0"}
              ]
            })
          ]
        })
      ],
      size_prices: [
        {size_id: 1, price: "8.99", points: "100"}
      ]
    });

    it("sets the modifier group text correctly with one modifier", function () {
      item.modifier_groups[0].modifier_items[0].quantity = 1;
      MenuItemsController._updateModifierQuantityText(item.modifier_groups[0]);
      expect($("p[data-modifier-group-id='10']").text()).toEqual("Choose up to 2 more");
    });

    it("sets the modifier group text correctly with two modifiers", function () {
      item.modifier_groups[0].modifier_items[0].quantity = 2;
      MenuItemsController._updateModifierQuantityText(item.modifier_groups[0]);
      expect($("p[data-modifier-group-id='10']").text()).toEqual("Choose up to 1 more");
    });

    it("sets the modifier group text correctly with three modifiers", function () {
      item.modifier_groups[0].modifier_items[0].quantity = 3;
      MenuItemsController._updateModifierQuantityText(item.modifier_groups[0]);
      expect($("p[data-modifier-group-id='10']").text()).toEqual("Maximum selected");
    });

    it("sets the modifier group text correctly with 1 modifier", function () {
      var modifier_group = item.modifier_groups[0];
      var modifier_item = modifier_group.modifier_items[0];
      modifier_group.modifier_group_max_modifier_count = 1;
      modifier_item.quantity = 1;
      MenuItemsController._updateModifierQuantityText(modifier_group);
      expect($("p[data-modifier-group-id='10']").text()).toEqual("Maximum selected");
    });
  });

  describe("#bindItemNoteEvent", function () {
    pending("TODO");
  });

  describe("#_editItemCallback", function () {
    pending("TODO");
  });

  describe("#_itemNotAdded", function () {
    describe("modifier added", function () {
      it("returns false", function () {
        expect(MenuItemsController._itemNotAdded(1)).toEqual(false);
      });
    });

    describe("modifier not added", function () {
      it("returns true", function () {
        new MenuItem({id: 1234});
        expect(MenuItemsController._itemNotAdded(0)).toEqual(true);
      });
    });
  });
});
