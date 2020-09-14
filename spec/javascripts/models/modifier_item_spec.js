describe("ModifierItem", function () {
  "use strict";

  describe("#constructor", function () {
    describe(".modifier_item_id", function () {
      it("should initialize with 'id' correctly", function () {
        var modifier = new ModifierItem({modifier_item_id: 1234});
        expect(modifier.modifier_item_id).toEqual(1234);
      });

      it("should initialize 'modifier_item_id' correctly", function () {
        var modifier = new ModifierItem({modifier_item_id: 1234});
        expect(modifier.modifier_item_id).toEqual(1234);
      });
    });

    describe(".modifier_item_name", function () {
      it("should initialize with 'name' correctly", function () {
        var modifier = new ModifierItem({modifier_item_name: "Drinks=Sprite"});
        expect(modifier.modifier_item_name).toEqual("Drinks, Sprite");
      });

      it("should initialize with 'modifier_item_name' correctly", function () {
        var modifier = new ModifierItem({modifier_item_name: "Drinks=Sprite"});
        expect(modifier.modifier_item_name).toEqual("Drinks, Sprite");
      });
    });

    describe(".max", function () {
      it("should initialize with modifier_item_max correctly", function () {
        var modifier = new ModifierItem({modifier_item_max: 2});
        expect(modifier.modifier_item_max).toEqual(2);
      });

      it("should initialize with max correctly", function () {
        var modifier = new ModifierItem({modifier_item_max: 2});
        expect(modifier.modifier_item_max).toEqual(2);
      });
    });

    describe(".modifier_item_min", function () {
      it("should initialize with modifier_item_min correctly", function () {
        var modifier = new ModifierItem({modifier_item_min: 0});
        expect(modifier.modifier_item_min).toEqual(0);
      });

      it("should initialize with min correctly", function () {
        var modifier = new ModifierItem({modifier_item_min: 0});
        expect(modifier.modifier_item_min).toEqual(0);
      });
    });

    describe(".modifier_item_pre_selected", function () {
      it("should initialize correctly", function () {
        var modifier = new ModifierItem({modifier_item_pre_selected: 'true'});
        expect(modifier.modifier_item_pre_selected).toEqual(true);
      });

      it("should initialize correctly", function () {
        var modifier = new ModifierItem({modifier_item_pre_selected: 'false'});
        expect(modifier.modifier_item_pre_selected).toEqual(false);
      });

      it("should initialize correctly", function () {
        var modifier = new ModifierItem({modifier_item_pre_selected: true});
        expect(modifier.modifier_item_pre_selected).toEqual(true);
      });

      it("should initialize correctly", function () {
        var modifier = new ModifierItem({modifier_item_pre_selected: false});
        expect(modifier.modifier_item_pre_selected).toEqual(false);
      });

      it("should initialize correctly", function () {
        var modifier = new ModifierItem({modifier_item_pre_selected: 'true'});
        expect(modifier.modifier_item_pre_selected).toEqual(true);
      });

      it("should initialize correctly", function () {
        var modifier = new ModifierItem({modifier_item_pre_selected: 'false'});
        expect(modifier.modifier_item_pre_selected).toEqual(false);
      });

      it("should initialize correctly", function () {
        var modifier = new ModifierItem({modifier_item_pre_selected: true});
        expect(modifier.modifier_item_pre_selected).toEqual(true);
      });

      it("should initialize correctly", function () {
        var modifier = new ModifierItem({modifier_item_pre_selected: false});
        expect(modifier.modifier_item_pre_selected).toEqual(false);
      });
    });

    describe(".modifier_prices_by_item_size_id", function () {
      it("should initialize with modifier_prices_by_item_size_id correctly", function () {
        var modifier = new ModifierItem({modifier_prices_by_item_size_id: [
          {size_id: 1},
          {size_id: 2}
        ]});

        expect(modifier.modifier_prices_by_item_size_id).toEqual([
          {size_id: 1},
          {size_id: 2}
        ]);
      });

      it("should initialize with modifier_prices_by_item_size_id correctly", function () {
        var modifier = new ModifierItem({modifier_prices_by_item_size_id: [
          {size_id: 1},
          {size_id: 2}
        ]});

        expect(modifier.modifier_prices_by_item_size_id).toEqual([
          {size_id: 1},
          {size_id: 2}
        ]);
      });
    });

    describe(".basePrice", function () {
      it("initializes the basePrice attribute", function () {
        var modifier = new ModifierItem({modifier_item_id: 1, modifier_prices_by_item_size_id: [
          {size_id: 1, modifier_price: "1.50"}
        ]});

        expect(modifier.basePrice).toEqual("1.50");
      });

      it("initializes the basePrice default attribute", function () {
        var modifier = new ModifierItem({modifier_item_id: 2});
        expect(modifier.basePrice).toEqual("0.00");
      });
    });

    describe(".netPrice", function () {
      it("should initialize correctly", function () {
        var modifier = new ModifierItem({modifier_item_id: 3});
        expect(modifier.netPrice).toEqual("0.00");
      });
    });

    describe(".quantity", function () {
      it("returns quantity if quantity present", function () {
        var modifier = new ModifierItem({modifier_item_id: 2, quantity: 6});
        expect(modifier.quantity).toEqual(6);
      });

      it("returns quantity if quantity present [string]", function () {
        var modifier = new ModifierItem({modifier_item_id: 2, quantity: "6"});
        expect(modifier.quantity).toEqual(6);
      });

      it("returns 1 if modifier is pre-selected", function () {
        var modifier = new ModifierItem({
          modifier_item_id: 2,
          modifier_item_max: 1,
          modifier_item_pre_selected: true,
          quantity: 1
        });
        expect(modifier.quantity).toEqual(1);
      });

      it("returns 0 if modifier isn't pre-selected", function () {
        var modifier = new ModifierItem({
          modifier_item_id: 2,
          modifier_item_max: 1,
          modifier_item_pre_selected: false,
          quantity: 0
        });
        expect(modifier.quantity).toEqual(0);
      });
    });

    describe(".defaultQuantity", function() {
      it("returns quantity if quantity present", function () {
        var modifier = new ModifierItem({ modifier_item_id: 2, quantity: 6 });
        expect(modifier.defaultQuantity).toEqual(6);
      });

      it("returns quantity if quantity present [string]", function () {
        var modifier = new ModifierItem({ modifier_item_id: 2, quantity: "6" });
        expect(modifier.defaultQuantity).toEqual(6);
      });

      it("returns 1 if modifier is pre-selected", function () {
        var modifier = new ModifierItem({
          modifier_item_id: 2,
          modifier_item_max: 1,
          modifier_item_pre_selected: true,
          quantity: 1
        });
        expect(modifier.defaultQuantity).toEqual(1);
      });

      it("returns 0 if modifier isn't pre-selected", function () {
        var modifier = new ModifierItem({
          modifier_item_id: 2,
          modifier_item_max: 1,
          modifier_item_pre_selected: false,
          quantity: 0
        });
        expect(modifier.defaultQuantity).toEqual(0);
      });

      it("is not modified when quantity does", function() {
        var modifier = new ModifierItem({
          modifier_item_id: 1,
          modifier_item_max: 2,
          modifier_item_preselected: false,
          quantity: 0
        });
        modifier.quantiy = 3;
        expect(modifier.defaultQuantity).toEqual(0);
      });
    });

    describe(".exclusive", function () {
      it("should initialize correctly", function () {
        pending("TODO");
      });
    });

    describe(".nestedItems", function () {
      it("should initialize correctly", function () {
        pending("TODO");
      });
    });

    it("doesn't blow up w/o params", function () {
      expect(function () {
        new ModifierItem()
      }).not.toThrow();
    });
  });

  describe("#sizePrice", function () {
    pending("TODO");
  });

  describe("#resetQuantity", function() {
    it("should reset quantity to default quantity", function() {
      var modifierItem = new ModifierItem({
        modifier_item_id: 2,
        modifier_item_max: 1,
        modifier_item_pre_selected: true,
        quantity: 1
      });
      modifierItem.quantity = 5;
      modifierItem.resetQuantity();
      expect(modifierItem.quantity).toEqual(1);
    });
  });

  describe("#hasNestedPrices", function() {
    var modifierItem;

    beforeEach(function () {
      modifierItem = new ModifierItem({
        modifier_item_name: "Father",
        modifier_item_id: 2,
        modifier_item_max: 1,
        modifier_item_pre_selected: true,
        quantity: 1,
        nestedItems: [{
          modifier_item_name: "test",
          modifier_item_id: 2,
          modifier_item_max: 1,
          modifier_item_pre_selected: true,
          quantity: 1,
          modifier_prices_by_item_size_id: [{
            modifier_price: "0.00",
            size_id: "1"
          }]
        },{
          modifier_item_name: "test2",
          modifier_item_id: 2,
          modifier_item_max: 1,
          modifier_item_pre_selected: true,
          quantity: 1,
          modifier_prices_by_item_size_id: [{
            modifier_price: "1.00",
            size_id: "2"
          }]
        }]
      });
    });

    it("should return true if any of nested modifiers has a price", function () {
      expect(modifierItem.hasNestedPrices("1")).toBeTruthy();
    });

    it("should return false if none of its nested modifiers has a price", function () {
      expect(modifierItem.hasNestedPrices("100")).toBeFalsy();
    });
  });

  describe("#hasAnAvailablePrice", function() {
    var modifierItem;

    describe("#modifier without nested items", function() {
      beforeEach(function () {
        modifierItem = new ModifierItem({
          modifier_item_name: "Father",
          modifier_item_id: 2,
          modifier_item_max: 1,
          modifier_item_pre_selected: true,
          quantity: 1,
          modifier_prices_by_item_size_id: [{
            modifier_price: "0.00",
            size_id: "1"
          }]
        });


      });

      it("should return true if it has a base price", function () {
        modifierItem.basePrice = modifierItem.sizePrice("1");

        expect(modifierItem.hasAnAvailablePrice("1")).toBeTruthy();
      });

      it("should return false if it doesn't have a base price", function () {
        modifierItem.basePrice = modifierItem.sizePrice("100");

        expect(modifierItem.hasAnAvailablePrice("100")).toBeFalsy();
      });
    });

    describe("#modifier with nested items", function() {
      beforeEach(function () {
        modifierItem = new ModifierItem({
          modifier_item_name: "Father",
          modifier_item_id: 2,
          modifier_item_max: 1,
          modifier_item_pre_selected: true,
          quantity: 1,
          nestedItems: [{
            modifier_item_name: "test",
            modifier_item_id: 2,
            modifier_item_max: 1,
            modifier_item_pre_selected: true,
            quantity: 1,
            modifier_prices_by_item_size_id: [{
              modifier_price: "0.00",
              size_id: "1"
            }]
          }, {
            modifier_item_name: "test2",
            modifier_item_id: 2,
            modifier_item_max: 1,
            modifier_item_pre_selected: true,
            quantity: 1,
            modifier_prices_by_item_size_id: [{
              modifier_price: "1.00",
              size_id: "2"
            }]
          }]
        });
      });

      it("should return true if any of nested modifiers has a price", function () {
        expect(modifierItem.hasAnAvailablePrice("1")).toBeTruthy();
      });

      it("should return false if none of its nested modifiers has a price", function () {
        expect(modifierItem.hasAnAvailablePrice("100")).toBeFalsy();
      });
    });
  });

  describe("#costsExtra", function () {
    it("returns true if modifier price > 0.00", function () {
      var modifier = new ModifierItem({modifier_prices_by_item_size_id: [
        {size_id: 1, modifier_price: "1.00"}
      ]});
      expect(modifier.costsExtra()).toEqual(true);
    });

    it("returns false if modifier price <= 0.00", function () {
      var modifier = new ModifierItem({});
      expect(modifier.costsExtra()).toEqual(false);
    });
  });

  describe("#oneMax", function () {
    it("returns true if there is one max", function () {
      var modifier = new ModifierItem({ modifier_item_max: 1 });
      expect(modifier.oneMax()).toEqual(true)
    });

    it("returns false if there isn't one max", function () {
      var modifier = new ModifierItem({ modifier_item_max: 2 });
      expect(modifier.oneMax()).toEqual(false)
    });
  });

  describe("#nineMax", function () {
    it("returns true if there is nine max", function () {
      var modifier = new ModifierItem({ modifier_item_max: 9 });
      expect(modifier.nineMax()).toBeTruthy();
    });

    it("returns false if there is one max", function () {
      var modifier = new ModifierItem({ modifier_item_max: 1 });
      expect(modifier.nineMax()).toBeFalsy();
    });

    it("returns false if there isn't nine max", function () {
      var modifier = new ModifierItem({ modifier_item_max: 10 });
      expect(modifier.nineMax()).toBeFalsy();
    });
  });
});
