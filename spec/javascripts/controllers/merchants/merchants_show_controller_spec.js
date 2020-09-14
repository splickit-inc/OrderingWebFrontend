describe("MerchantsShowController", function() {
  describe('#show', function () {
    var params = {};

    beforeEach(function () {
      loadFixtures('merchants_show_view.html');
      window.merchant_json = {
        "merchant_id": "1080",
        "lat": "40.014848",
        "lng": "-105.274258",
        "name": "Boulder",
        "display_name": "Boulder",
        "address1": "1509 Arapahoe Ave",
        "city": "Boulder",
        "state": "CO",
        "zip": "80302",
        "delivery": "Y",
        "brand": "",
        "phone_no": "6666666666"
      };

      var favorite_spy = jasmine.createSpyObj("favorite", ["totalPrice"]);
      favorite_spy.totalPrice.and.returnValue((2).toFixed(2));

      window.favoriteItems['232430']['1'] = favorite_spy;
      window.favoriteItems['232430']['2'] = favorite_spy;

      var last_order_spy = jasmine.createSpyObj("last_order", ["totalPrice"]);
      last_order_spy.totalPrice.and.returnValue((6.45).toFixed(2));

      window.lastOrderItems['11650492']['1'] = last_order_spy;
    });

    it("initializes map controller and menu", function () {
      var menu_spy = jasmine.createSpyObj("menu", ["initialize"]);
      spyOn(window, "Menu").and.returnValue(menu_spy);
      new MerchantsShowController().show();
      expect(menu_spy.initialize).toHaveBeenCalled();
    });

    it("should initialize price of valid favorites", function() {
      new MerchantsShowController().show();
      expect($('.user-favorite .favorite-price').html()).toEqual("$4.00")
    });

    it("should initialize price of valid last order", function() {
      new MerchantsShowController().show();
      expect($('.user-lastorder .lastorder-price').html()).toEqual("$6.45")
    });

    describe("with params modal true", function() {
      beforeEach(function () {
        params = {
          modal: true
        };
      });

      it("should call orderService show", function() {
        var orderServiceSpy = spyOn(OrderService.prototype, "show");
        new MerchantsShowController().show(params);
        expect(orderServiceSpy).toHaveBeenCalledWith(MyOrderController.openMyOrder);
      });
    });

    describe("without params modal false", function() {
      beforeEach(function () {
        params = {
          modal: false
        };
      });

      it("should not call orderService show", function() {
        var orderServiceSpy = spyOn(OrderService.prototype, "show");
        new MerchantsShowController().show(params);
        expect(orderServiceSpy).not.toHaveBeenCalled();
      });
    });

    describe("click handlers", function() {
      beforeEach(function() {
        var menu_spy = jasmine.createSpyObj("menu", ["initialize"]);
        spyOn(window, "Menu").and.returnValue(menu_spy);
      });

      it("should call MenuItemsController if item is clicked on", function() {
        menu_items_controller_spy = spyOn(MenuItemsController, "show");
        new MerchantsShowController().show();

        $('.items article').first().click();
        expect(menu_items_controller_spy).toHaveBeenCalledWith({item: window.menuItems['287734'], user: window.user, groupOrder: false, edit: false});
      });

      describe("favorites", function() {
        it("should call Dialog addToOrder if favorite is clicked on", function() {
          var dialog_spy = jasmine.createSpyObj("dialog", ['addToOrder']);
          spyOn(window, "Dialog").and.returnValue(dialog_spy);
          new MerchantsShowController().show();

          $('.user-favorite h3').first().click();
          expect(dialog_spy.addToOrder).toHaveBeenCalledWith(window.favoriteItems['232430']);
        });
      });

      describe("last-order", function() {
        it("should call Dialog addToOrder if last order  is clicked on", function() {
          var dialog_spy = jasmine.createSpyObj("dialog", ['addToOrder']);
          spyOn(window, "Dialog").and.returnValue(dialog_spy);
          new MerchantsShowController().show();

          $('.user-lastorder h3').first().click();
          expect(dialog_spy.addToOrder).toHaveBeenCalledWith(window.lastOrderItems['11650492']);
        });
      });
    });

    describe("Menu nav bar", function() {
      pending();

      it("should expand nav bar at >640px", function() {

      });

      describe("collapsed", function() {
        it("should collapse nav bar at <=640px", function() {

        });

        it("should register click event on menu types", function() {

        });
      });
    });
  });
});
