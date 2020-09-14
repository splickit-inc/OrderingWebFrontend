describe("GoogleAnalyticsService", function() {
	var gaSpy;
	ga = function() {};
  beforeEach(function() {
  	gaSpy = spyOn(window, "ga");
  });
	
  describe("#track", function() {
    it("should call ga with the proper arguments", function() {
    	GoogleAnalyticsService.track("alpha", "beta", "gamma", "delta");
    	expect(gaSpy).toHaveBeenCalledWith("send", "event", "alpha", "beta", "gamma", "delta");
    });
  });    
});