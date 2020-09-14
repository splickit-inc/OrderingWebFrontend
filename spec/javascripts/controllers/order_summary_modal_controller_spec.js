describe("OrderSummaryModalController", function() {
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
      OrderSummaryModalController.initialize("6923234");
      expect(dialogOpenSpy).toHaveBeenCalled();
    });

    it("should use the correct dialog html", function(){
      OrderSummaryModalController.initialize("6923234");
      expect($("div.order-summary").length).toEqual(2);
      expect($("form.new_user_favorite").length).toEqual(1);
      expect($("div.order-summary table#items tr").length).toEqual(2);
      expect($("table#amounts tr#subtotal").length).toEqual(1);
      expect($("table#amounts tr#tax").length).toEqual(1);
      expect($("table#amounts tr#tip").length).toEqual(1);
      expect($("div.add-favorite-summary").length).toEqual(1);
    });
  });
});