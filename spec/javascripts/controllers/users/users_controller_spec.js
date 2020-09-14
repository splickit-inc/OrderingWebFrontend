describe("UsersShowController", function() {
  var controller;
  beforeEach(function() {
    controller = new UsersShowController(new AddressService());
  });

  describe("updatePreferredAddress", function() {
    it("should store the preferred address", function() {
      var addressServiceSpy = spyOn(AddressService.prototype, "storePreferredAddress");
      controller.updatePreferredAddress(42);
      expect(addressServiceSpy).toHaveBeenCalledWith(42);
    });
  });
});
