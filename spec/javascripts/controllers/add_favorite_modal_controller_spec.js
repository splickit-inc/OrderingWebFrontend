describe("AddFavoriteModalController", function() {
  beforeEach(function () {
    window.orders = {};
    window.orders["6923234"] = new Order(get_order());
    loadFixtures('add_favorite_dialog_view.html');
  });

  afterEach(function () {
    Dialog.close_all();
  });

  describe("initAddFavoriteModal", function() {
    beforeEach(function() {
      window.user = new User();
    });
    it("should open dialog on initialize", function(){
      var dialogOpenSpy = spyOn(Dialog.prototype, "open");
      AddFavoriteModalController.initialize("6923234");
      expect(dialogOpenSpy).toHaveBeenCalled();
    });

    it("should use the correct dialog html", function(){
      AddFavoriteModalController.initialize("6923234");
      expect($("#save-favorite").length).toEqual(1);
    });
  });
});