describe("FlashNotification", function() {
  describe("#initialize", function() {
    it("binds a close event", function() {
      var bindFlashSpy = spyOn(FlashNotification.prototype, "bindFlash");
      new FlashNotification($("fluffy-cat"));
      expect(bindFlashSpy).toHaveBeenCalled();
    });

    it("binds a close event", function() {
      var bindFlashSpy = spyOn(FlashNotification.prototype, "bindFlash");
      new FlashNotification($("barking-dog"));
      expect(bindFlashSpy).toHaveBeenCalled();
    });
  });
});
