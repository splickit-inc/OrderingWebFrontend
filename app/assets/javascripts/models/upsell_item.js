var UpsellItem,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) {
    for (var key in parent) {
      if (__hasProp.call(parent, key))
        child[key] = parent[key];
    }

    function ctor() {
      this.constructor = child;
    }

    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype;
    return child;
  };

UpsellItem = (function(_super) {
  __extends(UpsellItem, _super);

  function UpsellItem() {
    return UpsellItem.__super__.constructor.apply(this, arguments);
  };

  UpsellItem.prototype.toMinParams = function() {
    return {
      item_id: this.item_id,
      item_name: this.item_name,
      total_price: this.totalPrice()
    };
  };

  return UpsellItem;
})(MenuItem);
