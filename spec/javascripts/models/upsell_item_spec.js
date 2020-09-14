describe("UpsellItem", function() {
  var upsellItem;

  beforeEach(function() {
    upsellItem = new UpsellItem({
      item_id: "212013",
      item_name: "Black Forest Ham",
      description: "Black Forest Ham, Shredded Lettuce, Tomatoes",
      large_image: "https://image.com/large/2x/212013.jpg",
      small_image: "https://image.com/small/2x/212013.jpg",
      modifier_groups: [
        new ModifierGroup({modifier_group_display_name: "Meat"}),
        new ModifierGroup({modifier_group_display_name: "Cheese"})
      ],
      size_prices: [
        { size_id: 1, price: "8.99", enabled: true },
        { size_id: 2, price: "8.99", enabled: true }
      ],
      point_range: 90,
      notes: "Hold teh lettuce, please."
    });
  });

  describe("#toMinParams", function() {
    it("should return min object", function() {
      expect(upsellItem.toMinParams()).toEqual({
        item_id: 212013,
        item_name: "Black Forest Ham",
        total_price: "8.99" });
    });
  });
});