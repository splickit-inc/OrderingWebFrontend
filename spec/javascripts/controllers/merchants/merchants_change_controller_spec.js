describe("MerchantsChangeController", function () {
  afterEach(function () {
    // Dialogs from the tests stay open if we don't do this
    Dialog.close_all();
  });

  describe("#openDialog", function() {
    it("should bind redirectCallback to continue click", function () {
      var fakeCallback = jasmine.createSpy("callback");

      new MerchantsChangeController().openDialog({
        event: "1",
        redirectCallback: fakeCallback,
        currentMerchantID: "1",
        orderType: "delivery"
      });

      $(".button.continue").trigger("click");

      expect(fakeCallback).toHaveBeenCalledWith("delivery", "1");
    });
  });
});
