describe("UsersAddressController", function() {
  beforeEach(function () {
    window.user = new User();
    loadFixtures('delivery_address_list.html');
  });

  afterEach(function () {
    Dialog.close_all();
  });

  describe("#showDeleteAddressDialog", function() {
    it("should open dialog when user clicks on delete-address button", function() {
      var dialogOpenSpy = spyOn(UsersAddressController.prototype, "showDeleteAddress");
      new UsersAddressController();
      $("button.delete-address").first().trigger('click');
      expect(dialogOpenSpy).toHaveBeenCalled();
    });

    it("should call dialog multiple open", function() {
      var dialogMultipleOpenSpy = spyOn(Dialog.prototype, "openMultiple");
      new UsersAddressController();
      $("button.delete-address").first().trigger('click');
      expect(dialogMultipleOpenSpy).toHaveBeenCalled();
    });

    it("should use the correct dialog html", function(){
      new UsersAddressController();
      $("button.delete-address").first().trigger("click");

      expect($("div[data-dialog-header] h1").text()).toContain("Delete delivery address");
      expect($("form div[data-dialog-content]").text()).toContain("Are you sure delete delivery address?");
      expect($("div[data-dialog-footer] button.btn-delete-usr-addr").length).toEqual(1);
      expect($("div[data-dialog-footer] a").length).toEqual(1);
      expect($("div[data-dialog-footer] button.btn-delete-usr-addr.primary").text()).toEqual("Yes");
    });

  });
});