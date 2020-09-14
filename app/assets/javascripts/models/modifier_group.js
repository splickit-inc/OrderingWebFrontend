var ModifierGroup = (function () {
  function ModifierGroup(params) {
    if (params !== undefined) {
      // TODO: init. model attrs. correctly server-side.
      this.id = _.uniqueId();
      this.modifier_group_display_name = params.modifier_group_display_name;
      this.modifier_items = initializeModifiers(params.modifier_items);
      this.modifier_group_credit = getCredit(params.modifier_group_credit);
      this.modifier_group_credit_by_size = params.modifier_group_credit_by_size;
      this.modifier_group_max_modifier_count = params.modifier_group_max_modifier_count;
      this.modifier_group_min_modifier_count = params.modifier_group_min_modifier_count != null ? params.modifier_group_min_modifier_count : 0; // TODO: extract method
      this.modifier_group_max_price = parseFloat(params.modifier_group_max_price);
      this.modifier_group_type = params.modifier_group_type || "";
      this.remainingCredit = params.modifier_group_credit || 0;
    }

    function initializeModifiers(modifiers) {
      return _.map(modifiers, function (modifier) {
        if (modifier instanceof ModifierItem) {
          return modifier;
        } else if (typeof modifier === 'object') {
          return new ModifierItem(modifier);
        }
      })
    }

    function getCredit(credit) {
      if (credit !== undefined) {
        return parseFloat(credit);
      } else {
        return 0.0;
      }
    }
  }

  ModifierGroup.prototype.remainingModifiers = function() {
    return this.modifier_group_max_modifier_count - this.quantity();
  };

  ModifierGroup.prototype.atModifierMax = function() {
    return (this.quantity() === this.modifier_group_max_modifier_count);
  };

  ModifierGroup.prototype.aboveGroupModifierMin = function() {
    return (this.quantity() - 1) >= this.modifier_group_min_modifier_count;
  };

  ModifierGroup.prototype.belowModifierGroupMax = function() {
    return (this.quantity() + 1) <= this.modifier_group_max_modifier_count;
  };

  // TODO: s/quantity/modifierQuantity/g
  ModifierGroup.prototype.quantity = function() {
    return _.reduce(this.allModifiers(), function(memo, modifier) {
      return memo + (modifier.quantity.to_n() || 0);
    }, 0);
  };

  ModifierGroup.prototype.allModifiers = function () {
    return _.compact(
      _.union(
        this.modifier_items,
        _.flatten(
          _.pluck(this.modifier_items, "nestedItems")
        )
      )
    );
  };

  ModifierGroup.prototype.resetQuantity = function() {
    _.each(this.allModifiers(), function(modifierItems) {
      modifierItems.resetQuantity();
    });
  };
  
  ModifierGroup.prototype.isValid = function () {
    return (this.validationErrorMessage() === null);
  };

  ModifierGroup.prototype.isInterdependent = function() {
    return this.modifier_group_type.toUpperCase() === "I2"
  };

  ModifierGroup.prototype.isQuantityGroup = function() {
    return this.modifier_group_type.toUpperCase() === "Q"
  };
  
  ModifierGroup.prototype.validationErrorMessage = function() {
    var quantity = this.quantity();
    var min = this.modifier_group_min_modifier_count;
    var max = this.modifier_group_max_modifier_count;
    var name = this.modifier_group_display_name;
    
    if (quantity < min) {
      if (min > 1) {
        var retString = _.template("Please select <%= minimum %> from <%= name %>");
        return retString({minimum: min, name: name});
      } else {
        var retString = _.template("Please select from <%= name %>");
        return retString({name: name});
      }
    } else if (quantity > max) {
      var retString = _.template("<%= name %> has exceeded the maximum selection of <%= max %>");
      return retString({name: name, max: max});
    }
    
    return null;
  };

  // Method to retrieve total price of a modifier group, using group's credit
  ModifierGroup.prototype.totalPrice = function() {
    var total = _.reduce(this.allModifiers(), function (memo, modifier) {
      if (modifier.modifier_item_pre_selected && modifier.quantity > 0 && this.modifier_group_credit <= 0) {
        return memo + (modifier.basePrice || 0) * (modifier.quantity - 1);
      } else {
        return memo + (modifier.basePrice || 0) * modifier.quantity;
      }
    }, 0, this);

    if (total > 0) {
      total = Math.max(0, total - this.modifier_group_credit);
    }

    if (total > this.modifier_group_max_price) {
      total = this.modifier_group_max_price;
    }

    return total;
  };
  
  ModifierGroup.prototype.getQuantityText = function () {
    var min = this.modifier_group_min_modifier_count === undefined ? 0 : this.modifier_group_min_modifier_count.to_n();
    var max = this.modifier_group_max_modifier_count === undefined ? 0 : this.modifier_group_max_modifier_count.to_n();

    var quantity = this.quantity();
    var maxRemaining = this.remainingModifiers();
    var minRemaining = min - quantity;
    
    if (max === 0 && min === 0) {
      return null;
    }
    
    if (maxRemaining === 0) {
        return 'Maximum selected';
    }
    
    else if (max === 0 && minRemaining > 0) {
        return "Choose " + minRemaining + " more";
    }
    
    else if (max === 0 && minRemaining <= 0) {
        return "Choose " + min;
    }
    
    else if (max === min) {
        return "Choose " + minRemaining + " more";
    }
    
    else if (min === 0 || (quantity >= min && min < max)) {
        return "Choose up to " + maxRemaining + " more";
    }
    
    var template = _.template("Choose <%= min_more %> to <%= max_more %> more");
    var text = template({min_more: minRemaining, max_more: maxRemaining});
    return text;
  };

  return ModifierGroup;
})();
