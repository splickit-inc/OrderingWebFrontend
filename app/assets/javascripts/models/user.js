var User = (function() {
  function User(_params) {
    if (_params != undefined) {
      this.points = _params.points;
    }
  }

  User.prototype.addPoints = function(points) {
    return this.points = this.points * 1 + points * 1;
  };

  User.prototype.subtractPoints = function(points) {
    return this.points = this.points - points;
  };

  User.prototype.isLoyal = function() {
    return this.points !== undefined;
  };

  User.prototype.hasEnoughPoints = function(itemPrice) {
    return itemPrice <= this.points;
  };

  return User;

})();
