describe("UsersOrdersHistoryController", function() {
  beforeEach(function () {
    window.orders = {};
    window.orders["6923234"] = new Order(get_order());
    loadFixtures('add_favorite_dialog_view.html');
  });

  afterEach(function () {
    Dialog.close_all();
  });

  describe("setEvents", function() {
    beforeEach(function() {
      window.user = new User();
    });

    it("attach click events to all add-favorite buttons", function(){
      var handleClickSpy = spyOn(AddFavoriteModalController, "initialize");
      new UsersOrdersHistoryController();
      $("button.add-favorite").trigger('click');
      expect(handleClickSpy).toHaveBeenCalledWith(6923234);
    });

    it("attach click events to a order's row", function(){
      var handleClickSpy = spyOn(OrderSummaryModalController, "initialize");
      new UsersOrdersHistoryController();
      $("div#order-data td:not(.add-favorite-button)").trigger('click');
      expect(handleClickSpy).toHaveBeenCalledWith(6923234);
    });

    it("attach touch events to a order's row", function (){
      var handleTouchSpy = spyOn($.fn, "addClass");
      new UsersOrdersHistoryController();
      $("div#order-data td:not(.add-favorite-button)").trigger('touchstart');
      expect(handleTouchSpy).toHaveBeenCalledWith("select");

      var handleTouchSpy = spyOn($.fn, "removeClass");
      new UsersOrdersHistoryController();
      $("div#order-data td:not(.add-favorite-button)").trigger('touchend');
      expect(handleTouchSpy).toHaveBeenCalledWith("select");
    });
  });

  describe("setEventsInErrors", function (){
    beforeEach(function() {
      window.user = new User();
    });

    it("show alert when order is not especified", function(){
      var alertSpy = spyOn(window, "alert");
      new UsersOrdersHistoryController();
      $("button.add-favorite").remove();
      $("div#order-data td:not(.add-favorite-button)").trigger("click");
      expect(alertSpy).toHaveBeenCalledWith("Order ID missing");
    });
  });
});