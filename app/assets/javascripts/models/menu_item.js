var MenuItem = (function () {
  function MenuItem(params) {
    function toNumber(itemID) {
      if (itemID !== undefined) {
        return itemID.to_n();
      }
    }

    if (params !== undefined) {
      this.item_id = toNumber(params.item_id);
      this.menu_type_id = params.menu_type_id;
      this.uuid = params.uuid;
      this.item_name = params.item_name;
      this.description = params.description;
      this.large_image = params.large_image;
      this.small_image = params.small_image;
      this.modifier_groups = initializeModifierGroups(params.modifier_groups);
      this.size_prices = initializeSizePrices(params.size_prices);
      this.point_range = params.point_range;
      this.notes = params.note;
      this.note = params.note;
      this.calories = params.calories;
      this.notesLength = getNotesLength(this.notes);
      this.points_used = (String(params.points_used) || "0").to_i(); //Only for Cart added items

      if (this.size_prices !== undefined) {
        var size;
        if (params.size_id !== undefined) {
          size = findSize(params.size_id, this.size_prices);
        } else {
          size = findEnabledSize(this.size_prices);
        }
        this.size = size;
        this.default_size = size;
      }
      this.calculateModifiers(size.size_id);
    }

    function initializeSizePrices(size_prices) {
      return _.map(size_prices, function (sizePrice) {
        if (sizePrice instanceof ModifierItem) {
          return sizePrice;
        } else if (typeof sizePrice === 'object') {
          return new SizePrice(sizePrice);
        }
      });
    }

    function initializeModifierGroups(modifier_groups) {
      return _.map(modifier_groups, function (modifierGroup) {
        if (modifierGroup instanceof ModifierGroup) {
          return modifierGroup;
        } else if (typeof modifierGroup === 'object') {
          return new ModifierGroup(modifierGroup);
        }
      });
    }

    function findSize(sizeID, size_prices) {
      return _.findWhere(size_prices, {
        size_id: sizeID
      });
    }

    function findEnabledSize(size_prices) {
      return _.findWhere(size_prices, {
        enabled: true
      });
    }

    function getNotesLength(notes) {
      if (notes !== undefined) {
        return 100 - notes.length;
      } else {
        return 100;
      }
    }
  }

  MenuItem.prototype.oneSize = function() {
    if (this.size_prices !== undefined) {
      return (this.size_prices.length === 1);
    }
  };

  // TODO: duplicate of #findSize
  MenuItem.prototype.sizePrice = function(sizeID) {
    return _.findWhere(this.size_prices, {
      size_id: sizeID
    });
  };

  MenuItem.prototype.redeemable = function() {
    return this.point_range != void(0) && this.point_range.length > 0;
  };

  MenuItem.prototype.hasModifiers = function() {
    return this.modifier_groups.length > 0;
  };

  MenuItem.prototype.modifier_items = function() {
    return _.reduce(this.modifier_groups, function(memo, group) {
      return memo.concat(group.modifier_items);
    }, []);
  };

  MenuItem.prototype.selectedNestedModifiers = function(modifierID) {
    if (modifierID !== void(0)) {
      return _.filter(this.findModifier(modifierID).nestedItems, function(modifier) {
        return modifier.quantity > 0;
      });
    }
  };

  MenuItem.prototype.nestedItemString = function(modifierID) {
    var modifiers = this.selectedNestedModifiers(modifierID);
    var modifierStrings = _.map(modifiers, function(modifier) {
      var string = modifier['modifier_item_name'];
      if (modifier['quantity'] > 1) {
        string += ' (' + modifier['quantity'] + ')';
      }
      return string;
    });

    return modifierStrings.join(", ");
  };

  MenuItem.prototype.findModifier = function (targetModifierID) {
    if (targetModifierID !== void(0)) {
      return _.findWhere(this.allModifiers(), {
        modifier_item_id: targetModifierID.to_n()
      });
    }
  };

  MenuItem.prototype.allModifiers = function () {
    return _.flatten(
      _.map(this.modifier_groups, function (modifierGroup) {
        return modifierGroup.allModifiers();
      })
    );
  };

  MenuItem.prototype.findModifierGroup = function(targetModifier) {
    if (targetModifier !== undefined) {
      return _.find(this.modifier_groups, function(modifierGroup) {
        return _.contains(modifierGroup.allModifiers(), targetModifier);
      });
    }
  };

  MenuItem.prototype.findAndZeroModifierGroup = function (modifierID) {
    var modifierGroup = this.findModifierGroup(this.findModifier(modifierID));
    _.each(modifierGroup.allModifiers(), function (modifier) {
      if (typeof modifier === 'object') {
        if (modifier.modifier_item_id.to_n() === modifierID.to_n()) {
            zeroModifierGroup(modifierGroup);
        }
      }
    });
  };

  // TODO: remove DOM interaction from model.
  MenuItem.prototype.calculateModifiers = function(sizeID) {
    return _.map(this.modifier_groups, function(modifierGroup) {
      if(modifierGroup.modifier_group_max_modifier_count > 1) {
          if(!!sizeID && !!modifierGroup.modifier_group_credit_by_size[sizeID])
          {
              modifierGroup.modifier_group_credit = modifierGroup.modifier_group_credit_by_size[sizeID];
          }
        modifierGroup.remainingCredit = Math.max(0, _.reduce(modifierGroup.allModifiers(), function(memo, modifier) {
          return memo - (modifier.basePrice || 0) * modifier.quantity;
        }, modifierGroup.modifier_group_credit));
      }

      return _.map(modifierGroup.allModifiers(), function(modifier) {
        if(modifier.quantity === modifier.modifier_item_max){
          MenuItemsController.subtractCaloriesLabel(modifier);
        }

        if (sizeID) {
          modifier.basePrice = modifier.sizePrice(sizeID);

          if (!modifier.hasAnAvailablePrice(sizeID)) {
            $("dt[data-id=" + modifier.modifier_item_id + "], dd[data-id=" + modifier.modifier_item_id + "]").addClass('disabled');

            MenuItemsController.addCaloriesLabel(modifier);

            modifier.quantity = 0;

            if (!modifier.oneMax()) {
              $("dd[data-id=" + modifier.modifier_item_id + "] a").removeClass('active');
              $("dd[data-id=" + modifier.modifier_item_id + "] span").text(modifier.quantity).attr('data-quantity', modifier.quantity);
            } else {
              $("dd[data-id=" + modifier.modifier_item_id + "] input[type=radio]").prop('checked', false);
              $("dd[data-id=" + modifier.modifier_item_id + "] input[type=checkbox]").prop('checked', false);

              MenuItemsController.addCaloriesLabel(modifier);
            }
          } else {
            $("dt[data-id=" + modifier.modifier_item_id + "], dd[data-id=" + modifier.modifier_item_id + "]").removeClass('disabled');
          }
        }

        modifier.netPrice = (modifier.basePrice < 0) ? modifier.basePrice : Math.max(0, modifier.basePrice - modifierGroup.remainingCredit);

        if (modifierGroup.remainingCredit > 0 && modifier.netPrice === 0) {
          return $("dt[data-id=" + modifier.modifier_item_id + "] span").hide();
        } else {
          return $("dt[data-id=" + modifier.modifier_item_id + "] span").show();
        }
      });
    });
  };

  MenuItem.prototype.addModifier = function(modifier) {
    if (modifier !== undefined) {
      var quantity = modifier.quantity.to_n();
      var group = this.findModifierGroup(modifier);
      var groupQuantity = group.quantity();

      var belowModMax = (quantity + 1) <= modifier.modifier_item_max;
      var belowGroupMax = (groupQuantity + 1) <= group.modifier_group_max_modifier_count;

      if (belowModMax && belowGroupMax) {
        modifier.quantity = quantity + 1;
        return this.calculateModifiers();
      }
    }
  };

  MenuItem.prototype.setModifierQuantity = function(modifier, newQuantity) {
    if (modifier !== undefined) {
      var group = this.findModifierGroup(modifier);
      var groupQuantity = group.quantity();

      var belowModMax = newQuantity <= modifier.modifier_item_max;
      var belowGroupMax = (groupQuantity + newQuantity - modifier.quantity) <= group.modifier_group_max_modifier_count;

      if (belowModMax && belowGroupMax) {
        modifier.quantity = newQuantity;
        return this.calculateModifiers();
      }
    }
  };

  MenuItem.prototype.removeModifier = function (modifier) {
    if (modifier !== void(0)) {
      if (removable(this.findModifierGroup(modifier), modifier)) {
        modifier.quantity = modifier.quantity - 1;
        this.calculateModifiers();
      }
    }
  };

  MenuItem.prototype.resetQuantity = function() {
    _.each(this.allModifiers(), function(modifierItem) {
      modifierItem.resetQuantity();
    });

    this.size = this.default_size;
  };

  MenuItem.prototype.toggleModifier = function(modifierID) {
    var modifier      = this.findModifier(modifierID);
    var modifierGroup = this.findModifierGroup(modifier);

    //important
    if (modifier !== undefined && modifier.oneMax()){
      if (optionalExclusiveModifier(modifierGroup)) {
        modifier.quantity = toggleOptionalExclusiveModifier(modifierGroup, modifier);
      } else if (modifierGroup.modifier_group_max_modifier_count === modifierGroup.modifier_group_min_modifier_count && modifierGroup.remainingModifiers() > 0 && modifier.quantity.to_n() === 0) {
          modifier.quantity = 1;
      } else if (modifier.quantity.to_n() === 0 && modifierGroup.belowModifierGroupMax()) {
          modifier.quantity = 1;
      } else if (modifier.quantity.to_n() === 1) {
          modifier.quantity = 0;
      }
      this.calculateModifiers();
      return modifier.quantity;
    }
  };

  MenuItem.prototype.quantity = function() {
    var modifierGroup = _.find(this.modifier_groups, function (modifierGroup) {
      return modifierGroup.isQuantityGroup();
    });

    var quantity = modifierGroup instanceof ModifierGroup ? modifierGroup.quantity() : 1;

    return quantity < 1 ? 1 : quantity;
  };

  MenuItem.prototype.totalPrice = function() {
    var price = Math.max(0, this.quantity() * (this.totalModifiersPrice() + this.size.price.to_n()));
    return (Math.round(100 * price) / 100).toFixed(2);
  };

  MenuItem.prototype.totalModifiersPrice = function () {
    return _.reduce(this.modifier_groups, function (memo, modifierGroup) {
      return modifierGroup.totalPrice() + memo;
    }, 0);
  };

  MenuItem.prototype.inactiveInterdependents = function() {
    return _.filter(this.modifier_groups, function(modifierGroup) {
      return modifierGroup.isInterdependent() && modifierGroup.quantity() === 0;
    });
  };

  MenuItem.prototype.activeInterdependents = function() {
    return _.filter(this.modifier_groups, function(modifierGroup) {
      return modifierGroup.isInterdependent() && modifierGroup.quantity() > 0;
    });
  };

  MenuItem.prototype.modifiersInterdependents = function() {
    return _.filter(this.modifier_groups, function(modifierGroup) {
      return modifierGroup.isInterdependent();
    });
  };

  MenuItem.prototype.interdependentValidationErrorMessage = function() {
    var inactiveInterdependents = this.inactiveInterdependents();
    var modifiersInterdependents = this.modifiersInterdependents();

    if ((inactiveInterdependents.length % 2 !== 0) && (modifiersInterdependents.length > 0) && (modifiersInterdependents.length % 2 === 0)) {
      var retString = _.template("Please select from <%= name %>");
      return retString({ name: inactiveInterdependents[0].modifier_group_display_name });
    }

    return null;
  };

  MenuItem.prototype.isValid = function() {
    var returnValue = true;

    _.each(this.modifier_groups, function(modifierGroup) {
      if (!modifierGroup.isValid()) {
        returnValue = false;
        return;
      }
    });

    if (this.interdependentValidationErrorMessage()) {
      returnValue = false;
    }

    return returnValue;
  };

  MenuItem.prototype.validationErrorMessages = function() {
    var errorMessages = [];
    var interdependentErrorMessage;

    _.each(this.modifier_groups, function (modifierGroup) {
      if (modifierGroup.validationErrorMessage()) {
        errorMessages.push(modifierGroup.validationErrorMessage());
      }
    });

    if (interdependentErrorMessage = this.interdependentValidationErrorMessage()) {
      errorMessages.push(interdependentErrorMessage);
    }

    return errorMessages;
  };

  MenuItem.prototype.toMinParams = function() {
    return {
      item_id: this.item_id,
      item_name: this.item_name,
      small_image: this.small_image,
      total_price: this.totalPrice()
    };
  };

  var removable = function (modifierGroup, modifier) {
    return modifier.quantity > 0;
  };

  var optionalExclusiveModifier = function(modifierGroup) {
    return (modifierGroup.modifier_group_max_modifier_count === 1 && modifierGroup.modifier_group_min_modifier_count === 0);
  };

  var toggleOptionalExclusiveModifier = function (modifierGroup, modifier) {
    selectCorrectModifier(modifierGroup, modifier.modifier_item_id);
    checkCorrectModifier(modifierGroup, modifier.modifier_item_id);

    if (modifierGroup.quantity() === 1) {
      return modifier.quantity = 0;
    } else {
      return modifier.quantity = 1;
    }
  };

  var selectCorrectModifier = function (modifierGroup, modifierID) {
    _.each(modifierGroup, function (modifiers) {
      _.each(modifiers, function (modifier, k) {
        if (modifier.modifier_item_id !== modifierID) {
          modifiers[k].quantity = 0;
        }
      });
    });
  };

  var checkCorrectModifier = function (modifierGroup, modifierID) {
    _.each(modifierGroup, function (modifiers) {
      _.each(modifiers, function (modifier, k) {
        if (modifier.modifier_item_id !== modifierID) {
          $("dd[data-id='" + modifier.modifier_item_id + "'] input").prop("checked", false);
        }
      });
    });
  };

  var zeroModifierGroup = function (modifierGroup) {
    _.each(modifierGroup.allModifiers(), function (modifier) {
      if (typeof modifier === 'object') {
          modifier.quantity = 0;
      }
    });
  };

  return MenuItem;
})();