var ModifierItem = (function () {
  function ModifierItem(params) {
    function toNumber(num) {
      if (num !== undefined) {
        return num.to_n();
      }
    }

    function formatName(name) {
      if (name && name.indexOf('=') > -1) {
        return name.replace('=', ', ');
      } else {
        return name;
      }
    }

    function safeBool(val) {
      if (typeof val == 'boolean') {
        return val;
      } else {
        return val === 'true';
      }
    }

    // TODO: init. model attrs. correctly server-side.
    if (params !== undefined) {
      this.modifier_item_id = toNumber(params.modifier_item_id);
      this.modifier_item_name = formatName(params.modifier_item_name);
      this.modifier_item_max = params.modifier_item_max;
      this.modifier_item_min = (params.modifier_item_min || 0); // TODO: set default server side
      this.modifier_item_pre_selected = safeBool(params.modifier_item_pre_selected);
      this.modifier_prices_by_item_size_id = (params.modifier_prices_by_item_size_id);
      this.basePrice = getPrice(this.modifier_prices_by_item_size_id);
      this.netPrice = this.basePrice;
      this.quantity = Number(params.quantity) || 0; //Default value 0
      this.exclusive = safeBool(params.exclusive);
      this.nestedItems = initializeNestedModifierItems(params.nestedItems || params.nested_items);
      this.defaultQuantity = this.quantity;
      this.modifier_item_calories = params.modifier_item_calories;

      // TODO: move to ruby model
      if (this.nestedItems !== undefined) {
        this.quantity = 0;
      }
    }

    function getPrice(modifier_prices_by_item_size_id) {
      if (modifier_prices_by_item_size_id && modifier_prices_by_item_size_id[0]) {
        return parseFloat(modifier_prices_by_item_size_id[0].modifier_price).toFixed(2);
      } else {
        return (0).toFixed(2);
      }
    }

    function initializeNestedModifierItems(nestedItems) {
      if (nestedItems != void(0)) {
        return _.map(nestedItems, function (nestedItem) {
          return new ModifierItem(nestedItem);
        })
      }
    }
  }

  ModifierItem.prototype.sizePrice = function (sizeID) {
    var sizePriceGroup = _.findWhere(this.modifier_prices_by_item_size_id, {
      size_id: sizeID
    });

    if (sizePriceGroup != undefined) {
      return sizePriceGroup.modifier_price;
    }
  };

  ModifierItem.prototype.hasNestedPrices = function (sizeID) {
    return _.any(this.nestedItems, function (nestedItem) {
      return nestedItem.sizePrice(sizeID) !== void 0;
    });
  };

  ModifierItem.prototype.hasAnAvailablePrice = function (sizeID) {
    if (this.nestedItems === void 0) {
      return this.basePrice !== void 0
    } else {
      return this.hasNestedPrices(sizeID);
    }
  };

  ModifierItem.prototype.resetQuantity = function () {
    this.quantity = this.defaultQuantity;
  };

  ModifierItem.prototype.costsExtra = function () {
    return this.netPrice > 0.00;
  };

  ModifierItem.prototype.oneMax = function () {
    if (this.modifier_item_max != undefined) {
      return this.modifier_item_max.to_n() === 1;
    }
  };

  ModifierItem.prototype.nineMax = function () {
    if (this.modifier_item_max != undefined) {
      var modMax = this.modifier_item_max.to_n();
      return modMax > 1 && modMax < 10;
    }
  };

  return ModifierItem;
})();
