describe("Application", function() {
	describe("Number", function() {
		describe("#to_s", function() {
			it("should work for positive integers", function() {
				var n = 42;
				expect(n.to_s()).toEqual("42");
			});
			
			it("should work for negative integers", function() {
				var n = -42;
				expect(n.to_s()).toEqual("-42");
			});
			
			it("should work for positive decimals", function() {
				var n = 1.756;
				expect(n.to_s()).toEqual("1.756");
				
				n = 0.4449;
				expect(n.to_s()).toEqual("0.4449");
			});
			
			it("should work for negative decimals", function() {
				var n = -22.183;
				expect(n.to_s()).toEqual("-22.183");
				
				n = -0.00006;
				expect(n.to_s()).toEqual("-0.00006");
			});
			
			it("should work for zero", function() {
				var n = 0;
				expect(n.to_s()).toEqual("0");
				
				n = 0.000;
				expect(n.to_s()).toEqual("0");
			});
			
			it("should work for NaN", function() {
				var n = NaN;
				expect(n.to_s()).toEqual("NaN");
			});
		});
	});
	
	describe("String", function() {
		describe("#to_n", function() {
			it("should work for positive integers", function() {
				var s = "42";
				expect(s.to_n()).toEqual(42);
			});
			
			it("should work for negative integers", function() {
				var s = "-42";
				expect(s.to_n()).toEqual(-42);
			});
			
			it("should work for positive decimals", function() {
				var s = "1.756";
				expect(s.to_n()).toEqual(1.756);
				
				s = "0.4449";
				expect(s.to_n()).toEqual(0.4449);
			});
			
			it("should work for negative decimals", function() {
				var s = "-22.183";
				expect(s.to_n()).toEqual(-22.183);
				
				s = "-0.00006";
				expect(s.to_n()).toEqual(-.00006);
			})
			
			it("should work for zero", function() {
				var s = "0";
				expect(s.to_n()).toEqual(0);
				
				s = "0.000";
				expect(s.to_n()).toEqual(0);
			});
			
			it("should return NaN for nonnumeric strings", function() {
				var s = "";
				expect(s.to_n()).toBeNaN();
				s = "Not a number";
				expect(s.to_n()).toBeNaN();
				s = "1.44abc44";
				expect(s.to_n()).toBeNaN();
				s = "abc1.55";
				expect(s.to_n()).toBeNaN();
				s = "1.6666abc";
				expect(s.to_n()).toBeNaN();
			});
		});
		describe("#to_i", function() {
			it("should work for any String natural", function() {
				var s = "1";
				expect(s.to_i()).toEqual(1);
			});

			it("should work for any String decimal and round it", function() {
				var s = "1.5";
				expect(s.to_i()).toEqual(2);
				var s = "1.4";
				expect(s.to_i()).toEqual(1);
			});

			it("should return 0 for nonnumeric strings", function() {
				var s = "";
				expect(s.to_i()).toEqual(0);
				s = "Not a number";
				expect(s.to_i()).toEqual(0);
				s = "1.44abc44";
				expect(s.to_i()).toEqual(0);
				s = "abc1.55";
				expect(s.to_i()).toEqual(0);
				s = "1.6666abc";
				expect(s.to_i()).toEqual(0);
			});
		});
	});
});
