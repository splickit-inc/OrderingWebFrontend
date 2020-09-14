describe("MenuItems", function() {
  var menuItem;

  beforeEach(function() {
    menuItem = new MenuItem({
      item_id: "212013",
      item_name: "Black Forest Ham",
      description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
      large_image: "https://image.com/large/2x/212013.jpg",
      small_image: "https://image.com/small/2x/212013.jpg",
      modifier_groups: [
        new ModifierGroup({ modifier_group_display_name: "Meat" }),
        new ModifierGroup({ modifier_group_display_name: "Cheese" })
      ],
      size_prices: [
        { size_id: 1, price: "8.99", enabled: true },
        { size_id: 2, price: "8.99", enabled: true }
      ],
      point_range: 90,
      notes: "Hold teh lettuce, please."
    });
  });

  describe("#new", function() {
    it("should set payWith attribute", function() {
      var cartItems = new MenuItems({ items: [ new MenuItem() ] });
      expect(cartItems.payWith).toEqual("cash");

      cartItems = new MenuItems({ items: [ new MenuItem() ], payWith: "cc" });
      expect(cartItems.payWith).toEqual("cc");
    });

    it("should set item attribute", function() {
      var menuItem = new MenuItem();
      var cartItems = new MenuItems({ items: [menuItem] });
      expect(cartItems.items).toEqual([ menuItem ]);
    });
  });

  describe("#addToOrder", function() {
    var cartItems;

    beforeEach(function() {
      cartItems = new MenuItems({ items: [ menuItem ] });
    });

    it("should call OrderService to add an order", function(){
      var fakeCallback = jasmine.createSpy("fake");
      var orderServiceSpy = spyOn(OrderService.prototype, "createItem");
      cartItems.addToOrder(fakeCallback);
      expect(orderServiceSpy).toHaveBeenCalledWith(cartItems.getJSONItems(), fakeCallback);
    });
  });
});