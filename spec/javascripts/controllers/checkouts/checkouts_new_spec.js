describe("CheckoutsNew", function() {

  beforeEach(function() {
    loadFixtures('checkouts_view.html');
  });

  describe("#constructor", function() {
    it("should set up button's click event for submit", function(){
      var clickSpy = spyOn($.fn, "click");
      new CheckoutsNew();
      expect(clickSpy).toHaveBeenCalled();
    });

    it("sets up the form submission event handler", function() {
      var spy = spyOn($.fn, 'on');
      var checkout = new CheckoutsNew();
      expect(spy).toHaveBeenCalledWith('submit', checkout.submit_form);
    });

    it("should call loading hook", function(){
      var loadingSpy = spyOn(loadingPage, "hook");
      new CheckoutsNew();
      expect(loadingSpy).toHaveBeenCalled();
    });

    it("should show promo form ", function(){
      new CheckoutsNew({ errorMessage: "", showPromoForm: true });

      expect($("#discount-text").css("display")).toEqual("none");
      expect($("#discount-form").css("display")).toEqual("inline");
    });

  });

  describe("#create_form_submit", function(){
    it("should submit create form when button is clicked ", function(){
      var submitSpy = spyOn($.fn, "submit").and.returnValue(false);
      new CheckoutsNew();
      $("button#create_checkout_submit").trigger("click");
      expect(submitSpy).toHaveBeenCalled();
    });
  });

  describe("#submit_form", function(){
    it("should call submit form when there is a submit", function(){
      var submitSpy = spyOn(CheckoutsNew.prototype, "submit_form").and.returnValue(false);
      new CheckoutsNew();
      $("#details form#create_checkout_form").submit();
      expect(submitSpy).toHaveBeenCalled();
    });
  });

  describe("#format_price", function() {
    it("formats the price correctly", function() {
      var checkout = new CheckoutsNew();
      expect(checkout.format_price(13.75)).toEqual("$13.75");
      expect(checkout.format_price(5)).toEqual("$5.00");
      expect(checkout.format_price(6.66666)).toEqual("$6.67");
    });
  });

  describe("#tip_selected", function() {
    it("value for tip is correctly", function() {
      var checkout = new CheckoutsNew();
      expect(checkout.get_tip('13.75')).toEqual(13.75);
      expect(checkout.get_tip('0')).toEqual(0);
      expect(checkout.get_tip('')).toEqual(0);

      expect(checkout.get_tip(undefined)).toEqual(0);
      expect(checkout.get_tip("hello")).toEqual(0);
      expect(checkout.get_tip("2005/12/12")).toEqual(0);

    });
  });

  describe("#display_promo_form", function() {
    it("hides #discount-text", function() {
      var hideSpy = spyOn($.fn, 'hide');
      var checkout = new CheckoutsNew();
      checkout.display_promo_form();
      expect(hideSpy).toHaveBeenCalled();
    });

    it("shows #discount-form", function() {
      var showSpy = spyOn($.fn, 'show');
      var checkout = new CheckoutsNew();
      checkout.display_promo_form();
      expect(showSpy).toHaveBeenCalled();
    });
  });

  describe("checkout tip, time and note save", function(){
    beforeEach(function() {
      new CheckoutsNew();
    });

    it("save time value in cookie", function() {
      $("#time select").trigger("change");
      var time = $("#time select").children("option:selected").val();
      var cookie = JSON.parse($.cookie("orderDetail"));
      expect(time).toEqual(cookie.time);
    });

    it("save note value in cookie", function() {
      var e = $.Event("keyup");
      e.which = 37;
      $('#note').trigger(e);
      var note = $('#note').val();
      var cookie = JSON.parse($.cookie("orderDetail"));
      expect(note).toEqual(cookie.note);
    });

    it("save tip value in cookie", function() {
      $("#tip select").trigger("change");
      var tip = $('select#tip').children('option:selected').text();
      var cookie = JSON.parse($.cookie("orderDetail"));
      expect(cookie.tip).toEqual(tip);
    });
  });

  describe("#send_order_detail_on_apply_promocode", function(){
    it("sets up the form submission event handler", function(){
      var spy = spyOn($.fn, "on");
      var checkout = new CheckoutsNew();
      expect(spy).toHaveBeenCalledWith('submit', checkout.submit_summary_form);
    });
  });

  describe("ErrorModal actions", function() {
    var errorModalSpy;

    beforeEach(function() {
      errorModalSpy = spyOn(ErrorModalController, "initialize");
    });

    it("should call ErrorModal initialize", function() {
      new CheckoutsNew({ errorMessage: "Error message" });
      expect(errorModalSpy).toHaveBeenCalled();
    });

    it("should not call ErrorModal initialize", function() {
      new CheckoutsNew({ errorMessage: "" });
      expect(errorModalSpy).not.toHaveBeenCalled();
    });
  });

  describe("#update_total", function(){
    it("should call update total when there is a tip change", function(){
      var updateSpy = spyOn(CheckoutsNew.prototype, "update_total");
      new CheckoutsNew();
      $("#tip select").trigger("change");
      expect(updateSpy).toHaveBeenCalled();
    });
    it("should edit text of Place Order button", function(){
      spyOn(CheckoutsNew.prototype, "format_price").and.returnValue("$8.9");
      new CheckoutsNew();
      $("#tip select").trigger("change");
      expect($("#buttons button").text()).toEqual("Place order ($8.9)");
    });
  });

  describe("valueio secure form", function() {
    it("should show loading page", function() {
      var loadingShowSpy = spyOn(loadingPage, "show");
      spyOn($.fn, "submit");
      window.valueio_on_success();
      expect(loadingShowSpy).toHaveBeenCalled();
    });
  });
});
