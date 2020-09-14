describe("User", function() {
  describe("#constructor", function() {
    it("should initialize with the correct values", function() {
      var user = new User({points: 500});
      expect(user.points).toEqual(500);
    });

    it("doesn't blow up w/o params", function() {
      expect(function() {
        new ModifierItem()
      }).not.toThrow();
    });
  });

  describe("#addPoints", function() {
    it("should add points (number)", function() {

      var user = new User({points: 500});

      expect(user.points).toEqual(500);
      user.addPoints(22);
      expect(user.points).toEqual(522);

    });

    it("should add points (string)", function() {

      var user = new User({points: 500});

      expect(user.points).toEqual(500);
      user.addPoints("22");
      expect(user.points).toEqual(522);

    });
  });

  describe("#subtractPoints", function() {
    it("should subtract points", function() {

      var user = new User({points: 500});

      expect(user.points).toEqual(500);
      user.subtractPoints(22);
      expect(user.points).toEqual(478);

    });
  });

  describe("#isLoyal", function() {
    it("should return true if points exist", function() {
      var user = new User({points: 500});
      expect(user.isLoyal()).toEqual(true);
    });
  });

  describe("#hasEnoughPoints", function() {
    it("should return false if points don't exist", function() {
      var user = new User();
      expect(user.isLoyal()).toEqual(false);
    });
  });

  describe("#hasEnoughPoints", function() {
    it("should return true if the user has enough points", function() {
      var user = new User({points: 200});
      expect(user.hasEnoughPoints(10)).toEqual(true);
    });

    it("should return false if the user doesn't has enough points", function() {
      var user = new User({points: 2});
      expect(user.hasEnoughPoints(10)).toEqual(false);
    });
  });
});
