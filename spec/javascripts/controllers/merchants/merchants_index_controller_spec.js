describe("MerchantsIndexController", function () {
  beforeEach(function() {
    window.mapBoxAvailable = true;
  });

  describe("#buttonAction", function() {
    beforeEach(function() {
      loadFixtures("index.html");
    });

    afterEach(function() {
      Dialog.close_all();
    });

    // TODO: Create a function to redirect on application js, jasmine can not stub window functions
    pending("when different merchant w/ items in cart", function() {
      it("should preventDefault", function() {

        var event = { preventDefault: {}, target: {} };
        event.target.outerHTML = '<a class="delivery button" data-merchant-id="102299" data-merchant-name="Hayden" href="/merchants/102299?order_type=delivery">Delivery</a>';
        var preventDefaultSpy = spyOn(event, "preventDefault");
        MerchantsIndexController.buttonAction(event, "pickup");
        expect(preventDefaultSpy).toHaveBeenCalled();
      });

      it("should open the merchant change dialog", function() {
        var event = { preventDefault: jasmine.createSpy(), target: {} };
        event.target.outerHTML = '<a class="delivery button" data-merchant-id="102299" data-merchant-name="Hayden" href="/merchants/102299?order_type=delivery">Delivery</a>';
        var openDialogSpy = spyOn(MerchantsChangeController, "openDialog");
        MerchantsIndexController.buttonAction(event, "pickup");
        expect(openDialogSpy).toHaveBeenCalledWith(jasmine.any(Object));
      });
    });

    describe("when menuType is delivery", function() {
      it("should handle the delivery click", function() {
        var event = { target: {} };
        event.target.outerHTML = '<a class="delivery button" data-merchant-id="102237" data-merchant-name="Hayden" href="/merchants/102299?order_type=delivery">Delivery</a>';
        var handleDeliveryClickSpy = spyOn(DeliveryModalController, "initialize");
        MerchantsIndexController.buttonAction(event, "delivery");
        expect(handleDeliveryClickSpy).toHaveBeenCalled();
      });
    });
  });

  describe('#index', function () {
    var mapsControllerSpy;

    beforeEach(function () {
      loadFixtures('map_view.html');
      mapsControllerSpy = spyOn(window, 'MapsController');
    });

    it("calls delivery modal controller on modal display", function() {
      var deliverySpy = spyOn(DeliveryModalController, "initialize");
      new MerchantsIndexController().index({ deliveryPath: "/merchants/102237?order_type=delivery" });
      expect(deliverySpy).toHaveBeenCalledWith({ path: "/merchants/102237?order_type=delivery" });
    });

    it("calls buttonAction on delivery click", function() {
      window.merchants_json = {};
      var buttonControllerSpy = spyOn(MerchantsIndexController, "buttonAction");
      new MerchantsIndexController().index();
      $('.delivery.button').click();
      expect(buttonControllerSpy).toHaveBeenCalledWith(jasmine.any(Object), 'delivery');
    });

    it("calls buttonAction on pickup click", function() {
      window.merchants_json = {};
      // spyOn(window, 'MapsController');
      var buttonControllerSpy = spyOn(MerchantsIndexController, "buttonAction");
      new MerchantsIndexController().index();
      $('.pickup.button').click();
      expect(buttonControllerSpy).toHaveBeenCalledWith(jasmine.any(Object), 'pickup');
    });

    it("tracks user events", function () {
      window.merchants_json = {};

      spyOn(MerchantsIndexController, 'buttonAction');

      var gaSpy = spyOn(GoogleAnalyticsService, 'track');

      new MerchantsIndexController().index();
      $('.delivery.button').click();
      expect(gaSpy).toHaveBeenCalledWith('merchants', 'showMenu', 'delivery');

      $('.pickup.button').click();
      expect(gaSpy).toHaveBeenCalledWith('merchants', 'showMenu', 'pickup');
    });

    it("creates a maps controller with the correct merchants json", function () {
      window.merchants_json = [
        {
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
          "brand": "Pita Pit",
          "phone_no": "6666666666"
        }
      ];

      new MerchantsIndexController().index();
      expect(mapsControllerSpy).toHaveBeenCalledWith({
        merchantsData: [{
          latitude: '40.014848',
          longitude: '-105.274258',
          content: "<div class='info-window delivery'> <h3>Pita Pit</h3> <p>1509 Arapahoe Ave, Boulder, CO 80302</p> <p>(666) 666-6666</p> <figure class='buttons'> <a class='delivery button' href='/merchants/1080?order_type=delivery' data-merchant-id='1080' data-merchant-name='Boulder'> Delivery </a> <a class='pickup button' href='/merchants/1080?order_type=pickup' data-merchant-id='1080' data-merchant-name='Boulder'> Pickup </a> </figure> </div>"
        }]
      });
    });

    it("should set order data variables", function () {
      loadFixtures("index.html");

      new MerchantsIndexController().index();
      expect(MerchantsIndexController.itemCount).toEqual(1);
      expect(MerchantsIndexController.activeMerchantID).toEqual(102237);
      expect(MerchantsIndexController.activeCateringOrder).toBeFalsy();
    });
  });

  describe("#getCateringPath", function () {
    it("should return menu path if there is an active catering order without different merchants", function () {
      MerchantsIndexController.activeMerchantID = 1;
      MerchantsIndexController.activeCateringOrder = true;

      expect(MerchantsIndexController.getCateringPath(1, "pickup")).toEqual("/merchants/1?order_type=pickup&catering=1");
    });

    it("should return new catering path if there isn't an active catering order or there are different merchants", function () {
      MerchantsIndexController.activeMerchantID = 2;
      MerchantsIndexController.activeCateringOrder = true;

      expect(MerchantsIndexController.getCateringPath(1, "pickup")).toEqual("/caterings/new?merchant_id=1&order_type=pickup");

      MerchantsIndexController.activeMerchantID = 1;
      MerchantsIndexController.activeCateringOrder = false;

      expect(MerchantsIndexController.getCateringPath(1, "pickup")).toEqual("/caterings/new?merchant_id=1&order_type=pickup");
    });
  });

  describe("#getOrderRedirectPath", function () {
    beforeEach(function () {
      loadFixtures("index.html");
    });

    it("should return catering path if catering selected", function () {
      $("input[type='checkbox'][data-merchant-id='102237'].checkbox-catering").prop("checked", true);

      expect(MerchantsIndexController.getOrderRedirectPath(102237, "pickup"))
        .toEqual("/caterings/new?merchant_id=102237&order_type=pickup");
    });

    it("should return group order path if group order selected", function () {
      $("input[type='checkbox'][data-merchant-id='102237'].checkbox-group-order").prop("checked", true);

      expect(MerchantsIndexController.getOrderRedirectPath(102237, "pickup"))
        .toEqual("/group_orders/new?merchant_id=102237&order_type=pickup");
    });

    it("should return standard path if normal order is selected", function () {
      expect(MerchantsIndexController.getOrderRedirectPath(1, "pickup")).toEqual("/merchants/1?order_type=pickup");
    });
  });

  describe("caterings option checked", function (){
    beforeEach(function() {
      loadFixtures("index.html");
      $('.checkbox-catering').attr('checked', 'checked');
    });

    afterEach(function() {
      Dialog.close_all();
    });

    it("should checked the checkbox of caterings ", function(){
      expect($('.checkbox-catering').is(':checked')).toBeTruthy()
    });

    // TODO: Create a function to redirect on application js, jasmine can not stub window functions
    pending("catering", function() {
      it("should have been called with caterings order type pickup", function() {
        var event = { preventDefault: {}, target: {} };
        event.target.outerHTML = '<a class="delivery button" data-merchant-id="102299" data-merchant-name="Hayden" href="/merchants/102299?order_type=delivery">Pickup</a>';
        var preventDefaultSpy = spyOn(event, "preventDefault");
        MerchantsIndexController.buttonAction(event, "pickup");
        expect(preventDefaultSpy).toHaveBeenCalledWith("/caterings/new?merchant_id=102299&order_type=pickup");
      });

      it("should have been called with caterings order type delivery", function() {
        var event = { preventDefault: jasmine.createSpy(), target: {} };
        event.target.outerHTML = '<a class="delivery button" data-merchant-id="102299" data-merchant-name="Hayden" href="/merchants/102299?order_type=delivery">Delivery</a>';
        var openDialogSpy = spyOn(MerchantsChangeController, "openDialog");
        MerchantsIndexController.buttonAction(event, "delivery");
        expect(openDialogSpy).toHaveBeenCalledWith("/caterings/new?merchant_id=102299&order_type=delivery");
      });
    });
  });
});
