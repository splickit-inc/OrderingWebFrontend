describe("DeleteCreditCardModalController", function() {
  beforeEach(function () {
    window.user = new User();
    loadFixtures('delete_credit_card_dialog_view.html');
  });

  afterEach(function () {
    Dialog.close_all();
  });

  describe("showDeleteFavoriteModal", function() {
    it("should open dialog on initialize", function(){
      var dialogOpenSpy = spyOn(Dialog.prototype, "open");
      DeleteCreditCardModalController.initialize("user_payments/new");
      expect($('.delete-credit_card').length).toEqual(1);
      $('.delete-credit_card').first().trigger("click");
      expect($(".modal-btn-delete-credit-card-yes").length).toEqual(1);
      expect($(".modal-btn-delete-credit-card-yes").text()).toEqual("Yes");
      expect(dialogOpenSpy).toHaveBeenCalled();
    });
  });
});
