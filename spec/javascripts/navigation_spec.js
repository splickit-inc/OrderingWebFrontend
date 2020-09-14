describe("Navigation", function() {
  beforeEach(function() {
    window.user = new User();
    loadFixtures('navigation.html');
  });

  describe("#show_order_dialog", function() {
    var showSpy,
        navigation,
        orderServiceSpy;

    beforeEach(function() {
      showSpy = spyOn(Navigation.prototype, "show_order_dialog").and.callThrough();
      orderServiceSpy = spyOn(OrderService.prototype, "show");
      navigation = new Navigation();
      $("div.order").click(navigation.show_order_dialog);
    });

    it("should call show_order_dialog", function() {
      $("div.order").trigger("click");
      expect(showSpy).toHaveBeenCalled();
    });

    it("should call orderService show", function() {
      $("div.order").trigger("click");
      expect(orderServiceSpy).toHaveBeenCalled();
    });
  });

  describe("#calculate_logo", function () {
    beforeEach(function () {
      Navigation.calculate_logo();
    });

    it("logo should be defined", function () {
      expect($("body a.logo img")).toBeDefined()
    });

    it("logo naturalWidth and naturalHeight should not undefined", function () {
      expect($("a.logo img").prop('naturalWidth')).not.toBe('undefined');
      expect($("a.logo img").prop('naturalHeight')).not.toBe('undefined');
    });

    it("logo should have width and height major to 0", function () {
      expect($("a.logo img").width).not.toBeLessThan(0);
      expect($("a.logo img").height).not.toBeLessThan(0);
    });
  });

  describe("#my_order_callback", function() {
    afterEach(function() {
      Dialog.close_all();
    });

    it("should call data", function() {
      var dataSpy = spyOn($.fn, "data");
      new Navigation().my_order_callback({ order: [] });
      expect(dataSpy).toHaveBeenCalledWith("route");
    });

    describe("merchant menu page", function() {
      var response = {};

      beforeEach(function() {
        $("body").data("route", "merchants/show");
        response = {
          order: {
            items: [ 1, 2, 3 ]
          }
        };
      });

      afterEach(function() {
        $("body").data("route", "");
      });

      it("should call openMyOrder", function() {
        var openMyOrderSpy = spyOn(MyOrderController, "openMyOrder");
        new Navigation().my_order_callback(response);
        expect(openMyOrderSpy).toHaveBeenCalledWith(response);
      });
    });

    describe("other page besides of merchant menu page", function() {
      beforeEach(function() {
        $("body").data("route", "merchants/index");
      });

      afterEach(function() {
        $("body").data("route", "");
      });

      describe("items > 0", function() {
        var response = {};

        beforeEach(function () {
          response = {
            order: {
              items: [ 1, 2, 3 ],
              meta: {
                skin_name: "moes",
                merchant_name: "name",
                merchant_id: 123,
                order_type: "pickup"
              }
            }
          };
        });

        it("should call merchantMenuPath", function () {
          spyOn(Dialog, "redirect");
          var activeSpy = spyOn(MyOrderController, "merchantMenuPath");
          new Navigation().my_order_callback(response);
          expect(activeSpy).toHaveBeenCalledWith(response.order.meta);
        });

        it("should call Dialog's redirect", function() {
          var redirectSpy = spyOn(Dialog, "redirect");
          new Navigation().my_order_callback(response);
          expect(redirectSpy).toHaveBeenCalledWith("/merchants/123?order_type=pickup&my_order=1");
        });
      });

      describe("items 0", function() {
        var response = {};

        beforeEach(function() {
          response = {
            order: {
              items: []
            }
          };
        });

        it("should call openMyOrder", function() {
          var openMyOrderSpy = spyOn(MyOrderController, "openMyOrder");
          new Navigation().my_order_callback(response);
          expect(openMyOrderSpy).toHaveBeenCalledWith(response)
        });
      });
    });
  });
});
