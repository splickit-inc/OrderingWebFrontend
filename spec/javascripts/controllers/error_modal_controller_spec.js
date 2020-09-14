describe("ErroreModalController", function() {
  beforeEach(function () {
    loadFixtures('checkouts_view.html');
  });

  afterEach(function () {
    Dialog.close_all();
  });

  describe("initErrorModal", function() {
    it("should open dialog on initialize", function(){
      var dialogOpenSpy = spyOn(Dialog.prototype, "open");
      ErrorModalController.initialize("Error message");
      expect(dialogOpenSpy).toHaveBeenCalled();
    });

    it("should use the correct dialog html", function(){
      ErrorModalController.initialize("Error message");
      expect($("div.order-error .description").length).toEqual(1);
      expect($("div.order-error .description").text()).toContain("Your order is incomplete.  Please make the following changes:");
      expect($("div.order-error ul li").length).toEqual(1);
      expect($("div.order-error ul li").text()).toContain("Error message");
      expect($("div[data-dialog-footer] button").length).toEqual(1);
      expect($("div[data-dialog-footer] button").text()).toEqual("OK");
    });
  });

  describe("bindModalEvents", function() {
    it("should call bindModalEvents", function() {
      var bindSpy = spyOn(ErrorModalController, "bindModalEvents");
      ErrorModalController.initialize("Error message");
      expect(bindSpy).toHaveBeenCalled();
    });

    it("should close dialog", function() {
      var dialogCloseSpy = spyOn(Dialog.prototype, "close").and.callThrough();
      ErrorModalController.initialize("Error message");
      $("div[data-dialog-footer] button.modal-close").trigger("click");
      expect(dialogCloseSpy).toHaveBeenCalled();
    });
  });
});