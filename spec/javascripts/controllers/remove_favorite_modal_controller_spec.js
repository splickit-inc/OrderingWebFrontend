describe("RemoveFavoriteModalController", function() {
  beforeEach(function () {
    window.user = new User();
    loadFixtures('remove_favorite_dialog_view.html');
  });

  afterEach(function () {
    Dialog.close_all();
  });

  describe("showDeleteFavoriteModal", function() {
    it("should open dialog on initialize", function(){
      var dialogOpenSpy = spyOn(Dialog.prototype, "open");
      RemoveFavoriteModalController.initialize("232430");
      expect($('.remove-favorite').length).toEqual(2);
      $('.remove-favorite').first().trigger("click");
      expect($(".modal-btn-remove-favorite-yes").length).toEqual(1);
      expect($(".modal-btn-remove-favorite-yes").text()).toEqual("Yes");
      expect(dialogOpenSpy).toHaveBeenCalled();
    });
  });
});