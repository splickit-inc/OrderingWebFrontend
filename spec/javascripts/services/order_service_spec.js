describe("OrderService", function() {

  var orderService = null;

  beforeEach(function() {
    loadFixtures("order_service_view.html");
    orderService = new OrderService();
  });

  describe("#show", function() {
    it("should make AJAX call with the correct params", function() {
      var ajaxSpy = spyOn($, "ajax");
      orderService.show({});
      expect(ajaxSpy).toHaveBeenCalledWith(jasmine.objectContaining({type: "GET", url: "/order"}));
    });

    it("should invoke the passed in callback", function() {
      var ajaxSpy = spyOn($, "ajax");
      var mockCallback = jasmine.createSpy("callback");
      orderService.show(mockCallback);
      expect(ajaxSpy).toHaveBeenCalledWith(jasmine.objectContaining({success: mockCallback}));
    });
  });

  describe("#createItem", function() {
    it("should make AJAX call with the correct params", function() {
      var ajaxSpy = spyOn($, "ajax");
      var item = {"item_id": "1"};
      orderService.createItem([item], {});
      expect(ajaxSpy).toHaveBeenCalledWith(jasmine.objectContaining({type: "POST", url: "/order/item", data: {items: JSON.stringify([item]), merchant_id: 1234, order_type: "delivery", merchant_name: 'The Burger Factory', group_order_token: "HXBX-1000"}}));
    });

    it("should invoke the passed in callback", function() {
      var ajaxSpy = spyOn($, "ajax");
      var mockCallback = jasmine.createSpy("callback");
      orderService.createItem({}, mockCallback);
      expect(ajaxSpy).toHaveBeenCalledWith(jasmine.objectContaining({success: mockCallback}));
    });
  });

  describe("#showItem", function() {
    it("should make AJAX call with the correct params", function() {
      var ajaxSpy = spyOn($, "ajax");
      orderService.showItem("155", {});
      expect(ajaxSpy).toHaveBeenCalledWith(jasmine.objectContaining({type: "GET", url: "/order/item/155"}));
    });

    it("should invoke the passed in callback", function() {
      var ajaxSpy = spyOn($, "ajax");
      var mockCallback = jasmine.createSpy("callback");
      orderService.showItem("155", mockCallback);
      expect(ajaxSpy).toHaveBeenCalledWith(jasmine.objectContaining({success: mockCallback}));
    });
  });

  describe("#updateItem", function() {
    it("should make AJAX call with the correct params", function() {
      var ajaxSpy = spyOn($, "ajax");
      var item = {"uuid": "255", name: "bacon rolls"};
      orderService.updateItem(item, {});
      expect(ajaxSpy).toHaveBeenCalledWith(jasmine.objectContaining({type: "PUT", url: "/order/item/255", data: {item: item}}));
    });

    it("should invoke the passed in callback", function() {
      var ajaxSpy = spyOn($, "ajax");
      var mockCallback = jasmine.createSpy("callback");
      var item = {"uuid": "255", name: "bacon rolls"};
      orderService.updateItem(item, mockCallback);
      expect(ajaxSpy).toHaveBeenCalledWith(jasmine.objectContaining({success: mockCallback}));
    });
  });

  describe("#deleteItem", function() {
    it("should make AJAX call with the correct params", function() {
      var ajaxSpy = spyOn($, "ajax");
      orderService.deleteItem("1", {});
      expect(ajaxSpy).toHaveBeenCalledWith(jasmine.objectContaining({type: "DELETE", url: "/order/item/1"}));
    });

    it("should invoke the passed in callback", function() {
      var ajaxSpy = spyOn($, "ajax");
      var mockCallback = jasmine.createSpy("callback");
      orderService.deleteItem("1", mockCallback);
      expect(ajaxSpy).toHaveBeenCalledWith(jasmine.objectContaining({success: mockCallback}));
    });
  });
});
