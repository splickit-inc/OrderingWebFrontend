describe("MenuItem", function() {
  var modGroups =[
    new ModifierGroup({
      modifier_group_display_name: "Meat",
      modifier_items: [new ModifierItem({
        modifier_item_id: 1,
        modifier_item_name: "Pork",
        modifier_item_max: 1,
        modifier_item_min: 0,
        modifier_item_pre_selected: false,
        quantity: 2,
        modifier_prices_by_item_size_id: [{ size_id: 1, modifier_price: "1.00" }]
      })]
    }),
    new ModifierGroup({ modifier_group_display_name: "Cheese" })
  ]


  describe("#new", function() {
    it("initializes with the correct attributes", function() {
      var menuItem = new MenuItem({
        item_id: "212013",
        item_name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/2x/212013.jpg",
        modifier_groups: modGroups,
        size_prices: [{ size_id: 1 }, { size_id: 2 }],
        point_range: 90,
        notes:"Hold teh lettuce, please.",
        note:"Hold teh lettuce, please."
      });

      expect(menuItem.item_id).toEqual(212013);
      expect(menuItem.item_name).toEqual("Black Forest Ham");
      expect(menuItem.description).toEqual("Black Forest Ham, Shredded Lettuce, Tomatoes");
      expect(menuItem.large_image).toEqual("https://image.com/large/2x/212013.jpg");
      expect(menuItem.small_image).toEqual("https://image.com/small/2x/212013.jpg");
      expect(menuItem.modifier_groups[0]).toEqual(jasmine.objectContaining({modifier_group_display_name: "Meat"}));
      expect(menuItem.modifier_groups[1]).toEqual(jasmine.objectContaining({modifier_group_display_name: "Cheese"}));
      expect(menuItem.size_prices).toEqual([new SizePrice({size_id: 1}), new SizePrice({size_id: 2})]);
      expect(menuItem.point_range).toEqual(90);
      expect(menuItem.note).toEqual("Hold teh lettuce, please.");
      expect(menuItem.notesLength).toEqual(75);
    });

    it("initializes with the correct attributes for cart added items", function() {
      var menuItem = new MenuItem({
        item_id: "212013",
        item_name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/2x/212013.jpg",
        modifier_groups: modGroups,
        size_prices: [{size_id: 1}, {size_id: 2}],
        point_range: 90,
        notes:"Hold teh lettuce, please.",
        note:"Hold teh lettuce, please.",
        points_used: "1200"
      });

      expect(menuItem.item_id).toEqual(212013);
      expect(menuItem.item_name).toEqual("Black Forest Ham");
      expect(menuItem.description).toEqual("Black Forest Ham, Shredded Lettuce, Tomatoes");
      expect(menuItem.large_image).toEqual("https://image.com/large/2x/212013.jpg");
      expect(menuItem.small_image).toEqual("https://image.com/small/2x/212013.jpg");
      expect(menuItem.modifier_groups[0]).toEqual(jasmine.objectContaining({modifier_group_display_name: "Meat"}));
      expect(menuItem.modifier_groups[1]).toEqual(jasmine.objectContaining({modifier_group_display_name: "Cheese"}));
      expect(menuItem.size_prices).toEqual([new SizePrice({size_id: 1}), new SizePrice({size_id: 2})]);
      expect(menuItem.point_range).toEqual(90);
      expect(menuItem.note).toEqual("Hold teh lettuce, please.");
      expect(menuItem.notesLength).toEqual(75);
      expect(menuItem.points_used).toEqual(1200);
    });

    it("sets noteLength default to 100 characters", function() {
      var menuItem = new MenuItem({id: "1234"});
      expect(menuItem.notesLength).toEqual(100);
    });

    it("defaults item size to first sizePrice", function() {
      var menuItem = new MenuItem({
        id: 1,
        size_prices: [{size_id: 1, size_name: "large", enabled: true}, {size_id: 2, size_name: "small", enabled: false}]
      });
      expect(menuItem.size).toEqual(new SizePrice({size_id: 1, size_name: "large", enabled: true}));
    });

    it("recalculates modifier prices", function() {
      var recalcModifierPricesSpy = spyOn(MenuItem.prototype, "calculateModifiers");
      new MenuItem({id: 1});
      expect(recalcModifierPricesSpy).toHaveBeenCalled();
    });

    it("doesn't blow up w/o params", function() {
      expect(function() {
        new MenuItem()
      }).not.toThrow();
    });
  });

  describe("hasModifiers", function() {
    it("should return true when it has modifiers", function() {
      var menuItem = new MenuItem({
        item_id: "212013",
        item_name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/2x/212013.jpg",
        modifier_groups: modGroups,
        size_prices: [{size_id: 1}, {size_id: 2}],
        point_range: 90,
        notes: "Hold teh lettuce, please."
      });

      expect(menuItem.hasModifiers()).toBeTruthy();
    });

    describe("#resetQuantity", function() {
      var menuItem;
      var modifierItems;
      beforeEach(function() {
        modifierItems = [
          new ModifierItem({
            quantity: 1
          }),
          new ModifierItem({
            quantity: 2
          }),
          new ModifierItem({
            quantity: 3
          }),
          new ModifierItem({
            quantity: 4
          })
        ];

        menuItem = new MenuItem({
          id: 1,
          name: "Sarah Paulson Sandwich",
          large_image: "https://www.placehold.it/600x400",
          small_image: "https://www.placehold.it/133x100",
          modifier_groups: [
          new ModifierGroup({
            modifier_group_display_name: "Meat",
            modifier_items: [modifierItems[0], modifierItems[1]],
            modifier_group_max_modifier_count: 4,
            modifier_group_min_modifier_count: 1,
            modifier_group_max_price: "4.00",
            modifier_group_type: null
          }),
          new ModifierGroup({
            modifier_group_display_name: "Cheese",
            modifier_items: [modifierItems[2], modifierItems[3]],
            modifier_group_max_modifier_count: 4,
            modifier_group_min_modifier_count: 1,
            modifier_group_max_price: "4.00",
            modifier_group_type: null })
          ]
        });
      });

      it("should call reset Quantity of all modifier items", function() {
        var resetQuantitySpy = spyOn(ModifierItem.prototype, "resetQuantity");

        $(menuItem.allModifiers()).each(function(index, modifierItem) {
          modifierItem.quantity = 4;
        });

        menuItem.resetQuantity();

        expect(resetQuantitySpy).toHaveBeenCalled();
      });

      it("should reset to default quantity of all modifier items", function() {
        $(menuItem.allModifiers()).each(function(index, modifierItem) {
          modifierItem.quantity = 4;
        });

        $(menuItem.allModifiers()).each(function(index, modifierItem) {
          expect(modifierItem.quantity).toEqual(4);
        });

        menuItem.resetQuantity();

        $(menuItem.allModifiers()).each(function(index, modifierItem) {
          expect(modifierItem.quantity).toEqual(modifierItems[index].quantity);
        });
      });
    });

    it("should return false when it doesn't have modifiers", function() {
      var menuItem =  new MenuItem({
        item_id: "212013",
        item_name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/2x/212013.jpg",
        modifier_groups: [],
        size_prices: [{size_id: 1}, {size_id: 2}],
        point_range: 90,
        notes: "Hold teh lettuce, please."
      });

      expect(menuItem.hasModifiers()).toBeFalsy();
    });

    it("should return false when it doesn't have modifiers", function() {
      var menuItem =  new MenuItem({
        item_id: "212013",
        item_name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/2x/212013.jpg",
        size_prices: [{size_id: 1}, {size_id: 2}],
        point_range: 90,
        notes: "Hold teh lettuce, please."
      });

      expect(menuItem.hasModifiers()).toBeFalsy();
    });
  });

  describe("point_used", function(){
    it("should assign points_used", function(){
      var menuItem = new MenuItem({ points_used: "1" });
      expect(menuItem.points_used).toEqual(1);
    });

    it("should assign 0 points_used when is nonummeric", function(){
      var menuItem = new MenuItem({ points_used: "" });
      expect(menuItem.points_used).toEqual(0);

      menuItem = new MenuItem({ points_used: "n" });
      expect(menuItem.points_used).toEqual(0);

      menuItem = new MenuItem({ points_used: "n1.2a" });
      expect(menuItem.points_used).toEqual(0);

      menuItem = new MenuItem({ points_used: true });
      expect(menuItem.points_used).toEqual(0);

      menuItem = new MenuItem({ points_used: false });
      expect(menuItem.points_used).toEqual(0);

      menuItem = new MenuItem({ points_used: undefined });
      expect(menuItem.points_used).toEqual(0);

      menuItem = new MenuItem({ points_used: {} });
      expect(menuItem.points_used).toEqual(0);

      menuItem = new MenuItem({ points_used: [] });
      expect(menuItem.points_used).toEqual(0);
    });
  });

  describe("#oneSize", function() {
    it("returns true if item has one size", function() {
      var menuItem = new MenuItem({id: 1, size_prices: [{enabled: true}]});
      expect(menuItem.oneSize()).toBe(true);
    });

    it("returns false if item has more than one size", function() {
      var menuItem = new MenuItem({id: 1, size_prices: [{enabled: true}, {enabled: false}]});
      expect(menuItem.oneSize()).toBe(false);
    });


    it("returns nothing if item has no size", function() {
      var menuItem = new MenuItem();
      expect(menuItem.oneSize()).toBe(undefined);
    });
  });

  describe("#sizePrice", function() {
    it("returns the sizePrice", function() {
      var menuItem = new MenuItem({id: 1, size_prices: [{size_id: 1, size_name: "Small Pita"}, {size_id: 2, size_name: "Large Pita"}]});
      expect(menuItem.sizePrice(1)).toEqual(new SizePrice({size_id: 1, size_name: "Small Pita"}));
    });
  });

  describe("#redeemable", function() {
    it("returns true if the item is redeemable", function() {
      var menuItem = new MenuItem({id: 1, point_range: [90]});
      expect(menuItem.redeemable()).toEqual(true);
    });

    it("returns true if the item is redeemable with multiple point values", function() {
      var menuItem = new MenuItem({id: 1, point_range: [90, 110, 130]});
      expect(menuItem.redeemable()).toEqual(true);
    });


    it("returns false if the item has empty point_range", function() {
      var menuItem = new MenuItem({id: 1, point_range: []});
      expect(menuItem.redeemable()).toEqual(false);
    });

    it("returns false if the item has no point_range", function() {
      var menuItem = new MenuItem({id: 1});
      expect(menuItem.redeemable()).toEqual(false);
    });
  });

  describe("#modifiers", function() {
    it("returns all modifiers for an MenuItem", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 11, modifier_item_name: "Ham"}),
              new ModifierItem({modifier_item_id: 12, modifier_item_name: "Ram"}),
            ]
          }),
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 21, modifier_item_name: "Bam"}),
              new ModifierItem({modifier_item_id: 22, modifier_item_name: "Sam"}),
            ]
          })
        ]
      });

      expect(menuItem.modifier_items()).toEqual([
        jasmine.objectContaining({modifier_item_id: 11, modifier_item_name: "Ham"}),
        jasmine.objectContaining({modifier_item_id: 12, modifier_item_name: "Ram"}),
        jasmine.objectContaining({modifier_item_id: 21, modifier_item_name: "Bam"}),
        jasmine.objectContaining({modifier_item_id: 22, modifier_item_name: "Sam"}),
      ])
    });
  });

  describe("#selectedNestedModifiers", function() {
    it("returns nothing if no modifier is include", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 11, modifier_item_name: "Ham"}),
              new ModifierItem({modifier_item_id: 12, modifier_item_name: "Ram"}),
            ]
          }),
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 21, modifier_item_name: "Bam"}),
              new ModifierItem({modifier_item_id: 22, modifier_item_name: "Sam"}),
            ]
          })
        ]
      });

      expect(menuItem.selectedNestedModifiers()).toEqual(void(0));
    });

    it("returns an empty list if no modifiers enabled", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          {
            modifier_items: [
              {
                modifier_item_id: 12,
                modifier_item_name: "Ram",
                nestedItems: [
                  {
                    modifier_item_id: 13,
                    modifier_item_name: "nested-ram",
                    quantity: 0
                  }
                ]
              }
            ]
          }
        ]
      });

      expect(menuItem.selectedNestedModifiers(12)).toEqual([]);
    });

    it("returns a list of enabled modifiers if enabled", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          {
            modifier_items: [
              {
                modifier_item_id: 12,
                modifier_item_name: "Ram",
                nestedItems: [{
                  modifier_item_id: 13,
                  modifier_item_name: 'nested-ram',
                  quantity: 1
                }]
              }
            ]
          }
        ]
      });

      expect(menuItem.selectedNestedModifiers(12)[0].modifier_item_id).toEqual(13);
      expect(menuItem.selectedNestedModifiers(12)[0].modifier_item_name).toEqual('nested-ram');
      expect(menuItem.selectedNestedModifiers(12)[0].quantity).toEqual(1);
    });
  });

  describe("#nestedItemString", function() {
    it("returns a formatted string composed of the nested item names", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          {
            modifier_items: [
              {
                modifier_item_id: 12,
                modifier_item_name: "Ram",
                nestedItems: [
                  {
                    modifier_item_id: 13,
                    modifier_item_name: 'chocolate fudge',
                    quantity: 1
                  },
                  {
                    modifier_item_id: 14,
                    modifier_item_name: 'candy sauce',
                    quantity: 1
                  }
                ]
              }
            ]
          }
        ]
      });

      expect(menuItem.nestedItemString(12)).toEqual('chocolate fudge, candy sauce');

    });
  });

  describe("#findModifiers", function() {
    it("returns the modifier matching the modifierID (number)", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 11, modifier_item_name: "Ham"}),
              new ModifierItem({modifier_item_id: 12, modifier_item_name: "Ram"}),
            ]
          }),
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 21, modifier_item_name: "Bam"}),
              new ModifierItem({modifier_item_id: 22, modifier_item_name: "Sam"}),
            ]
          })
        ]
      });

      expect(menuItem.findModifier(11)).toEqual(jasmine.objectContaining({modifier_item_name: "Ham"}));
      expect(menuItem.findModifier(12)).toEqual(jasmine.objectContaining({modifier_item_name: "Ram"}));
      expect(menuItem.findModifier(21)).toEqual(jasmine.objectContaining({modifier_item_name: "Bam"}));
      expect(menuItem.findModifier(22)).toEqual(jasmine.objectContaining({modifier_item_name: "Sam"}));
    });

    it("returns the modifier matching the modifierID (string)", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 11, modifier_item_name: "Ham"}),
              new ModifierItem({modifier_item_id: 12, modifier_item_name: "Ram"}),
            ]
          }),
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 21, modifier_item_name: "Bam"}),
              new ModifierItem({modifier_item_id: 22, modifier_item_name: "Sam"}),
            ]
          })
        ]
      });

      expect(menuItem.findModifier("11")).toEqual(jasmine.objectContaining({modifier_item_name: "Ham"}));
      expect(menuItem.findModifier("12")).toEqual(jasmine.objectContaining({modifier_item_name: "Ram"}));
      expect(menuItem.findModifier("21")).toEqual(jasmine.objectContaining({modifier_item_name: "Bam"}));
      expect(menuItem.findModifier("22")).toEqual(jasmine.objectContaining({modifier_item_name: "Sam"}));
    });

    it("returns undefined when no modifierID is specified (blank)", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 11, modifier_item_name: "Ham"}),
              new ModifierItem({modifier_item_id: 12, modifier_item_name: "Ram"}),
            ]
          }),
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 21, modifier_item_name: "Bam"}),
              new ModifierItem({modifier_item_id: 22, modifier_item_name: "Sam"}),
            ]
          })
        ]
      });

      expect(menuItem.findModifier()).toBeUndefined();
      expect(menuItem.findModifier()).toBeUndefined();
      expect(menuItem.findModifier()).toBeUndefined();
      expect(menuItem.findModifier()).toBeUndefined();
    });

    it("returns nothing when no modifierID is specified (empty string)", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 11, modifier_item_name: "Ham"}),
              new ModifierItem({modifier_item_id: 12, modifier_item_name: "Ram"}),
            ]
          }),
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 21, modifier_item_name: "Bam"}),
              new ModifierItem({modifier_item_id: 22, modifier_item_name: "Sam"}),
            ]
          })
        ]
      });

      expect(menuItem.findModifier("")).toBeUndefined();
      expect(menuItem.findModifier("")).toBeUndefined();
      expect(menuItem.findModifier("")).toBeUndefined();
      expect(menuItem.findModifier("")).toBeUndefined();
    });

    it("returns nothing when no modifier is found", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 11, modifier_item_name: "Ham"}),
              new ModifierItem({modifier_item_id: 12, modifier_item_name: "Ram"}),
            ]
          }),
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({modifier_item_id: 21, modifier_item_name: "Bam"}),
              new ModifierItem({modifier_item_id: 22, modifier_item_name: "Sam"}),
            ]
          })
        ]
      });

      expect(menuItem.findModifier(5)).toBeUndefined();
      expect(menuItem.findModifier(4)).toBeUndefined();
      expect(menuItem.findModifier(3)).toBeUndefined();
      expect(menuItem.findModifier(2)).toBeUndefined();
    });

    it("returns the correct nested modifier", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          new ModifierGroup({
            modifier_items: [
              new ModifierItem({
                modifier_item_id: 1,
                modifier_item_name: "Ham",
                nested_items: [
                  new ModifierItem({
                    modifier_item_id: 2,
                    modifier_item_name: "Kosher"
                  }),
                  new ModifierItem({
                    modifier_item_id: 3,
                    modifier_item_name: "non-Kosher"
                  })
                ]
              })
            ]
          })
        ]
      });

      expect(menuItem.findModifier(2)).toEqual(jasmine.objectContaining({modifier_item_name: "Kosher"}));
      expect(menuItem.findModifier(3)).toEqual(jasmine.objectContaining({modifier_item_name: "non-Kosher"}));
    });
  });

  describe("#findAndZeroModifierGroup", function() {
    it("updates all modifiers with a quantity of zero", function() {
      var menuItem = new MenuItem({
        id: 1,
        modifier_groups: [
          {
            modifier_items: [
              {
                modifier_item_id: 12,
                modifier_item_name: "RAM",
                quantity: 1,
                nestedItems: undefined
              },
              {
                modifier_item_id: 12,
                modifier_item_name: "HAM",
                quantity: 1,
                nestedItems: undefined
              }
            ]
          }
        ]
      });

      expect(menuItem.modifier_groups[0].modifier_items[0].quantity).toEqual(1);
      expect(menuItem.modifier_groups[0].modifier_items[1].quantity).toEqual(1);

      menuItem.findAndZeroModifierGroup(12);

      expect(menuItem.modifier_groups[0].modifier_items[0].quantity).toEqual(0);
      expect(menuItem.modifier_groups[0].modifier_items[1].quantity).toEqual(0);
    });
  });

  describe("#calculateModifiers", function() {
    var itemModifiers, modifier_groups, item;

    beforeEach(function() {
      itemModifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Wood",
          modifier_item_max: 2,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "0.5"}]
        }),
        new ModifierItem({
          modifier_item_id: 2,
          modifier_item_name: "Ore",
          modifier_item_max: 2,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "1"}]
        }),
        new ModifierItem({
          modifier_item_id: 3,
          modifier_item_name: "Brick",
          modifier_item_max: 2,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "1.5"}]
        }),
        new ModifierItem({
          modifier_item_id: 4,
          modifier_item_name: "Sheep",
          modifier_item_max: 2,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "2"}]
        }),
        new ModifierItem({
          modifier_item_id: 5,
          modifier_item_name: "Wheat",
          modifier_item_max: 2,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 2, modifier_price: "2.5"}]
        }),
        new ModifierItem({
          modifier_item_id: 6,
          modifier_item_name: "Oedipus complex",
          modifier_item_max: 3,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 2, modifier_price: "1.5"}]
        }),
        new ModifierItem({
          modifier_item_id: 7,
          modifier_item_name: "Kid tested, mother approved",
          modifier_item_max: 2,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 2, modifier_price: ".5"}]
        })
      ];

      modifier_groups = [
        new ModifierGroup({
          name: "Road Cards",
          modifier_items: [itemModifiers[0], itemModifiers[2]],
          modifier_group_credit: 1.25,
          modifier_group_max_modifier_count: 2
        }),
        new ModifierGroup({
          name: "City Cards",
          modifier_items: [itemModifiers[1], itemModifiers[4]],
          modifier_group_credit: 2.33,
          modifier_group_max_modifier_count: 2
        }),
        new ModifierGroup({
          name: "Worthless Cards",
          modifier_items: [itemModifiers[3]],
          modifier_group_credit: 0,
          modifier_group_max_modifier_count: 2
        }),
        new ModifierGroup({
          name: "Cards against humanity",
          modifier_items: [itemModifiers[5], itemModifiers[6]],
          modifier_group_credit:.75,
          modifier_group_max_modifier_count: 1
        })
      ];

      item = new MenuItem({
        id: 1,
        name: "Sarah Paulson Sandwich",
        large_image: "https://www.placehold.it/600x400",
        small_image: "https://www.placehold.it/133x100",
        modifier_groups: modifier_groups,
        point_range: 2
      });
    });

    describe("should set the remainingCredit field on all modifier_groups", function() {
      describe("with a modifier group max greater than 1", function() {

        it("to their original credit if no modifiers are selected", function() {
          expect(modifier_groups[0].remainingCredit).toBeCloseTo(1.25);
          expect(modifier_groups[1].remainingCredit).toBeCloseTo(2.33);
          expect(modifier_groups[2].remainingCredit).toBeCloseTo(0);

          item.calculateModifiers();

          expect(modifier_groups[0].remainingCredit).toBeCloseTo(1.25);
          expect(modifier_groups[1].remainingCredit).toBeCloseTo(2.33);
          expect(modifier_groups[2].remainingCredit).toBeCloseTo(0);
        });

        it("to the credit minus the total price of all modifiers contained within the group", function() {
          expect(modifier_groups[0].remainingCredit).toBeCloseTo(1.25);
          expect(modifier_groups[1].remainingCredit).toBeCloseTo(2.33);
          expect(modifier_groups[2].remainingCredit).toBeCloseTo(0);

          itemModifiers[0].quantity = 1;
          itemModifiers[1].quantity = 2;
          itemModifiers[3].quantity = 1;

          item.calculateModifiers();

          expect(modifier_groups[0].remainingCredit).toBeCloseTo(0.75);
          expect(modifier_groups[1].remainingCredit).toBeCloseTo(0.33);
          expect(modifier_groups[2].remainingCredit).toBeCloseTo(0);
        });
      });

      describe("with modifier group max of 1", function() {
        it("to their original credit if no modifiers are selected", function() {
          expect(modifier_groups[3].remainingCredit).toBeCloseTo(.75);

          item.calculateModifiers();

          expect(modifier_groups[3].remainingCredit).toBeCloseTo(.75);
        });

        it("to stay at their original credit with a modifier selected", function() {
          expect(modifier_groups[3].remainingCredit).toBeCloseTo(.75);

          itemModifiers[0].quantity = 1;

          item.calculateModifiers();

          expect(modifier_groups[3].remainingCredit).toBeCloseTo(.75);
        });
      });

      describe("with nested modifiers", function () {
        beforeEach(function() {
          itemModifiers[0].nestedItems = [
            new ModifierItem({
              modifier_item_name: "test",
              modifier_item_id: 2,
              modifier_item_max: 1,
              modifier_item_pre_selected: true,
              quantity: 1,
              modifier_prices_by_item_size_id: [{
                modifier_price: "3.00",
                size_id: 1
              }]
            }),
            new ModifierItem({
              modifier_item_name: "test2",
              modifier_item_id: 2,
              modifier_item_max: 1,
              modifier_item_pre_selected: true,
              quantity: 1,
              modifier_prices_by_item_size_id: [{
                modifier_price: "1.00",
                size_id: 2
              }]
            })
          ];
        });

        it("should set a correct remaining credit with nested modifiers", function () {
          item.calculateModifiers(1);

          expect(modifier_groups[0].remainingCredit).toBeCloseTo(0);
        });
      });
    });

    describe("with negative modifiers amount", function () {
      it("should recalculate the netPrice based on the size ID and doesn't take care of credit", function() {
        var modifier =  new ModifierItem({
            modifier_item_id: 1,
            modifier_item_name: "Wood",
            modifier_item_max: 2,
            modifier_item_min: 0,
            modifier_item_pre_selected: false,
            quantity: 0,
            modifier_prices_by_item_size_id: [
              { size_id: 1, modifier_price: "-1.00" },
            ]
          });

        modifier_groups[0].modifier_items.push(modifier);

        item.calculateModifiers(1);

        expect(modifier.netPrice).toBe("-1.00");
      });
    });

    it("should recalculate the netPrice based on the size ID", function() {
      var itemModifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Wood",
          modifier_item_max: 2,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [
            {size_id: 1, modifier_price: "1"},
            {size_id: 2, modifier_price: "5"}
          ]
        }),

        new ModifierItem({
          modifier_item_id: 2,
          modifier_item_name: "Ore",
          modifier_item_max: 2,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [
            {size_id: 1, modifier_price: "2"},
            {size_id: 2, modifier_price: "10"}
          ]
        })
      ];

      var modifier_groups = [
        new ModifierGroup({
          name: "Road Cards",
          modifier_items: [itemModifiers[0], itemModifiers[1]],
          modifier_group_credit: 0
        })
      ];

      var menuItem = new MenuItem({
        id: 1,
        name: "Sarah Paulson Sandwich",
        large_image: "https://www.placehold.it/600x400",
        small_image: "https://www.placehold.it/133x100",
        modifier_groups: modifier_groups,
        point_range: 2,
        size_prices: [
          {size_id: 1, price: "8.99"}
        ]
      });

      expect(itemModifiers[0].netPrice).toBe(1);
      expect(itemModifiers[1].netPrice).toBe(2);

      menuItem.calculateModifiers(2);

      expect(itemModifiers[0].netPrice).toBe(5);
      expect(itemModifiers[1].netPrice).toBe(10);
    });

    describe("group max > 1", function() {
      it("should reset the netPrice field on all modifiers to the price minus any remaining credit in the group", function() {
        expect(itemModifiers[0].netPrice).toBeCloseTo(0);
        expect(itemModifiers[1].netPrice).toBeCloseTo(0);
        expect(itemModifiers[2].netPrice).toBeCloseTo(0.25);
        expect(itemModifiers[3].netPrice).toBeCloseTo(2);
        expect(itemModifiers[4].netPrice).toBeCloseTo(0.17);


        itemModifiers[0].quantity = 1;
        itemModifiers[1].quantity = 2;
        itemModifiers[3].quantity = 1;

        item.calculateModifiers();

        expect(itemModifiers[0].netPrice).toBeCloseTo(0);
        expect(itemModifiers[1].netPrice).toBeCloseTo(0.67);
        expect(itemModifiers[2].netPrice).toBeCloseTo(0.75);
        expect(itemModifiers[3].netPrice).toBeCloseTo(2);
        expect(itemModifiers[4].netPrice).toBeCloseTo(2.17);
      });
    });

    describe("group max = 1", function() {
      it("should always set netPrice to the price minus original credit in gropu", function() {
        expect(itemModifiers[5].netPrice).toBeCloseTo(.75);
        expect(itemModifiers[6].netPrice).toBeCloseTo(0);

        itemModifiers[5].quantity = 1;

        item.calculateModifiers();

        expect(itemModifiers[5].netPrice).toBeCloseTo(.75);
        expect(itemModifiers[6].netPrice).toBeCloseTo(0);
      });
    });


    describe("credit remaining", function() {
      var modifier_groups, item;

      beforeEach(function() {
        modifier_groups = [
          new ModifierGroup({
            name: "Road Cards",
            modifier_items: [itemModifiers[0], itemModifiers[2]],
            modifier_group_credit: 2.99
          }),
          new ModifierGroup({
            name: "City Cards",
            modifier_items: [itemModifiers[1], itemModifiers[4]],
            modifier_group_credit: 0.99
          })
        ];

        item = new MenuItem({
          id: 1,
          name: "Sarah Paulson Sandwich",
          large_image: "https://www.placehold.it/600x400",
          small_image: "https://www.placehold.it/133x100",
          modifier_groups: modifier_groups,
          point_range: 2
        });
      });

      it("should hide modifier group prices if there's remaining credit", function() {
        var hideSpy = spyOn($.fn, "hide");
        item.calculateModifiers();
        expect(hideSpy).toHaveBeenCalled();
      });
    });

    describe("no credit remaining", function() {
      it("should show modifier group prices", function() {
        var modifier_groups = [
          new ModifierGroup({
            name: "Road Cards",
            modifier_items: [itemModifiers[0], itemModifiers[2]],
            modifier_group_credit: 0
          }),
          new ModifierGroup({
            name: "City Cards",
            modifier_items: [itemModifiers[1], itemModifiers[4]],
            modifier_group_credit: 0
          })
        ];

        var menuItem = new MenuItem({
          id: 1, name: "Sarah Paulson Sandwich",
          large_image: "https://www.placehold.it/600x400",
          small_image: "https://www.placehold.it/133x100",
          modifier_groups: modifier_groups,
          point_range: 2
        });

        var showSpy = spyOn($.fn, "show");

        menuItem.calculateModifiers();

        expect(showSpy).toHaveBeenCalled();

      });
    });

    describe("modifier available with item size", function() {
      it("should enable the modifier", function() {
        var modifier_groups = [
          new ModifierGroup({
            name: "Road Cards",
            modifier_items: [itemModifiers[0], itemModifiers[2]],
            modifier_group_credit: 0
          }),
          new ModifierGroup({
            name: "City Cards",
            modifier_items: [itemModifiers[1], itemModifiers[4]],
            modifier_group_credit: 0
          })
        ];

        var menuItem = new MenuItem({
          id: 1,
          name: "Sarah Paulson Sandwich",
          large_image: "https://www.placehold.it/600x400",
          small_image: "https://www.placehold.it/133x100",
          modifier_groups: modifier_groups,
          point_range: 2
        });

        var removeClassSpy = spyOn($.fn, "removeClass");

        menuItem.calculateModifiers(1);

        expect(removeClassSpy).toHaveBeenCalledWith("disabled");
        var disabled = _.filter(removeClassSpy.calls.all(), function(n){ return _.contains(n["args"], "disabled"); });
        expect(disabled.length).toEqual(3);
      });
    });

    describe("modifier not available with item size", function() {
      var modifier_groups, menu_item;

      beforeEach(function() {
        var max_one_modifier = new ModifierItem({
          modifier_item_id: 1000,
          modifier_item_name: "MaxOne",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{ size_id: 1, modifier_price: "1" }]
        });

        modifier_groups = [
          new ModifierGroup({
            name: "Road Cards",
            modifier_items: [itemModifiers[0], itemModifiers[2], max_one_modifier],
            modifier_group_credit: 0
          }),
          new ModifierGroup({
            name: "City Cards",
            modifier_items: [itemModifiers[1], itemModifiers[4]],
            modifier_group_credit: 0
          })
        ];

        menu_item = new MenuItem({
          id: 1,
          name: "Sarah Paulson Sandwich",
          large_image: "https://www.placehold.it/600x400",
          small_image: "https://www.placehold.it/133x100",
          modifier_groups: modifier_groups,
          point_range: 2
        });
      });

      describe("with nested modifiers", function () {
        beforeEach(function () {
          var modifierItem = new ModifierItem({
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

          modifier_groups[0].modifier_items.push(modifierItem);
        });

        it("should disable nested modifiers button", function () {
          var addClassSpy = spyOn($.fn, "addClass");

          menu_item.calculateModifiers(2);

          expect(addClassSpy).toHaveBeenCalled();
          expect(addClassSpy.calls.count()).toEqual(7);
        });
      });

      it("should disable the modifier", function() {
        var addClassSpy = spyOn($.fn, "addClass");

        menu_item.calculateModifiers(2);

        expect(addClassSpy).toHaveBeenCalled();
        expect(addClassSpy.calls.count()).toEqual(4);
      });

      it("should uncheck elements", function() {
        var propSpy = spyOn($.fn, "prop");

        menu_item.calculateModifiers(2);

        expect(propSpy).toHaveBeenCalledWith("checked", false);
        expect(propSpy.calls.count()).toEqual(2);
      });

      it("should change item quantiy to 0", function(){
        itemModifiers[0].quantity = 1;
        itemModifiers[1].quantity = 1;
        itemModifiers[2].quantity = 1;

        expect(itemModifiers[0].quantity).toEqual(1);
        expect(itemModifiers[1].quantity).toEqual(1);
        expect(itemModifiers[2].quantity).toEqual(1);

        menu_item.calculateModifiers(2);

        expect(itemModifiers[0].quantity).toEqual(0);
        expect(itemModifiers[1].quantity).toEqual(0);
        expect(itemModifiers[2].quantity).toEqual(0);
      });

      it("should remove plus minus icons", function(){
        var removeClassSpy = spyOn($.fn, "removeClass");
        var attrSpy = spyOn($.fn, "attr");

        menu_item.calculateModifiers(2);

        expect(removeClassSpy).toHaveBeenCalledWith("active");
        var active = _.filter(removeClassSpy.calls.all(), function(n){ return _.contains(n["args"], "active"); });
        expect(active.length).toEqual(3);

        expect(attrSpy).toHaveBeenCalled();
        expect(attrSpy.calls.count()).toEqual(3);
      });
    });
  });

  describe("#addModifier", function() {
    var itemModifiers, item;

    beforeEach(function() {
      itemModifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Matthew Perry",
          modifier_item_max: 2,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "1"}]
        }),
        new ModifierItem({
          modifier_item_id: 2,
          modifier_item_name: "Aaron Sorkin",
          modifier_item_max: 2,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "2"}]
        }),
        new ModifierItem({
          modifier_item_id: 3,
          modifier_item_name: "Amanda Peet",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "3"}]
        }),
        new ModifierItem({
          modifier_item_id: 4,
          modifier_item_name: "Bradley Whitford",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "4"}]
        })
      ];

      item = new MenuItem({
        id: 1,
        name: "Sarah Paulson Sandwich",
        large_image: "https://www.placehold.it/600x400",
        small_image: "https://www.placehold.it/133x100",
        modifier_groups: [
          new ModifierGroup({
            name: "Writers",
            modifier_items: [itemModifiers[0], itemModifiers[1]],
            modifier_group_max_modifier_count: 3
          }),
          new ModifierGroup({
            name: "More Writers",
            modifier_items: [itemModifiers[2], itemModifiers[3]]
          })
        ]
      });
    });

    it("should increment the quantity of the provided modifier", function() {
      item.addModifier(item.findModifier(1));
      item.addModifier(item.findModifier(1));
      expect(itemModifiers[0].quantity).toBe(2);
    });

    it("should not increment beyond the provided modifier's max", function() {
      item.addModifier(item.findModifier(1));
      item.addModifier(item.findModifier(1));
      item.addModifier(item.findModifier(1));
      expect(itemModifiers[0].quantity).toBe(2);
    });

    it("should not throw if an invalid or no modifier is provided", function() {
      var error;
      try {
        item.addModifier(item.findModifier(99));
        item.addModifier();
      } catch (e) {
        error = e;
      }
      expect(error).toBeUndefined();
    });

    it("should not increment beyond the modifier group's max for all modifiers in the group", function() {
      item.addModifier(item.findModifier(1));
      item.addModifier(item.findModifier(1));
      item.addModifier(item.findModifier(2));
      item.addModifier(item.findModifier(2));
      expect(itemModifiers[0].quantity).toBe(2);
      expect(itemModifiers[1].quantity).toBe(1);
    });

    it("should recalc modifier prices", function() {
      var recalcSpy = spyOn(item, "calculateModifiers");
      item.addModifier(item.findModifier(1));
      expect(recalcSpy).toHaveBeenCalled();
    });
  });

  describe("#removeModifier", function() {
    var itemModifiers, item;

    beforeEach(function() {
      itemModifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Matthew Perry",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "1"}]
        }),
        new ModifierItem({
          modifier_item_id: 2,
          modifier_item_name: "Aaron Sorkin",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "2"}]
        }),
        new ModifierItem({
          modifier_item_id: 3,
          modifier_item_name: "Amanda Peet",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "3"}]
        }),
        new ModifierItem({
          modifier_item_id: 4,
          modifier_item_name: "Bradley Whitford",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "4"}]
        })
      ];

      item = new MenuItem({
        id: 1,
        name: "Sarah Paulson Sandwich",
        large_image: "https://www.placehold.it/600x400",
        small_image: "https://www.placehold.it/133x100", modifier_groups: [
          new ModifierGroup({
            name: "Writers",
            modifier_items: [itemModifiers[0], itemModifiers[1]]
          }),
          new ModifierGroup({
            name: "More Writers",
            modifier_items: [itemModifiers[2], itemModifiers[3]]
          })
        ]
      });

    });

    it("should decrement the quantity of the provided modifier", function() {
      itemModifiers[0].quantity = 1;
      item.removeModifier(item.findModifier(1));
      expect(itemModifiers[0].quantity).toBe(0);
    });

    it("should not decrement beyond the provided modifier's min", function() {
      item.removeModifier(item.findModifier(1));
      expect(itemModifiers[0].quantity).toBe(0);
    });

    it("should not throw if an invalid or no modifier is provided", function() {
      var error;
      try {
        item.removeModifier(item.findModifier(99));
        item.removeModifier();
      } catch (e) {
        error = e;
      }
      expect(error).toBeUndefined();
    });

    it("should not decrement below 0 all modifiers in the group", function() {
      itemModifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Matthew Perry",
          modifier_item_max: 3,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "1"}]
        }),
        new ModifierItem({
          modifier_item_id: 2,
          modifier_item_name: "Aaron Sorkin",
          modifier_item_max: 3,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "2"}]
        }),
        new ModifierItem({
          modifier_item_id: 3,
          modifier_item_name: "Amanda Peet",
          modifier_item_max: 3,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "3"}]
        }),
        new ModifierItem({
          modifier_item_id: 4,
          modifier_item_name: "Bradley Whitford",
          modifier_item_max: 1, modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "4"}]
        })
      ];

      item = new MenuItem({
        id: 1,
        name: "Sarah Paulson Sandwich",
        large_image: "https://www.placehold.it/600x400",
        small_image: "https://www.placehold.it/133x100",
        modifier_groups: [
          new ModifierGroup({
            name: "Writers",
            modifier_items: [itemModifiers[0], itemModifiers[1]],
            modifier_group_max_modifier_count: 3,
            modifier_group_min_modifier_count: 1
          }),
          new ModifierGroup({
            name: "More Writers",
            modifier_items: [itemModifiers[2], itemModifiers[3]]
          })
        ]
      });

      item.addModifier(item.findModifier(1));
      item.addModifier(item.findModifier(1));
      item.addModifier(item.findModifier(1));
      expect(itemModifiers[0].quantity).toBe(3);
      item.removeModifier(item.findModifier(1));
      expect(itemModifiers[0].quantity).toBe(2);
      item.removeModifier(item.findModifier(1));
      expect(itemModifiers[0].quantity).toBe(1);
      item.removeModifier(item.findModifier(1));
      expect(itemModifiers[0].quantity).toBe(0);
      item.removeModifier(item.findModifier(1));
      expect(itemModifiers[0].quantity).toBe(0);
    });

    it("should recalc modifier prices", function() {
      var recalcSpy = spyOn(item, "calculateModifiers");
      itemModifiers[0].quantity = 1;
      item.removeModifier(item.findModifier(1));
      expect(recalcSpy).toHaveBeenCalled();
    });
  });

  describe("#toggleModifier", function() {
    var singleItemModifiers, item;

    describe("when group.min == group.max", function() {
      beforeEach(function() {
        singleItemModifiers = [
          new ModifierItem({
            modifier_item_id: 1,
            modifier_item_name: "White Bread",
            modifier_item_max: 1,
            modifier_item_min: 1,
            modifier_item_pre_selected: false,
            quantity: 0,
            modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "0"}]
          }),
          new ModifierItem({
            modifier_item_id: 2,
            modifier_item_name: "Bacon Bread",
            modifier_item_max: 1,
            modifier_item_min: 1,
            modifier_item_pre_selected: false,
            quantity: 0,
            modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "2"}]
          })
        ];

        item = new MenuItem({
          id: 1,
          name: "Sarah Paulson Sandwich",
          large_image: "https://www.placehold.it/600x400",
          small_image: "https://www.placehold.it/133x100",
          modifier_groups: [
            new ModifierGroup({
              name: "Writers",
              modifier_items: [singleItemModifiers[0], singleItemModifiers[1]],
              modifier_group_max_modifier_count: 1,
              modifier_group_min_modifier_count: 1
            })
          ]
        });
      });

      it("should calculateModifiers()", function() {
        var recalcSpy = spyOn(item, "calculateModifiers");
        item.toggleModifier(2);
        expect(recalcSpy).toHaveBeenCalled();
      });

      it("should set the current modifer quantity to 1", function() {
        expect(singleItemModifiers[1].quantity).toBe(0);
        item.toggleModifier(2);
        expect(singleItemModifiers[1].quantity).toBe(1);
      });

      it("should return the modifier quantity", function() {
        expect(item.toggleModifier(2)).toEqual(1);
      });
    });

    describe("below or above group min / max", function() {
      var itemModifiers, item;

      beforeEach(function() {
        itemModifiers = [
          new ModifierItem({
            modifier_item_id: 1,
            modifier_item_name: "Matthew Perry",
            modifier_item_max: 1,
            modifier_item_min: 0,
            modifier_item_pre_selected: false,
            quantity: 0,
            modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "1"}]
          }),
          new ModifierItem({
            modifier_item_id: 2,
            modifier_item_name: "Aaron Sorkin",
            modifier_item_max: 2,
            modifier_item_min: 0,
            modifier_item_pre_selected: false,
            quantity: 0,
            modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "2"}]
          }),
          new ModifierItem({
            modifier_item_id: 3,
            modifier_item_name: "Amanda Peet",
            modifier_item_max: 1,
            modifier_item_min: 0,
            modifier_item_pre_selected: false,
            quantity: 0,
            modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "3"}]
          }),
          new ModifierItem({
            modifier_item_id: 4,
            modifier_item_name: "Bradley Whitford",
            modifier_item_max: 1,
            modifier_item_min: 0,
            modifier_item_pre_selected: false,
            quantity: 0,
            modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "4"}]
          })
        ];

        item = new MenuItem({
          id: 1,
          name: "Sarah Paulson Sandwich",
          large_image: "https://www.placehold.it/600x400",
          small_image: "https://www.placehold.it/133x100",
          modifier_groups: [
            new ModifierGroup({
              name: "Writers",
              modifier_items: [itemModifiers[0], itemModifiers[1]],
              modifier_group_max_modifier_count: 1
            }),
            new ModifierGroup({
              name: "More Writers",
              modifier_items: [itemModifiers[2], itemModifiers[3]],
              modifier_group_min_modifier_count: 2
            })
          ]
        });
      });

      it("should return the modifier quantity", function() {
        expect(item.toggleModifier(1)).toEqual(1);
      });

      it("should recalc modifier prices if the modifier quantity is currently 0", function() {
        var recalcSpy = spyOn(item, "calculateModifiers");
        itemModifiers[0].quantity = 0;
        item.toggleModifier(1);
        expect(recalcSpy).toHaveBeenCalled();
      });

      it("should recalc modifier prices if the modifier quantity is currently 1 ", function() {
        var recalcSpy = spyOn(item, "calculateModifiers");
        itemModifiers[0].quantity = 1;
        item.toggleModifier(1);
        expect(recalcSpy).toHaveBeenCalled();
      });

      it("should not change the quantity of the provided modifier if that would take the group above its max", function() {
        itemModifiers[0].quantity = 0;
        itemModifiers[1].quantity = 1;
        expect(itemModifiers[0].quantity).toBe(0);
      });

      it("should not change the quantity of the provided modifier if that would take the group below its min", function() {
        itemModifiers[2].quantity = 2;
        expect(itemModifiers[2].quantity).toBe(2);
      });

      it("should do nothing if the provided modifier has a max other than 1", function() {
        item.toggleModifier(2);
        expect(itemModifiers[0].quantity).toBe(0);
      });

      it("should not throw if an invalid or no modifier is provided", function() {
        var error;
        try {
          item.toggleModifier(99);
          item.toggleModifier();
        } catch (e) {
          error = e;
        }
        expect(error).toBeUndefined();
      });
    });
  });

  describe("#quantity", function() {
    var menuItem;

    it("should return a Modifier Group quantity if a Q Modifier Group is on the item", function() {
      menuItem = new MenuItem({
        modifier_groups: [
          new ModifierGroup({
            name: "Quantity",
            modifier_items: [ new ModifierItem({ quantity: 4 }) ],
            modifier_group_credit: 0.79,
            modifier_group_type: "Q"
            })
          ]
      });

      expect(menuItem.quantity()).toEqual(4);
    });

    it("should return 1 if there is not a Q Modifier Group on the item", function() {
      menuItem = new MenuItem({
        modifier_groups: [
          new ModifierGroup({
            name: "Quantity",
            modifier_items: [ new ModifierItem({ quantity: 4 }) ],
            modifier_group_credit: 0.79,
            modifier_group_type: "I2"
          })
        ]
      });

      expect(menuItem.quantity()).toEqual(1);
    });
  });

  describe("#totalPrice", function() {
    it("should account for modifier credit within a group only one time", function() {
      var itemModifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Dijon Mustard",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "1"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Yellow Mustard",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "2"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Industrial Strength Mayonnaise",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "3"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Baby Relish",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "4"}]
        })
      ];

      var menuItem = new MenuItem({
        id: 1,
        modifier_item_name: "Spinach Donut",
        description: "",
        large_image: "https://www.placehold.it/600x400",
        small_image: "https://www.placehold.it/133x100",
        modifier_groups: [
          new ModifierGroup({
            name: "Mustard",
            modifier_items: [itemModifiers[0], itemModifiers[1]],
            modifier_group_credit: 0.79
          }),
          new ModifierGroup({
            name: "Other Toppings",
            modifier_items: [itemModifiers[2], itemModifiers[3]]
          })
        ],
        size_prices: [
          {size_id: 1, price: "8.99", enabled: true}
        ]
      });

      itemModifiers[0].quantity = 3;
      itemModifiers[1].quantity = 4;
      itemModifiers[3].quantity = 1;

      expect(menuItem.totalPrice()).toEqual("23.20");
    });

    it("should return the total price of the item including modifiers", function() {
      var itemModifiers = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Les Paul",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "1"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Fender",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "2"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Neal Peart",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "3"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Tommy Aldridge",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: false,
          quantity: 0,
          modifier_prices_by_item_size_id: [{size_id: 1, modifier_price: "4"}]
        })
      ];

      var menuItem = new MenuItem({
        id: 1,
        name: "Lenny Kravitz Sandwich",
        description: "",
        large_image: "https://www.placehold.it/600x400",
        small_image: "https://www.placehold.it/133x100",
        modifier_groups: [
          new ModifierGroup({
            name: "Guitars",
            modifier_items: [itemModifiers[0], itemModifiers[1]]
          }),
          new ModifierGroup({
            name: "Drum Solos",
            modifier_items: [itemModifiers[2], itemModifiers[3]]
          })
        ],
        size_prices: [
          {size_id: 1, price: "8.99", enabled: true}
        ]
      });

      itemModifiers[0].quantity = 3;
      itemModifiers[1].quantity = 4;
      itemModifiers[3].quantity = 1;

      expect(menuItem.totalPrice()).toEqual("23.99");
    });

    it("should return the original price of the item when there are no modifiers", function() {
      var menuItem = new MenuItem({
        id: 1,
        name: "Lenny Kravitz Sandwich",
        description: "",
        large_image: "https://www.placehold.it/600x400",
        small_image: "https://www.placehold.it/133x100",
        modifier_groups: [],
        size_prices: [
          {size_id: 1, price: "8.99", enabled: true}
        ]
      });

      expect(menuItem.totalPrice()).toEqual("8.99");
    });

    it("should return the old total price multiply by quantity", function() {
      var menuItem = new MenuItem({
        id: 1,
        name: "Lenny Kravitz Sandwich",
        large_image: "https://www.placehold.it/600x400",
        small_image: "https://www.placehold.it/133x100",
        size_prices: [ { size_id: 1, price: "9.00", enabled: true } ],
        modifier_groups: [ new ModifierGroup({
          modifier_group_type: "Q",
          modifier_items: [ new ModifierItem({ quantity: 4 }) ]
        })]
      });

      expect(menuItem.totalPrice()).toEqual("36.00");
    });

    it("should return the price formatted to two decimal places", function() {
      var menuItem = new MenuItem({
        id: 1,
        name: "Lenny Kravitz Sandwich",
        large_image: "https://www.placehold.it/600x400",
        small_image: "https://www.placehold.it/133x100",
        size_prices: [
          {size_id: 1, price: "9.00", enabled: true}
        ]
      });

      expect(menuItem.totalPrice()).toEqual("9.00");
    });
  });


  describe("#totalModifiersPrice", function() {
    it("should only return accumulated price from group orders", function() {
      var menuItem = new MenuItem({
        item_id: "212013",
        item_name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/2x/212013.jpg",
        modifier_groups: modGroups,
        size_prices: [{ size_id: 1 }, { size_id: 2 }],
        point_range: 90,
        notes: "Hold teh lettuce, please."
      });

      expect(menuItem.totalModifiersPrice()).toEqual(2);
    });
  });

  describe("InterdependentsMethods", function() {
    var menuItem, meatsModifiers, meatsModifierInactive, meatsModifierActive;

    beforeEach(function(){
      meatsModifierInactive = new ModifierGroup({
        name: "meat",
        modifier_items: [
          new ModifierItem({
            modifier_item_id: 1,
            modifier_item_name: "Pork",
            modifier_item_max: 1,
            modifier_item_min: 0,
            modifier_item_pre_selected: true,
            quantity: 0,
            size_prices: [{size_id: 1, modifier_price: "1.00"}]
          })
        ],
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00,
        modifier_group_type: "I2",
        modifier_group_display_name: "Test Group"
      });

      meatsModifierActive = new ModifierGroup({
        name: "meat2",
        modifier_items: [
          new ModifierItem({
            modifier_item_id: 1,
            modifier_item_name: "Pork",
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
        modifier_group_max_price: 4.00,
        modifier_group_type: "I2"
      });

      meatsModifiers = [
        meatsModifierInactive,
        meatsModifierActive
      ];

      menuItem = new MenuItem({
        id: 1,
        name: "Lenny Kravitz Sandwich",
        large_image: "https://www.placehold.it/600x400",
        modifier_groups: meatsModifiers,
        small_image: "https://www.placehold.it/133x100",
        size_prices: [{ size_id: 1, price: "9.00", enabled: true }]
      });
    });

    describe("#inactiveInterdependets", function() {
      it("should return inactiveModifier", function() {
        var inactiveInterdependent = menuItem.inactiveInterdependents();
        expect(inactiveInterdependent.length).toEqual(1);
        expect(inactiveInterdependent[0]).toEqual(meatsModifierInactive);
      });

      it("should return empty", function() {
        menuItem.modifier_groups = [meatsModifierActive];
        var inactiveInterdependent = menuItem.inactiveInterdependents();
        expect(inactiveInterdependent.length).toEqual(0);
      });
    });

    describe("#activeInterdependets", function() {
      it("should return activeModifier", function() {
        var activeInterdependent = menuItem.activeInterdependents();
        expect(activeInterdependent.length).toEqual(1);
        expect(activeInterdependent[0]).toEqual(meatsModifierActive);
      });

      it("should return empty", function() {
        menuItem.modifier_groups = [meatsModifierInactive];
        var activeInterdependent = menuItem.activeInterdependents();
        expect(activeInterdependent.length).toEqual(0);
      });
    });

    describe("#modifiersInterdependets", function() {
      it("should return all Interdependent Modifiers", function() {
        var modifiersInterdependent = menuItem.modifiersInterdependents();
        expect(modifiersInterdependent.length).toEqual(2);
        expect(modifiersInterdependent[0]).toEqual(meatsModifierInactive);
        expect(modifiersInterdependent[1]).toEqual(meatsModifierActive);
      });

      it("should return empty", function() {
        menuItem.modifier_groups = [];
        var modifiersInterdependent = menuItem.activeInterdependents();
        expect(modifiersInterdependent.length).toEqual(0);
      });
    });

    describe("#interdependentValidationErrorMessage", function() {
      it("should return message when the inactive is odd and total is even and greater than 0", function() {
        var message = menuItem.interdependentValidationErrorMessage();
        expect(message).toEqual("Please select from Test Group");
      });

      it("should not return message when the inactive is even", function() {
        menuItem.modifier_groups = [meatsModifierInactive, meatsModifierInactive];
        var message = menuItem.interdependentValidationErrorMessage();
        expect(message).toBe(null);
      });

      it("should not return message when total Interdependants is odd", function() {
        menuItem.modifier_groups = [meatsModifierInactive, meatsModifierActive, meatsModifierInactive];
        var message = menuItem.interdependentValidationErrorMessage();
        expect(message).toBe(null);
      });

      it("should not return message when total Interdependants is 0", function() {
        menuItem.modifier_groups = [];
        var message = menuItem.interdependentValidationErrorMessage();
        expect(message).toBe(null);
      });
    });
  });

  describe("#setModifierQuantity", function() {
    var item;

    beforeEach(function () {
      item = new MenuItem({
        id: "212013",
        name: "Black Forest Ham",
        description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
        large_image: "https://image.com/large/2x/212013.jpg",
        small_image: "https://image.com/small/1x/212013.jpg",
        modifier_groups: [
          new ModifierGroup({
            name: "Cheese",
            modifier_group_max_modifier_count: 20,
            modifier_group_min_modifier_count: 1
          })
        ],
        size_prices: [
          { size_id: 1, price: "1", enabled: true },
          { size_id: 2, price: "2", enabled: false }
        ],
        point_range: 90,
        notes: "Hold teh lettuce, please."
      });
    });

    it("should set quantity text when it fulfills max and min", function () {
      var modifier = new ModifierItem({
        modifier_item_id: 443239000,
        modifier_item_name: "Normal",
        modifier_item_max: 20,
        modifier_item_min: 1,
        quantity: 2
      });

      item.modifier_groups[0].modifier_items = [modifier];

      item.setModifierQuantity(modifier, 10);

      expect(modifier.quantity).toEqual(10);
    });

    it("should set quantity text when it doesn't fulfills max and min modifier group", function () {
      var modifier = new ModifierItem({
        modifier_item_id: 443239000,
        modifier_item_name: "Normal",
        modifier_item_max: 30,
        modifier_item_min: 1,
        quantity: 2
      });

      item.modifier_groups[0].modifier_items = [modifier];

      item.setModifierQuantity(modifier, 25);

      expect(modifier.quantity).toEqual(2);
    });

    it("should set quantity text when it doesn't fulfills max and min modifier", function () {
      var modifier = new ModifierItem({
        modifier_item_id: 443239000,
        modifier_item_name: "Normal",
        modifier_item_max: 8,
        modifier_item_min: 1,
        quantity: 2
      });

      item.modifier_groups[0].modifier_items = [modifier];

      item.setModifierQuantity(modifier, 10);

      expect(modifier.quantity).toEqual(2);
    });
  });

  describe("#isValid", function () {
    describe("it has no modifier groups", function() {
      it("is valid", function () {
        var menuItem = new MenuItem({
          id: 1,
          name: "Lenny Kravitz Sandwich",
          large_image: "https://www.placehold.it/600x400",
          modifier_groups: undefined,
          small_image: "https://www.placehold.it/133x100",
          size_prices: [
            {size_id: 1, price: "9.00", enabled: true}
          ]
        });
        
        expect(menuItem.isValid()).toEqual(true);
      });
    });

    describe("it has interdependent modifiers", function () {
      var menuItem, meatsModifiers, meatsModifierInactive, meatsModifierActive;

      beforeEach(function(){
        meatsModifierInactive = new ModifierGroup({
          name: "meat",
          modifier_items: [
            new ModifierItem({
              modifier_item_id: 1,
              modifier_item_name: "Pork",
              modifier_item_max: 1,
              modifier_item_min: 0,
              modifier_item_pre_selected: true,
              quantity: 0,
              size_prices: [{size_id: 1, modifier_price: "1.00"}]
            })
          ],
          modifier_group_credit: 0.99,
          modifier_group_max_modifier_count: 4,
          modifier_group_min_modifier_count: 0,
          modifier_group_max_price: 4.00,
          modifier_group_type: "I2",
          modifier_group_display_name: "Test Group"
        });

        meatsModifierActive = new ModifierGroup({
          name: "meat2",
          modifier_items: [
            new ModifierItem({
              modifier_item_id: 1,
              modifier_item_name: "Pork",
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
          modifier_group_max_price: 4.00,
          modifier_group_type: "I2"
        });

        meatsModifiers = [
          meatsModifierInactive,
          meatsModifierActive
        ];

        menuItem = new MenuItem({
          id: 1,
          name: "Lenny Kravitz Sandwich",
          large_image: "https://www.placehold.it/600x400",
          modifier_groups: meatsModifiers,
          small_image: "https://www.placehold.it/133x100",
          size_prices: [{ size_id: 1, price: "9.00", enabled: true }]
        });
      });

      it("should return true when the inactive is odd and total is even and greater than 0", function() {
        expect(menuItem.isValid()).toBeFalsy();
      });

      it("should return false when the inactive is even", function() {
        menuItem.modifier_groups = [meatsModifierInactive, meatsModifierInactive];
        expect(menuItem.isValid()).toBeTruthy();
      });

      it("should return false when total Interdependants is odd", function() {
        menuItem.modifier_groups = [meatsModifierInactive, meatsModifierActive, meatsModifierInactive];
        expect(menuItem.isValid()).toBeTruthy();
      });

      it("should return false when total Interdependants is 0", function() {
        menuItem.modifier_groups = [];
        expect(menuItem.isValid()).toBeTruthy();
      });
    });

    describe("it has modifiers", function () {
      var meats = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Pork",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: true,
          quantity: 1,
          size_prices: [{size_id: 1, modifier_price: "1.00"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Steak",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: true,
          quantity: 1,
          size_prices: [{size_id: 1, modifier_price: "2.00"}]
        })
      ];
      
      var vegetables = [
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Cumquat",
          modifier_item_max: 5,
          modifier_item_min: 0,
          modifier_item_pre_selected: true,
          quantity: 1,
          size_prices: [{size_id: 1, modifier_price: "1.00"}]
        }),
        new ModifierItem({
          modifier_item_id: 1,
          modifier_item_name: "Carrot",
          modifier_item_max: 1,
          modifier_item_min: 0,
          modifier_item_pre_selected: true,
          quantity: 1,
          size_prices: [{size_id: 1, modifier_price: "2.00"}]
        })
      ];
      
      var modifierGroup1 = new ModifierGroup({
        name: "meat",
        modifier_items: meats,
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00
      });
      
      var modifierGroup2 = new ModifierGroup({
        name: "vegetables",
        modifier_items: vegetables,
        modifier_group_credit: 0.99,
        modifier_group_max_modifier_count: 4,
        modifier_group_min_modifier_count: 1,
        modifier_group_max_price: 4.00
      });
      
      var menuItem = new MenuItem({
        id: 1,
        name: "Lenny Kravitz Sandwich",
        large_image: "https://www.placehold.it/600x400",
        modifier_groups: [modifierGroup1, modifierGroup2],
        small_image: "https://www.placehold.it/133x100",
        size_prices: [
          {size_id: 1, price: "9.00", enabled: true}
        ]
      });
    
      menuItem.modifier_groups = [modifierGroup1, modifierGroup2];
      
      it("is valid", function () {
        menuItem.modifier_groups[0].modifier_items[0].quantity = 1;
        expect(menuItem.isValid()).toEqual(true);
      });
      
      
      describe("has invalid modifier group", function () {
        it("is invalid if quantity is too high", function () {
          menuItem.modifier_groups[0].modifier_items[0].quantity = 5;
          expect(menuItem.isValid()).toEqual(false);
        });
        
        it("is invalid if quantity is too low", function () {
          menuItem.modifier_groups[0].modifier_items[0].quantity = 0;
          menuItem.modifier_groups[0].modifier_items[1].quantity = 0;
          expect(menuItem.isValid()).toEqual(false);
        });
      });
    });
  });
});
