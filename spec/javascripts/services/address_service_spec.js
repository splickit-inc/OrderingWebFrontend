describe("AddressService", function() {  

  var addressService = null;
  var cookieName = "userPrefs";
	
  beforeEach(function() {
		var cookie = $.cookie();
    	for(var key in cookie) {
    		$.removeCookie(key);
    	}
    	    
  	addressService = new AddressService();
  	spyOn(addressService, 'cookieName').and.returnValue(cookieName);
  });

  afterEach(function() {
    var cookie = $.cookie();
    for(var key in cookie) {
      $.removeCookie(key);
    }
  });
	
  describe("#getPreferredAddress", function() {
    it("should return undefined if no cookie is found", function() {
    	spyOn(addressService, 'getCookie').and.returnValue(undefined);
    	expect(addressService.getPreferredAddress()).toBeUndefined();
    });
    
    it("should return undefined if no preferredAddressId field is found", function() {
    	spyOn(addressService, 'getCookie').and.returnValue("{}");
    	expect(addressService.getPreferredAddress()).toBeUndefined();      
    });
    
    it("should return the stored preferredAddressId field", function() {
    	spyOn(addressService, 'getCookie').and.returnValue("{\"preferredAddressId\": 3061}");
    	expect(addressService.getPreferredAddress()).toEqual(3061);      
    });
  });    
  
  describe("#storePreferredAddress", function() {
  	it("should create a new cookie if none exists", function() {
  		spyOn(addressService, 'getCookie').and.returnValue(undefined);
  		addressService.storePreferredAddress(34);
  		addressService.getCookie.and.callThrough();
  		var readCookie = JSON.parse(addressService.getCookie());
  		expect(readCookie.preferredAddressId).toEqual(34);
  	});
  	
  	it("should overwrite the preferredAddressId field if one already exists", function() {
  		spyOn(addressService, 'getCookie').and.returnValue("{\"preferredAddressId\": 579}");
  		addressService.storePreferredAddress(580);
  		addressService.getCookie.and.callThrough();
  		var readCookie = JSON.parse(addressService.getCookie());
  		expect(readCookie.preferredAddressId).toEqual(580);  		
  	});
  	
  	it("should persist the address for subsequent reads", function() {
  		spyOn(addressService, 'getCookie').and.returnValue("{}");
  		addressService.storePreferredAddress(580);
  		addressService.getCookie.and.callThrough();
  		var readCookie = JSON.parse(addressService.getCookie());
  		expect(readCookie.preferredAddressId).toEqual(580);  		  		
  	});
  });
});
