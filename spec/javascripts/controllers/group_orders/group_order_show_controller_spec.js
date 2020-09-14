describe("GroupOrdersShowController", function() {

  beforeEach(function() {
    loadFixtures('group_orders/show.html');
  });

  describe("#intitialize", function() {
    it("sets the refresh interval", function() {
      var groupOrderShow = new GroupOrdersShowController();
      expect(groupOrderShow.refreshInterval).toEqual(60000);
    });

    it("sets group order token", function() {
      var groupOrderShow = new GroupOrdersShowController();
      expect(groupOrderShow.groupOrderToken).toEqual("6582-ba35x-34lab-sznk8");
    });

    it("binds delete events", function() {
      var bindDeleteEventsSpy = spyOn(GroupOrdersShowController.prototype, "bindDeleteEvents");
      new GroupOrdersShowController();
      expect(bindDeleteEventsSpy).toHaveBeenCalled();
    });

    it("initializes setRefreshInterval()", function() {
      var bindRefreshIntervalSpy = spyOn(GroupOrdersShowController.prototype, "bindRefreshInterval");
      new GroupOrdersShowController();
      expect(bindRefreshIntervalSpy).toHaveBeenCalled();
    });

    it("initializes setCancelOrderEvent()", function() {
      var bindCancelOrderEventSpy = spyOn(GroupOrdersShowController.prototype, "bindCancelOrderEvent");
      new GroupOrdersShowController();
      expect(bindCancelOrderEventSpy).toHaveBeenCalled();
    });

    it("should bind IncrementEvent", function() {
      var incrementSpy = spyOn(GroupOrdersShowController.prototype, "bindIncrementEvent");
      new GroupOrdersShowController();
      expect(incrementSpy).toHaveBeenCalled();
    });
  });

  describe("#bindRefreshInterval", function() {
    beforeEach(function() {
      jasmine.clock().install();
    });

    afterEach(function() {
      jasmine.clock().uninstall();
    });

    it("gets the group order every interval", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var getGroupOrderSpy = spyOn(groupOrderShow, "getGroupOrder");

      groupOrderShow.refreshInterval = 50;
      groupOrderShow.bindRefreshInterval();

      expect(getGroupOrderSpy).not.toHaveBeenCalled();

      jasmine.clock().tick(51);
      expect(getGroupOrderSpy.calls.count()).toEqual(1);
      jasmine.clock().tick(51);
      expect(getGroupOrderSpy.calls.count()).toEqual(2);
      jasmine.clock().tick(51);
      expect(getGroupOrderSpy.calls.count()).toEqual(3);
    });
  });

  describe("#bindIncrementEvent", function() {
    beforeEach(function () {
      $("#modifiers section.right-block").append($("<button id='increment-button'>"));
      $("#submit-time").append($("<span id='expire-at'>"));
    });

    it("should attach and call ajax event for increment on click", function () {
      var ajaxSpy = spyOn($, "ajax");
      new GroupOrdersShowController().bindIncrementEvent();
      $("#increment-button").trigger("click");
      expect(ajaxSpy).toHaveBeenCalledWith({
        url: "/group_orders/6582-ba35x-34lab-sznk8/increment/10",
        type: "POST",
        context: $("#increment-button")[0],
        success: jasmine.any(Function),
        error: jasmine.any(Function),
        complete: jasmine.any(Function),
      });
    });

    it("should update submit time", function () {
      spyOn($, "ajax").and.callFake(function(params) {
        return params.success({
          send_on_local_time_string: "Test"
        });
      });
      new GroupOrdersShowController().bindIncrementEvent();
      $("#increment-button").trigger("click");

      expect($("#expire-at").text()).toEqual("Test");
    });

    it("should open a warning dialog", function () {
      var dialogSpy = spyOn(WarningModalController.prototype, "open");

      spyOn($, "ajax").and.callFake(function(params) {
        return params.error({ });
      });

      new GroupOrdersShowController().bindIncrementEvent();
      $("#increment-button").trigger("click");

      expect(dialogSpy).toHaveBeenCalled();
    });
  });

  describe("#bindCancelEvents", function() {
    it("opens the cancel order dialog", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var openCancelOrderDialogSpy = spyOn(groupOrderShow, "openCancelOrderDialog")
      $("#cancel").click();
      expect(openCancelOrderDialogSpy).toHaveBeenCalledWith(jasmine.any(Object));
    });
  });

  describe("#openCancelOrderDialog", function() {

    var event;

    beforeEach(function(){
      event = { preventDefault: function(){} };
    });

    afterEach(function() {
      Dialog.close_all();
    });

    it("prevents default on click", function() {
      var preventDefaultSpy = spyOn(event, "preventDefault");
      var groupOrderShow = new GroupOrdersShowController();
      groupOrderShow.openCancelOrderDialog(event);
      expect(preventDefaultSpy).toHaveBeenCalled();
    });

    it("opens the dialog", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var dialogOpenSpy = spyOn(Dialog.prototype, "open");
      groupOrderShow.openCancelOrderDialog(event);
      expect(dialogOpenSpy).toHaveBeenCalled();
    });

    it("closes the dialog when aborting from cancellation", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var dialogCloseSpy = spyOn(Dialog.prototype, "close").and.callThrough();
      groupOrderShow.openCancelOrderDialog(event);
      $("#cancel-abort").click();
      expect(dialogCloseSpy).toHaveBeenCalled();
    });

    it("submits the cancel request when proceeding", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var submitSpy = spyOn($.fn, "submit");
      groupOrderShow.openCancelOrderDialog(event);
      $("#cancel-proceed").click();
      expect(submitSpy).toHaveBeenCalled();
    });
  });

  describe("#disableCheckoutButton", function() {
    it("disables the checkout button if there are no items", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var disableSpy = spyOn($.fn, "disable");

      groupOrderShow.disableCheckoutButton();

      expect(disableSpy).toHaveBeenCalled();
    });
  });

  describe("#enableCheckoutButton", function() {
    it("disables the checkout button if there are no items", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var enableSpy = spyOn($.fn, "enable");

      groupOrderShow.enableCheckoutButton();

      expect(enableSpy).toHaveBeenCalled();
    });
  });

  describe("#disableAddItemsButton", function() {
    it("disables the add items button if the GO has been already submitted", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var disableSpy = spyOn($.fn, "disable");

      groupOrderShow.disableAddItemsButton();

      expect(disableSpy).toHaveBeenCalled();
    });
  });

  describe("#disableIncrementTimeButton", function() {
    it("disables the increment time button if the GO has been already submitted", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var disableSpy = spyOn($.fn, "disable");

      groupOrderShow.disableIncrementTimeButton();

      expect(disableSpy).toHaveBeenCalled();
    });
  });

  describe("#disableCancelButton", function() {
    it("disables the cancel button if the GO has been already submitted", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var disableSpy = spyOn($.fn, "disable");

      groupOrderShow.disableCancelButton();

      expect(disableSpy).toHaveBeenCalled();
    });
  });

  describe("#enableCancelButton", function() {
    it("enables the cancel button", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var enableSpy = spyOn($.fn, "enable");

      groupOrderShow.enableCancelButton();

      expect(enableSpy).toHaveBeenCalled();
    });
  });

  describe("#hideItem", function() {
    it("hides the specified item", function() {
      var groupOrderShow = new GroupOrdersShowController();
      var hideSpy = spyOn($.fn, "hide");
      groupOrderShow.hideItem("1234");
      expect(hideSpy).toHaveBeenCalled();
    });
  });

  describe("#getGroupOrder", function() {
    it("gets group order data", function () {
      var ajaxSpy = spyOn($, "ajax");
      var groupOrderShow = new GroupOrdersShowController();
      groupOrderShow.getGroupOrder();
      expect(ajaxSpy).toHaveBeenCalledWith({
        url: '/group_order/6582-ba35x-34lab-sznk8',
        type: 'GET',
        success: jasmine.any(Function),
        error: jasmine.any(Function)
      });
    });

    it("enables checkout button when there are submitted orders", function() {
      spyOn($, "ajax").and.callFake(function(params) {
        return params.success({
          group_order_type: "1",
          total_submitted_orders: "1",
          status: "submitted",
          order_summary: {
            cart_items: []
          }
        });
      });
      var updateButtonSpy = spyOn(GroupOrdersShowController.prototype, "enableCheckoutButton");
      var groupOrderShow = new GroupOrdersShowController();

      groupOrderShow.getGroupOrder();

      expect(updateButtonSpy).toHaveBeenCalled();
    });

    it("disables checkout button when there is not any submitted order", function() {
      spyOn($, "ajax").and.callFake(function(params) {
        return params.success({
          group_order_type: "1",
          total_submitted_orders: "0",
          status: "submitted",
          order_summary: {
            cart_items: []
          }
        });
      });
      var updateButtonSpy = spyOn(GroupOrdersShowController.prototype, "disableCheckoutButton");
      var groupOrderShow = new GroupOrdersShowController();

      groupOrderShow.getGroupOrder();

      expect(updateButtonSpy).toHaveBeenCalled();
    });

    it("doesn't append new items on failure", function() {
      spyOn($, "ajax").and.callFake(function(params) {
        return params.error();
      });

      var renderItemsSpy = spyOn(GroupOrdersShowController.prototype, "renderItemsData");
      var groupOrderShow = new GroupOrdersShowController();

      groupOrderShow.getGroupOrder();

      expect(renderItemsSpy).not.toHaveBeenCalled();
    });
  });

  describe("#renderGroupOrderDetails", function() {
    var groupOrder, groupOrderShow;

    beforeEach(function() {
      groupOrderShow = new GroupOrdersShowController();

      groupOrder = {
        group_order_type: "1",
        order_summary: {
          cart_items: []
        }
      };
    });

    it("removes existing items", function() {
      var emptySpy = spyOn($.fn, "empty");

      groupOrderShow.renderGroupOrderDetails(groupOrder);

      expect(emptySpy).toHaveBeenCalled();
    });

    describe("Individual Pay", function() {
      var groupOrder;

      beforeEach(function() {
        groupOrder = {
          status: "submitted",
          group_order_type: "2",
          order_summary: {
            user_items: [{
              user_id: "4777193",
              full_name: "test_user",
              item_count: "1"
            }]
          }
        };
      });

      it("appends new user order's on success", function() {
        var renderSpy = spyOn(GroupOrdersShowController.prototype, "renderUsersData");
        var groupOrderShow = new GroupOrdersShowController();

        groupOrderShow.renderGroupOrderDetails(groupOrder);

        expect(renderSpy).toHaveBeenCalled();
      });

      it("updates status on success", function() {
        var updateSpy = spyOn(GroupOrdersShowController.prototype, "updateStatus");
        var groupOrderShow = new GroupOrdersShowController();

        groupOrderShow.renderGroupOrderDetails(groupOrder);

        expect(updateSpy).toHaveBeenCalled();
      });
    });

    describe("Admin Pay", function() {
      it("appends new items on success", function() {
        var renderSpy = spyOn(GroupOrdersShowController.prototype, "renderItemsData");
        var groupOrderShow = new GroupOrdersShowController();

        groupOrderShow.renderGroupOrderDetails(groupOrder);

        expect(renderSpy).toHaveBeenCalled();
      });

      it("#initializes bindDeleteEvents", function() {
        var bindDeleteEventsSpy = spyOn(GroupOrdersShowController.prototype, "bindDeleteEvents");
        groupOrderShow.renderGroupOrderDetails(groupOrder);
        expect(bindDeleteEventsSpy).toHaveBeenCalled();
      });
    });
  });

  describe("#renderItemsData", function() {
    var groupOrderShow;
    var items;

    beforeEach(function() {
      groupOrderShow = new GroupOrdersShowController();
      items = [{
          order_detail_id: 1234,
          item_name: "Bacon Hat",
          item_price: "$5.00",
          item_description: "Juicy. Very juicy.",
          item_note: "Tom H."
        }]
    });

    it("adds all items", function() {
      var appendSpy = spyOn($.fn, "append");
      groupOrderShow.renderItemsData(items, "active");
      expect(appendSpy).toHaveBeenCalled();
    });
  });

  describe("#renderUsersData", function() {
    var groupOrderShow;
    var users;

    beforeEach(function() {
      groupOrderShow = new GroupOrdersShowController();
      users = [{
        user_id: "4777193",
        full_name: "Ariel Alba",
        item_count: "1"
      }]
    });

    it("adds all items", function() {
      var appendSpy = spyOn($.fn, "append");
      groupOrderShow.renderItemsData(users, "active");
      expect(appendSpy).toHaveBeenCalled();
    });
  });

  describe("#updateStatus", function() {
    it("should update status",function() {
      var textSpy = spyOn($.fn, "text");
      var groupOrderShow = new GroupOrdersShowController();
      groupOrderShow.updateStatus({ status: "test" })
      expect(textSpy).toHaveBeenCalledWith("test");
    });
  });

  describe("#updateOrdersCounter", function() {
    it("should update status",function() {
      var textSpy = spyOn($.fn, "text");
      var groupOrderShow = new GroupOrdersShowController();
      groupOrderShow.updateOrdersCounter({ total_submitted_orders: "1" })
      expect(textSpy).toHaveBeenCalledWith("1");
    });
  });

  describe('#updateOrdersCounter after one minute', function(){
    beforeEach(function() {
      jasmine.clock().install();
    });

    afterEach(function() {
      jasmine.clock().uninstall();
    });

    it("should call the updateOrdersCounter method after one minute", function(){
      var getGroupOrderController = new GroupOrdersShowController();
      var getGroupOrderSpy = spyOn(getGroupOrderController, "getGroupOrder");
      var updateOrderCounterSpy = spyOn($.fn, "text");

      getGroupOrderController.refreshInterval  = 60;
      getGroupOrderController.bindRefreshInterval();

      expect(updateOrderCounterSpy).not.toHaveBeenCalled();
      expect(getGroupOrderSpy).not.toHaveBeenCalled();

      jasmine.clock().tick(61);

      getGroupOrderController.updateOrdersCounter({ total_submitted_orders: "1" });

      expect(getGroupOrderSpy).toHaveBeenCalled();
      expect(getGroupOrderSpy.calls.count()).toEqual(1);
      expect(updateOrderCounterSpy).toHaveBeenCalledWith("1");
      expect(updateOrderCounterSpy.calls.count()).toEqual(1);
    });
  });
});
