describe("GroupOrdersCreateController", function() {

  describe("#intitialize", function() {
    it("sets the refresh interval", function() {
      var groupOrderCreate = new GroupOrdersCreateController(1080, "pickup", 2);
      expect(groupOrderCreate.refreshInterval).toEqual(60000*5);
      expect(groupOrderCreate.MerchantId).toEqual(1080);
      expect(groupOrderCreate.OrderType).toEqual('pickup');
      expect(groupOrderCreate.GroupOrderType).toEqual(2);
    });


    it("initializes setRefreshInterval()", function() {
      var bindRefreshIntervalSpy = spyOn(GroupOrdersCreateController.prototype, "bindRefreshInterval");
      new GroupOrdersCreateController(1080, "pickup", 2);
      expect(bindRefreshIntervalSpy).toHaveBeenCalled();
    });
  });

  describe("#bindRefreshInterval", function() {
    beforeEach(function() {
      jasmine.clock().install();
    });

    afterEach(function() {
      jasmine.clock().uninstall();
    });

    it("gets the group order available time severy interval", function() {
      var groupOrderCreate = new GroupOrdersCreateController(1080, "pickup", 2);
      var getGroupOrderSpy = spyOn(groupOrderCreate, "getGroupOrderAvailableTimes");

      groupOrderCreate.refreshInterval = 50;
      groupOrderCreate.bindRefreshInterval();

      expect(getGroupOrderSpy).not.toHaveBeenCalled();

      jasmine.clock().tick(51);
      expect(getGroupOrderSpy.calls.count()).toEqual(1);
      jasmine.clock().tick(51);
      expect(getGroupOrderSpy.calls.count()).toEqual(2);
      jasmine.clock().tick(51);
      expect(getGroupOrderSpy.calls.count()).toEqual(3);

    });
  });


  describe("#disableSendButton", function() {
    it("disables the Send button if there are select invities pay option", function() {
      var groupOrderCreate = new GroupOrdersCreateController(1080, "pickup", 2);
      var addClassSpy = spyOn($.fn, "addClass");
      var attrSpy = spyOn($.fn, "attr");

      groupOrderCreate.disableSendButton();

      expect(addClassSpy).toHaveBeenCalledWith("disabled");
      expect(attrSpy).toHaveBeenCalledWith("disabled", true);
    });
  });

  describe("#enableSendButton", function() {
    it("enable the send button if there are select you pay option", function() {
      var groupOrderCreate = new GroupOrdersCreateController(1080, "pickup", 2);
      var removeClassSpy = spyOn($.fn, "removeClass");
      var attrSpy = spyOn($.fn, "attr");

      groupOrderCreate.enableSendButton();

      expect(removeClassSpy).toHaveBeenCalledWith("disabled");
      expect(attrSpy).toHaveBeenCalledWith("disabled", false);
    });
  });



  describe("#getGroupOrderAvailableTimes", function() {
    it("gets group order available times data", function() {
      var ajaxSpy = spyOn($, "ajax");
      var groupOrderCreate = new GroupOrdersCreateController(1080, "pickup", 2);
      groupOrderCreate.getGroupOrderAvailableTimes();
      expect(ajaxSpy).toHaveBeenCalledWith({ url: '/merchants/1080/group_order_available_times/pickup', type: 'GET', success: jasmine.any(Function), error: jasmine.any(Function) });
    });

    it("refresh group order available times on success", function() {

      spyOn($, "ajax").and.callFake(function(params) {
        return params.success({submit_times_array: [ 1459806460, 1459806520, 1459806580, 1459806640, 1459806700, 1459806760, 1459806820, 1459806880, 1459806940, 1459820700 ]});
      });

      var getGroupOrderAvailableTimesSpy = spyOn(GroupOrdersCreateController.prototype, "getGroupOrderAvailableTimes");
      var groupOrderCreate = new GroupOrdersCreateController( 1080, "pickup", 2 );

      groupOrderCreate.getGroupOrderAvailableTimes();

      expect(getGroupOrderAvailableTimesSpy).toHaveBeenCalled();
    });

    it("updates send button on success", function() {

      spyOn($, "ajax").and.callFake(function(params) {
        return params.success({submit_times_array: [ 1459806460, 1459806520, 1459806580, 1459806640, 1459806700, 1459806760, 1459806820, 1459806880, 1459806940, 1459820700 ]});
      });

      var enableSendButtonSpy = spyOn(GroupOrdersCreateController.prototype, "enableSendButton");
      var groupOrderCreate = new GroupOrdersCreateController(1080, "pickup", 2);

      groupOrderCreate.getGroupOrderAvailableTimes();

      expect(enableSendButtonSpy).toHaveBeenCalled();
    });
  });
});
