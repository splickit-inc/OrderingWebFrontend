describe("DeliveryModalController", function () {
  beforeEach(function () {
    window.user = new User();
    loadFixtures('delivery_dialog_view.html');
  });

  afterEach(function () {
    // Dialogs from the tests stay open if we don't do this
    Dialog.close_all();
  });

  describe("initialize", function () {
    it("should open dialog", function() {
      var dialogOpenSpy = spyOn(Dialog.prototype, "open");
      DeliveryModalController.initialize({});
      expect(dialogOpenSpy).toHaveBeenCalled();
    });

    it("should use the correct dialog html", function() {
      DeliveryModalController.initialize({});
      expect($('.addresses').length).toEqual(1);
    });

    it("should call handleDeleteClick", function() {
      window.addresses = [{ address1: "555 5th st",
                            address2: "",
                            city: "Boulder",
                            instructions: "",
                            phone_no: "5555555555",
                            state: "CO",
                            zip: "80304",
                            user_addr_id: "1234" }];
      var handleDeleteSpy = spyOn(DeliveryModalController, "handleDeleteClick");
      DeliveryModalController.initialize({});
      var e = jQuery.Event( "click" );
      $('aside .delivery').trigger("click");
      $("div.delete button").trigger(e);
      expect(handleDeleteSpy).toHaveBeenCalledWith(jasmine.any(Object), 1234);
    });

    describe("signed out user", function() {
      var redirectSpy;

      beforeEach(function() {
        redirectSpy = spyOn(DeliveryModalController, "redirect");
        window.user = undefined;
      });

      it("should not open dialog when user clicks on delivery button", function() {
        DeliveryModalController.initialize({ path: "/merchants/10223?order_type=delivery" });

        var dialogOpenSpy = spyOn(Dialog.prototype, "open");

        expect(dialogOpenSpy).not.toHaveBeenCalled();
      });

      it("should redirect to the sign in page with location parameter", function() {
        $("input#past_location").val("123");

        DeliveryModalController.initialize({ path: "/merchants/102237?order_type=delivery" });

        expect(redirectSpy).toHaveBeenCalledWith("/sign_in/?continue_path=%2F&query_location=123&query_delivery_path=%2Fmerchants%2F102237%3Forder_type%3Ddelivery");
      });

      it("should redirect to the sign in page without location parameter", function() {
        $("input#location").val("123");

        DeliveryModalController.initialize({ path: "/merchants/102237?order_type=delivery" });

        expect(redirectSpy).toHaveBeenCalledWith("/sign_in/?continue_path=%2F&query_delivery_path=%2Fmerchants%2F102237%3Forder_type%3Ddelivery");
      });
    });

    describe("sign in after delivery click", function() {
      var redirectSpy;

      beforeEach(function(){
        window.user = new User();
        window.addresses = [{address1: "555 5th st",
          address2: "",
          city: "Boulder",
          instructions: "",
          phone_no: "5555555555",
          state: "CO",
          zip: "80304",
          user_addr_id: "1234"}];
        redirectSpy = spyOn(DeliveryModalController, "redirect");
      });

      it("should display delivery modal", function(){
        var dialogOpenSpy = spyOn(Dialog.prototype, "open");
        DeliveryModalController.initialize({ path: "/merchants/102237?order_type=delivery" });
        expect(dialogOpenSpy).toHaveBeenCalled();
      });

      it("should set modal button to merchant path", function() {
        DeliveryModalController.initialize({ path: "/merchants/102237?order_type=delivery" });
        expect($(".set-btn").length).toEqual(1);
        expect($(".set-btn").data("merchant-path")).toEqual("/merchants/102237?order_type=delivery");
      });

      it("should redirect to merchant path", function() {
        DeliveryModalController.initialize({ path: "/merchants/102237?order_type=delivery" });
        $(".set-btn").trigger("click");
        expect(redirectSpy).toHaveBeenCalledWith("/merchants/102237?order_type=delivery&user_addr_id=1234");
      });
    });
  });

  describe("#handleDeleteClick", function() {
    beforeEach(function(){
      window.user = new User();
      window.addresses = [{ address1: "555 5th st",
                            address2: "",
                            city: "Boulder",
                            instructions: "",
                            phone_no: "5555555555",
                            state: "CO",
                            zip: "80304",
                            user_addr_id: "1234" }];
    });

    it("should call showDeleteAddress and open a dialog", function() {
      var showDeleteAddressSpy = spyOn(UsersAddressController.prototype, "showDeleteAddress").and.callThrough();
      var dialogSpy = spyOn(Dialog.prototype, "openMultiple").and.callThrough();
      DeliveryModalController.initialize({});
      $('aside .delivery').trigger("click");
      $("div.delete button").trigger("click");
      expect(showDeleteAddressSpy).toHaveBeenCalledWith(1234);
      expect(dialogSpy).toHaveBeenCalled();
    });

    it("should attach loading event and call setAjaxEvent", function() {
      var onSpy = spyOn($.fn, "click");
      var setAjaxEventSpy = spyOn(DeliveryModalController, "setAjaxEvent");
      DeliveryModalController.initialize({});
      $('aside .delivery').trigger("click");
      $("div.delete button").trigger("click");
      expect(onSpy).toHaveBeenCalled();
      expect(setAjaxEventSpy).toHaveBeenCalled();
    });

    it("should show loading page when YES button is clicked", function() {
      var showSpy = spyOn(loadingPage, "show");
      DeliveryModalController.initialize({});
      $('aside .delivery').trigger("click");
      $("div.delete button").trigger("click");
      $("div#delivery-address button[data-delete='yes']").trigger("click");
      expect(showSpy).toHaveBeenCalled();
    });
  });

  describe("#setAjaxEvent", function() {
    beforeEach(function(){
      window.user = new User();
      window.addresses = [{ address1: "555 5th st",
        address2: "",
        city: "Boulder",
        instructions: "",
        phone_no: "5555555555",
        state: "CO",
        zip: "80304",
        user_addr_id: "1234" }];
    });

    it("should attach submit", function() {
      var onSpy = spyOn($.fn, "submit");
      DeliveryModalController.initialize({});
      $('aside .delivery').trigger("click");
      $("div.delete button").trigger("click");
      expect(onSpy).toHaveBeenCalled();
    });
  });

  describe("#deleteAddress", function(){
    beforeEach(function(){
      window.user = new User();
      window.addresses = [{ address1: "555 5th st",
        address2: "",
        city: "Boulder",
        instructions: "",
        phone_no: "5555555555",
        state: "CO",
        zip: "80304",
        user_addr_id: "1234" }];
    });

    it("should remove an address", function() {
      DeliveryModalController.initialize({});
      var e = jQuery.Event("click", { target: $("div.delete button")[0] });
      $('aside .delivery').first().trigger("click");
      expect(window.addresses.length).toEqual(1);
      expect($("div#select-address div.addresses div.bordered").length).toEqual(1);
      $("div.delete button").first().trigger(e);
      DeliveryModalController.deleteAddress(e, "1234");
      expect(window.addresses.length).toEqual(0);
      expect($("div#select-address div.addresses div.bordered").length).toEqual(0);
    });
  });

  describe("handleSetClick", function() {
    var redirectSpy;
    beforeEach(function() {
      window.user = new User();
      window.addresses = [{address1: "555 5th st",
        address2: "",
        city: "Boulder",
        instructions: "",
        phone_no: "5555555555",
        state: "CO",
        zip: "80304",
        user_addr_id: "1234"}];
      redirectSpy = spyOn(DeliveryModalController, 'redirect');
    });

    it("should redirect user to href specified on delivery link", function() {
      DeliveryModalController.initialize({ path: $('.delivery.button').attr('href') });
      $('aside .delivery').trigger('click');
      $('.set-btn').trigger('click');
      var href = $('.delivery.button').attr('href');
      expect(redirectSpy).toHaveBeenCalledWith(href + "&user_addr_id=1234");
    });

    it("should store the preferred address id in the cookie", function() {
      var storeSpy = spyOn(AddressService.prototype, 'storePreferredAddress');
      DeliveryModalController.initialize({});
      $('aside .delivery').trigger('click');
      $('.set-btn').trigger('click');
      expect(storeSpy).toHaveBeenCalled();
    });
  });

  describe("handleAddNewAddressClick", function() {
    var redirectSpy;
    beforeEach(function() {
      window.user = new User();
      window.addresses = [{address1: "555 5th st",
        address2: "",
        city: "Boulder",
        instructions: "",
        phone_no: "5555555555",
        state: "CO",
        zip: "80304",
        user_addr_id: "1234"}];
      redirectSpy = spyOn(DeliveryModalController, 'redirect');
    });

    it("should redirect user to add new address form ", function() {
      DeliveryModalController.initialize({ path: "/merchants/102237?order_type=delivery"});
      $('aside .delivery').trigger('click');
      $('.new-address-btn').trigger('click');
      expect(redirectSpy).toHaveBeenCalledWith("/user/address/new?path=%2Fmerchants%2F102237%3Forder_type%3Ddelivery");
    });
  });
});
