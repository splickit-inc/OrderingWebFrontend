var MenuItems = (function () {
  function MenuItems(params) {
    this.items = params.items;

    if (params.payWith == null) {
      this.payWith = "cash";
    } else {
      this.payWith = params.payWith;
    }
  };

  MenuItems.prototype.addToOrder = function(callback) {
    return new OrderService().createItem(this.getJSONItems(), callback);
  };

  MenuItems.prototype.getJSONItems = function() {
    var itemsJSON = [];

    _.each(this.items, function(item) {
      var modifierItems = [];

      $.map(item.allModifiers(), function (modifier) {
        if (modifier.quantity > 0) {
          return modifierItems.push({
            modifier_item_id: modifier.modifier_item_id,
            mod_quantity: modifier.quantity,
            name: $.trim(modifier.modifier_item_name)
          });
        }
      });

      var modGroups = [];

      _.each(item.modifier_groups, function (modifierGroup) {
        return modGroups.push({
          modifier_group_display_name: $.trim(modifierGroup.modifier_group_display_name),
          modifier_items: modifierGroup.modifier_items,
          modifier_group_credit_by_size: modifierGroup.modifier_group_credit_by_size,
          modifier_group_max_modifier_count: modifierGroup.modifier_group_max_modifier_count,
          modifier_group_min_modifier_count: modifierGroup.modifier_group_min_modifier_count,
          modifier_group_credit: modifierGroup.modifier_group_credit,
          remainingCredit: modifierGroup.remainingCredit
        });
      });

      var notes = $('[data-dialog-element]').find("#requests input").val();
      if(item.notes && !notes){
        if (notes === ""){
          notes = '';
        } else {
          notes = item.notes;
        }
      }


      var itemJSON = {
        "item_id": item.item_id,
        "menu_type_id": item.menu_type_id,
        "uuid": item.uuid,
        "item_name": item.item_name,
        "large_image": item.large_image,
        "small_image": item.small_image,
        "description": item.description,
        "size_prices": item.size_prices,
        "notes": notes,
        "point_range": item.point_range,
        "modifier_groups": modGroups,
        "mods": modifierItems,
        "quantity": 1,
        "size_id": item.size.size_id,
        "sizeName": item.size.size_name,
        "note": notes
      };

      if (this.payWith === "points") {
        itemJSON.points_used = item.size.points;
        itemJSON.brand_points_id = item.sizePrice(item.size.id);

        var totalModifierPrice = item.totalModifiersPrice();

        if (totalModifierPrice > 0 && window.merchant_json && window.merchant_json.charge_modifiers_loyalty_purchase) {
          itemJSON.cash = item.totalModifiersPrice();
          itemJSON.price_string = item.size.points + " pts + $" + totalModifierPrice.toFixed(2);
        } else {
          itemJSON.price_string = item.size.points + " pts";
        }
      } else {
        itemJSON.cash = item.totalPrice();
        itemJSON.price_string = "$" + itemJSON.cash;
      }

      itemsJSON.push(itemJSON);
    }, this);

    return itemsJSON;
  };

  return MenuItems;
})();