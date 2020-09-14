describe("loadingPage", function() {
  beforeEach(function() {
    loadFixtures('checkouts_view.html');
  });

  describe("#show", function() {
    it("should show loading page", function(){
      loadingPage.show();
      expect($("div#loading-page:not(:hidden)").length).toEqual(1);
      loadingPage.hide();
    });

    it("should show loading page with params", function() {
      var test = jasmine.createSpy("test");
      loadingPage.show({ callback: test });
      expect(test).toHaveBeenCalled();
      expect($("div#loading-page:not(:hidden)").length).toEqual(1);
      loadingPage.hide();
    });

    it("should show loading page in Safari with params", function() {
      navigator.__defineGetter__('userAgent', function(){
        return "safari";
      });
      loadingPage.show({ callback: window.location.reload });
      expect($("div#loading-page:not(:hidden)").length).toEqual(1);
      loadingPage.hide();
    });
  });

  describe("#hide", function() {
    it("should hide loading page", function(){
      loadingPage.show();
      loadingPage.hide();
      expect($("div#loading-page:hidden").length).toEqual(1);
    });
  });

  describe("#hook", function() {
    it("should attach events", function() {
      var clickSpy = spyOn($.fn, "click");
      loadingPage.hook();
      expect(clickSpy).toHaveBeenCalled();
    });
  });
});