describe("ModifierGroup", function() {
  var modifiers = [
    new ModifierItem({
      modifier_item_id: 1,
      modifier_item_name: "Bender",
      modifier_item_max: 1,
      modifier_item_min: 0,
      modifier_item_pre_selected: false,
      quantity: 1,
      modifier_prices_by_item_size_id: [{ size_id: 1, modifier_price: "1.00" }]
    }),
    new ModifierItem({
      modifier_item_id: 1,
      modifier_item_name: "Fender",
      modifier_item_max: 1,
      modifier_item_min: 0,
      modifier_item_pre_selected: false,
      quantity: 1,
      modifier_prices_by_item_size_id: [{ size_id: 1, modifier_price: "2.00" }]
    })
  ];

  describe("#constructor", function() {
    it("initializes object correctly", function() {
      var modifierGroup = new ModifierGroup({
        modifier_group_display_name: "meat",
        modifier_items: modifiers,
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00
      });

      expect(modifierGroup.modifier_group_display_name).toEqual("meat");
      expect(modifierGroup.modifier_items).toEqual(modifiers);
      expect(modifierGroup.modifier_group_credit).toEqual(0.99);
      expect(modifierGroup.modifier_group_max_modifier_count).toEqual(4);
      expect(modifierGroup.modifier_group_min_modifier_count).toEqual(1);
      expect(modifierGroup.modifier_group_max_price).toEqual(4.00);
      expect(modifierGroup.remainingCredit).toEqual(0.99);

    });

    it("defaults minimum to 0", function() {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_credit: "0.99",
        modifier_group_max_modifier_count: 4,
        modifier_group_max_price: "4.00"
      });
      expect(modifierGroup.modifier_group_min_modifier_count).toEqual(0);
    });

    it("defaults remainingCredit to 0", function() {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: "4.00"
      });
      expect(modifierGroup.remainingCredit).toEqual(0);
    });

    it("should set modifier_group_type", function() {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: "4.00"
      });

      expect(modifierGroup.modifier_group_type).toBe("");

      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: "4.00",
        modifier_group_type: null
      });

      expect(modifierGroup.modifier_group_type).toBe("");

      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: "4.00",
        modifier_group_type: "I2"
      });

      expect(modifierGroup.modifier_group_type).toEqual("I2");
    });
  });

  describe("#isInterdependent", function() {
    it("should return true when it is interdependent", function() {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: "4.00",
        modifier_group_type: "I2"
      });

      expect(modifierGroup.isInterdependent()).toBeTruthy();
    });

    it("should return false when it is not interdependent", function() {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: "4.00",
        modifier_group_type: null
      });

      expect(modifierGroup.isInterdependent()).toBeFalsy();
    });
  });

  describe("#isQuantityGroup", function() {
    it("should return true when it is a quantity group", function() {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: "4.00",
        modifier_group_type: "Q"
      });

      expect(modifierGroup.isQuantityGroup()).toBeTruthy();
    });

    it("should return false when it is not quantity group", function() {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: "4.00",
        modifier_group_type: null
      });

      expect(modifierGroup.isQuantityGroup()).toBeFalsy();
    });
  });

  describe("resetQuantity", function() {
    var modifierGroup;

    beforeEach(function() {
      modifierGroup = new ModifierGroup({
        name: "Meat",
        modifier_items: modifiers,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: "4.00",
        modifier_group_type: null
      });
    });

    it("should call reset Quantity of all modifier items", function() {
      var resetQuantitySpy = spyOn(ModifierItem.prototype, "resetQuantity");

      $(modifierGroup.modifier_items).each(function(index, modifierItem) {
        modifierItem.quantity = 4;
      });

      modifierGroup.resetQuantity();

      expect(resetQuantitySpy).toHaveBeenCalled();
    });

    it("should reset to default quantity of all modifier items", function() {
      $(modifierGroup.modifier_items).each(function(index, modifierItem) {
        modifierItem.quantity = 4;
      });

      $(modifierGroup.modifier_items).each(function(index, modifierItem) {
        expect(modifierItem.quantity).toEqual(4);
      });

      modifierGroup.resetQuantity();

      $(modifierGroup.modifier_items).each(function(index, modifierItem) {
        expect(modifierItem.quantity).toEqual(1);
      });
    });
  });

  describe(".quantityText", function() {
    describe("#getQuantityText", function () {
      it("should return null if a group with neither min nor max is passed", function () {
        var group = new ModifierGroup({name: "Space Cabbage", modifier_items: []});
        expect(group.getQuantityText()).toBeNull();
      });

      it("should return null if a group with min and max = 0 is passed", function () {
        var group = new ModifierGroup({name: "Space Cabbage", modifier_items: [], modifier_group_max_modifier_count: 0, modifier_group_min_modifier_count: 0});
        expect(group.getQuantityText()).toBeNull();
      });

      it("should return the right message if a group with a max but no min is passed", function () {
        var group = new ModifierGroup({name: "Space Cabbage", modifier_items: [], modifier_group_max_modifier_count: 2});
        expect(group.getQuantityText()).toEqual("Choose up to 2 more");
      });

      it("should return the right message if a group with a max and a min = 0 is passed", function () {
        var group = new ModifierGroup({name: "Space Cabbage", modifier_items: [], modifier_group_max_modifier_count: 2, modifier_group_min_modifier_count: 0});
        expect(group.getQuantityText()).toEqual("Choose up to 2 more");
      });

      it("should return the right message if a group with a min but no max is passed", function () {
        var group = new ModifierGroup({name: "Space Cabbage", modifier_items: [], modifier_group_min_modifier_count: 2});
        expect(group.getQuantityText()).toEqual("Choose 2 more");
      });

      it("should return the right message if a group with a min but and a max = 0 is passed", function () {
        var group = new ModifierGroup({
          name: "Space Cabbage",
          modifier_items: [
            new ModifierItem({
              quantity: 1
            }),
            new ModifierItem({
              quantity: 1
            })
          ],
          modifier_group_max_modifier_count: 0,
          modifier_group_min_modifier_count: 1
        });

        expect(group.getQuantityText()).toEqual("Choose 1");
      });

      it("should return the right message if a group with both a min and a max is passed", function () {
        var group = new ModifierGroup({
          name: "Space Cabbage",
          modifier_items: [
            new ModifierItem({
              quantity: 0
            }),
            new ModifierItem({
              quantity: 0
            })
          ],
          modifier_group_max_modifier_count: 3,
          modifier_group_min_modifier_count: 2
        });
        expect(group.getQuantityText()).toEqual("Choose 2 to 3 more");
      });

      it("should return the right message if a group with identical min and max is passed", function () {
        var group = new ModifierGroup({
          name: "Space Cabbage",
          modifier_items: [],
          modifier_group_max_modifier_count: 3, modifier_group_min_modifier_count: 3
        });
        expect(group.getQuantityText()).toEqual("Choose 3 more");
      });
    });
  });

  describe(".quantity", function() {
    it("returns the total number of defaults in a modifier group", function() {

      var modifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Bender",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: true,
          quantity: 1,
          size_prices: [{size_id: 1, modifier_price: "1.00"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Fender",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: true,
          quantity: 1,
          size_prices: [{size_id: 1, modifier_price: "2.00"}]
        })
      ];


      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00
      });

      expect(modifierGroup.quantity()).toEqual(2);

    });

    it("returns the total number of defaults in a modifier group", function() {

      var modifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Bender",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: true,
          quantity: 1,
          size_prices: [{size_id: 1, modifier_price: "1.00"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Fender",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          size_prices: [{size_id: 1, modifier_price: "2.00"}]
        })
      ];


      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00
      });

      expect(modifierGroup.quantity()).toEqual(1);

    });

    it("does not automatically preselect items to reach the minimum", function() {

      var modifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Benderzzz",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          size_prices: [{size_id: 1, modifier_price: "1.00"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Fender",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          size_prices: [{size_id: 1, modifier_price: "2.00"}]
        })
      ];

      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00
      });

      expect(modifierGroup.quantity()).toEqual(0);

    });
  });

  describe("#remainingModifiers", function () {
    it("returns the correct remaining number of modifiers", function () {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: [
          new ModifierItem({
            modifier_item_id: 1,
            modifier_item_name: "Bender",
            modifier_item_max: 1,
            modifier_item_min: 0,
            modifier_item_pre_selected: true,
            size_prices: [{size_id: 1, modifier_price: "1.00"}],
            quantity: 1
          }),
          new ModifierItem({
            modifier_item_id: 2,
            modifier_item_name: "Fender",
            modifier_item_max: 1,
            modifier_item_min: 0,
            modifier_item_pre_selected: true,
            size_prices: [{size_id: 1, modifier_price: "1.00"}],
            quantity: 1
          })
        ],
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00
      });

      expect(modifierGroup.remainingModifiers()).toEqual(2);

    });
  });

  describe("#atModifierMax", function () {
    pending("TODO");
  });

  describe("#aboveGroupModifierMin", function () {
    it("returns true if >= group modifier minimum", function () {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00
      });

      expect(modifierGroup.aboveGroupModifierMin()).toEqual(true);
    });

    it("returns false if < group modifier minimum", function () {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 2,
        modifier_group_max_price: 4.00
      });

      expect(modifierGroup.aboveGroupModifierMin()).toEqual(false);
    });
  });

  describe("#belowModifierGroupMax", function () {
    it("returns true if <= group modifier maximum", function () {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00
      });

      expect(modifierGroup.belowModifierGroupMax()).toEqual(true);
    });

    it("returns false if > group modifier minimum", function () {
      var modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 1,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00
      });

      expect(modifierGroup.belowModifierGroupMax()).toEqual(false);
    });
  });

  describe("#quantity", function () {
    pending("TODO");
  });

  describe("#allModifiers", function () {
    pending("TODO");
  });
  
  describe("#isValid", function () {
    var modifierGroup = new ModifierGroup({
      name: "meat",
      modifier_items: modifiers,
      modifier_group_credit: 0.99,
      modifier_group_max_modifier_count: 4,
      modifier_group_min_modifier_count: 1,
      modifier_group_max_price: 4.00
    });
    
    it("returns false if < modifier group modifier minimum", function () {
      modifiers[0].quantity = 0;
      modifiers[1].quantity = 0;
      expect(modifierGroup.isValid()).toEqual(false);
    });
    
    it("returns true if at modifier group minimum", function () {
      modifiers[1].quantity = 1;
      expect(modifierGroup.isValid()).toEqual(true);
    });
    
    it("returns true if at modifier group maximum", function () {
      modifiers[0].quantity = 3;
      expect(modifierGroup.isValid()).toEqual(true);
    });

    it("return false if above modifier group maximum", function () {
      modifiers[1].quantity = 2;
      expect(modifierGroup.isValid()).toEqual(false);
    });
    
    it("returns false if below modifier group minimum", function () {
      modifiers[0].quantity = 0;
      modifiers[1].quantity = 0;
      expect(modifierGroup.isValid()).toEqual(false);
    });
  });

  describe("#totalPrice", function() {
    var modifierGroup;

    beforeEach(function() {
      // Change quantity to increase totalPrice
      $.each(modifiers, function(index, modifier) {
        modifier.quantity = 2;
      });

      modifierGroup = new ModifierGroup({
        name: "meat",
        modifier_items: modifiers,
        modifier_group_credit: 0,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 999.00
      });
    });

    it("should return all modifiers accumulated price", function() {
      expect(modifierGroup.totalPrice()).toEqual(6);
    });

    it("should return modifiers accumulated price without presel price", function() {
      modifiers[0].modifier_item_pre_selected = true;
      expect(modifierGroup.totalPrice()).toEqual(5);
    });

    it("should return all modifiers accumulated price reduced by group credit when it's greater than 0", function() {
      modifierGroup.modifier_group_credit = 1;
      expect(modifierGroup.totalPrice()).toEqual(5);
    });

    it("should return max price when it is greater than accumulated price", function() {
      modifierGroup.modifier_group_max_price = 2;
      expect(modifierGroup.totalPrice()).toEqual(2);
    });

    it("should return all modifiers accumulated price without undefined item's price", function() {
      modifiers[0].basePrice = undefined;
      expect(modifierGroup.totalPrice()).toEqual(4);
    });

    describe("#negative amount modifier", function() {
      var modifier;

      beforeEach(function() {
        modifier = new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Negative",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 1,
          modifier_prices_by_item_size_id: [{ size_id: 1, modifier_price: "-1.00" }]
        });

        modifierGroup.modifier_items.push(modifier);
      });

      it("should calculate total with negative amounts", function () {
        expect(modifierGroup.totalPrice()).toEqual(3);

        modifierGroup.modifier_items.pop();

        expect(modifierGroup.totalPrice()).toEqual(4);
      });

      it("should calculate total with negative amounts and credit", function () {
        modifierGroup.modifier_group_credit = 1.00;

        expect(modifierGroup.totalPrice()).toEqual(2);

        modifierGroup.modifier_items.pop();

        expect(modifierGroup.totalPrice()).toEqual(3);
      });
    });
  });
});
