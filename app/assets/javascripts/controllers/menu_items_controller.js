var MenuItemsController = {

  show: function (params) {

    var content = Handlebars.compile(HandlebarsTemplates['menu_item']({
      item:           params.item,
      groupOrder:     params.groupOrder,
      loyalUser:      (params.user !== void(0)) && params.user.isLoyal(),
      redeemableItem: params.item.redeemable(),
      itemOneSize:    params.item.oneSize(),
      edit:           params.edit,
      showNotes:      window.show_notes,
      nutritionLink:  this.getNutritionLink(),
      displayNutritionLink: !skin.isPunchh,
      isWtjmmj:       this.is_wtjmmj(),
      isCheckoutPage: $("body").data("route") == "checkouts/new"
    }));

    var dialog = new Dialog({
      content: content,
      id:      "add-to-order",
      "class": "add-to-order"
    });

    dialog.open();

    // TODO: shouldn't need to recalculate; instantiate item model correctly.
    var sizeID = params.item.size.size_id;
    params.item.calculateModifiers(sizeID);
    
    this.bindSelectNestedAnimation(params.item);
    this.setAllNestedModifierText(params.item);
    this.updateItemTotal(params.item, params.user, params.edit);
    this.updateModifierNetPriceText(params.item);
    this.selectCorrectSize(params.item.size.size_id);
    this.bindTrackingEvents();
    this.bindSizeChangeEvents(params.item, params.user, params.edit);
    this.bindSubEvents(params.item, params.user, params.edit);
    this.bindAddEvents(params.item, params.user, params.edit);
    this.bindCheckboxEvents(params.item, params.user, params.edit);
    this.bindRadioEvents(params.item, params.user, params.edit);
    this.bindSpinnerEvents(params.item, params.user, params.edit);
    this.bindAddToOrderEvents(params.item, params.user, dialog);
    this.bindCheckoutEvents(params.item, dialog);
    this.bindNestedModifierEvents(params.item, params.user);
    this.bindItemNoteEvent(100);
    this.updateAllModifiersText(params.item);
    this.bindSpinner(params.item);
    this.bindDropdownEvents();

    if (!skin.isMoes()) {
      this.bindNutritionEvents(params.item);
    }
  },

  remove: function(event) {
    var uuid = $(event.target).attr('data-item-id');

      Dialog.removeItem(uuid, function (response) {
        if ($("body").data("route") == "checkouts/new") {
          window.location = window.location;
        } else {
          MyOrderController.removeItemCallback(response, event)
        }
      });
    },

    edit: function (event) {
      var uuid = $(event.target).attr('data-item-id');

      orderService.showItem(uuid, function (response) {
        MenuItemsController._editItemCallback(response);
      });
    },

    getNutritionLink: function () {
      if (skin.isMoes()) {
        return "http://www.moes.com/food/nutrition";
      }

      return null;
    },

    is_wtjmmj:  function(){
      if (window.skin.skinName == "wtjmmj"){
        return true;
      }
    },

    selectCorrectSize: function (sizeID) {
      $("input[value='" + sizeID + "']").prop("checked", true);
    },

    updateAllModifiersText: function (item) {
      _.each(item.modifier_groups, function (modifierGroup) {
        MenuItemsController._updateModifierQuantityText(modifierGroup);
      });
    },
    bindSelectNestedAnimation: function (item) {

      var self = this;
      var $dialogLeft = $('#add-to-order .dialog-left');
      var $dialogRight = $('.item-dialog-component');

      $('.nm-select').click(function (event) {
        var currentLocation = $('#menu-item-dialog').scrollTop();

        $dialogLeft.addClass('nm-left-hidden');
        $dialogRight.addClass('nm-right-visible');

        $('.nm-save').click(function () {
          $dialogLeft.removeClass('nm-left-hidden');
          $dialogRight.removeClass('nm-right-visible');

          $('#menu-item-dialog').scrollTo(currentLocation);
          $('#current-nm').remove();

          var modifierID = $(event.target).data('id');
          var modifierGroup = item.findModifierGroup(item.findModifier(modifierID));
          self.setAllNestedModifierText(item);
          self.disableSelectButtons(modifierID, modifierGroup);
        });
      });
    },

    bindSpinner: function(item){
        var inputElements = $(".spinner-modifier-item");
        $.each(inputElements,function(key, element){
            var modID = $(element).parents("dd").attr("data-id");
            var modifier = item.findModifier(modID);
            $(element).spinner({
                min: modifier.modifier_item_min,
                max: modifier.modifier_item_max
            });
        });
    },

    bindDropdownEvents: function () {
        var icons = {
            header: "ui-icon-circle-arrow-e",
            activeHeader: "ui-icon-circle-arrow-s"
        };

        $( "#dropdown" ).accordion({
            autoHeight: 'false',
            heightStyle: 'content',
            collapsible: true,
            icon: icons
        });
        if(skin.isOsf()){
            $(".ui-accordion-content").show();
        }
    },

    bindTrackingEvents: function () {
      $('button.add').on('click', function () {
        return GoogleAnalyticsService.track('orders', 'add');
      });

      $('button.checkout').on('click', function () {
        return GoogleAnalyticsService.track('orders', 'addAndCheckout');
      });
    },

    hasUpsellItems: function (menu_type_id) {
      var items = [];
      var i = 0;
      var keys = Object.keys(window.menuTypeUpsellItems);
      _.each(keys, function(key){
        if(key.search(menu_type_id) != -1){
          items[i] = window.menuTypeUpsellItems[key];
          i++;
        }
      });

      return items;
    },

    openUpsellsModal: function (items) {
      var upsellsDialog = new Dialog({
        title: "May we suggest",
        content: HandlebarsTemplates['upsells_information']({upsell_items: items}),
        id: "upsells-info",
        "class": "upsellss-info",
        buttons: [{
          text: "No Thanks",
          class: "no-thanks"
        }],
        onClose: function () {
          if (MenuItemsController.proceedToCheckout) {
            Dialog.checkout();
          }
        }
      });
      var dialogElement = upsellsDialog.open();
      $('button.no-thanks').on('click', function () {
        Dialog.close_all();
      });
      this.bindAddUpsell(upsellsDialog, items);
      return dialogElement;
    },

    getItem: function(items, id){
      var item="";
      _.each(items, function(i){
        if(i.item_id == id){
          item = i;
        }
      });
      return item;
    },

    bindAddUpsell: function (dialog, items) {
      $(".add-item").click(function (event) {
        var id = $(this).data("upsell-item-id");
        var item = MenuItemsController.getItem(items, id);
        item.resetQuantity();
        if (item.hasModifiers() || !item.oneSize()) {
          MenuItemsController.proceedToCheckout = false;
          return MenuItemsController.show({
            item: item,
            user: window.user,
            groupOrder: $("main").data("merchant-group-order-token") !== "",
            edit: false,
            comesFromUpsell: true
          });
        } else {
          if(!MenuItemsController.proceedToCheckout){
            dialog.close();
          }
          dialog.addToOrder( [item], null, MenuItemsController.proceedToCheckout, false);
        }
      });
    },

    openNutritionModal: function (response) {
      var nutrition_response;
      var title_box;

      if (response.message) {
        nutrition_response = response;
        title_box = "Nutritional Information"
      } else {
        nutrition_response = this.nutritionFormat(response.nutrition_info);
        title_box = response.item_name;
      }

      var nutritionDialog = new Dialog({
        title: title_box,
        content: HandlebarsTemplates['nutrition_information']({nutrition: nutrition_response}),
        id: "nutrition-info",
        "class": "nutrition-info"
      });

      return nutritionDialog.openMultiple();
    }
    ,

    bindNutritionEvents: function (item) {
      var self = this;

      $('.nutrition-info').click(function () {
        var updatedItem = window.menuItems[item.item_id];
        NutritionInformation({
          itemID: updatedItem.item_id,
          sizeID: updatedItem.size.size_id,
          itemName: updatedItem.item_name,
          callback: self.openNutritionModal,
          context: self
        });
      });
    }
    ,

    bindSizeChangeEvents: function (item, user, edit) {
      var self = this;

      $('dd input[name="sizes"]').on('click', (function () {
        return function (event) {
          item.size = item.sizePrice($(event.currentTarget).val());

          //TODO: it needs to be added when SIZES modifier is implemented in API
          // _.each (item.size_prices, function(size){
          //   if (size.size_id == item.size.size_id) {
          //     $("#size-add-sub-"+size.size_id).text("Subtract");
          //     $("#size-add-sub-"+size.size_id+"-mobile").text("-");
          //   } else {
          //     $("#size-add-sub-"+size.size_id).text("Add");
          //     $("#size-add-sub-"+size.size_id+"-mobile").text("+");
          //   }
          // });

          item.calculateModifiers(item.size.size_id);
          self.updateItemTotal(item, user, edit);
          self.updateModifierNetPriceText(item);
        };
      })(this));
    }
    ,

    nutritionFormat: function (nutrition_response) {
      for (var i = 0; i < nutrition_response.length; i++) {
        if (nutrition_response[i].label == 'Calories') {
          nutrition_response[i].isCalories = true;
        } else if (nutrition_response[i].label == 'Calories From Fat') {
          nutrition_response[i].isCaloriesFF = true;
        } else if (nutrition_response[i].label == 'Cholesterol') {
          nutrition_response[i].isCholesterol = true;
        } else if (nutrition_response[i].label == 'Dietary Fiber') {
          nutrition_response[i].isDietaryFiber = true;
        } else if (nutrition_response[i].label == 'Protein') {
          nutrition_response[i].isProtein = true;
        } else if (nutrition_response[i].label == 'Saturated Fat') {
          nutrition_response[i].isSaturatedFat = true;
        } else if (nutrition_response[i].label == 'Serving Size') {
          nutrition_response[i].isServing = true;
        } else if (nutrition_response[i].label == 'Sodium') {
          nutrition_response[i].isSodium = true;
        } else if (nutrition_response[i].label == 'Sugars') {
          nutrition_response[i].isSugars = true;
        } else if (nutrition_response[i].label == 'Total Carbohydrates') {
          nutrition_response[i].isCarbohydrates = true;
        } else if (nutrition_response[i].label == 'Total Fat') {
          nutrition_response[i].isFat = true;
        } else if (nutrition_response[i].label == 'Trans Fat') {
          nutrition_response[i].isTransFat = true;
        }
      }
      return nutrition_response;
    }
    ,

    bindSpinnerEvents: function (item, user, edit) {
      var self = this;
      $("dd input.spinner-modifier-item").unbind("input");
      $("dd input.spinner-modifier-item").on("input spinstop", (function () {
        return function (event) {
          var trigger = $(event.currentTarget);
          var modID = trigger.parents("dd").attr("data-id");
          var modifier = item.findModifier(modID);
          var quantity = trigger.val().to_n() || 0;

          var qtyValid = item.setModifierQuantity(modifier, quantity);

          if (modifier && qtyValid) {
            var modifierGroup = item.findModifierGroup(modifier);

            self.updateItemTotal(item, user, edit);
            self.updateModifierNetPriceText(item);
            self._updateModifierQuantityText(modifierGroup);
          }

          if (quantity == modifier.modifier_item_max) {
            self.subtractCaloriesLabel(modifier);
          } else {
            self.addCaloriesLabel(modifier);
          }

          trigger.val(modifier.quantity);

          return false;
        };
      })(this));

      $("dd .ui-spinner a.ui-spinner-up, dd .ui-spinner a.ui-spinner-down").unbind("mouseup");
      $("dd .ui-spinner a.ui-spinner-up, dd .ui-spinner a.ui-spinner-down").on("mouseup", (function () {
        return function (event) {
          var trigger = $(event.currentTarget);
          var modID = trigger.parents("dd").attr("data-id");
          var modifier = item.findModifier(modID);
          var spinnerInput = trigger.siblings("input.spinner-modifier-item");
          var quantity = spinnerInput.val().to_n();

          var qtyValid = item.setModifierQuantity(modifier, quantity);

          if (modifier && qtyValid) {
            var modifierGroup = item.findModifierGroup(modifier);

            self.updateItemTotal(item, user, edit);
            self.updateModifierNetPriceText(item);
            self._updateModifierQuantityText(modifierGroup);
          }

          if (quantity == modifier.modifier_item_max) {
            self.subtractCaloriesLabel(modifier);
          } else {
            self.addCaloriesLabel(modifier);
          }

          spinnerInput.val(modifier.quantity);

          return true;
        };
      })(this));
    }
    ,

    bindSubEvents: function (item, user, edit) {
      var self = this;

      $('dd a.subtract').unbind('click');
      $('dd a.subtract').on('click', (function () {
        return function (event) {
          var trigger = $(event.currentTarget);
          var modID = trigger.parents("dd").attr("data-id");
          var modifier = item.findModifier(modID);

          item.removeModifier(modifier);

          if (modifier.quantity === 0) {
            trigger.removeClass('active');
            trigger.siblings('a').removeClass('active');
          }

          if (modifier.quantity < modifier.modifier_item_max) {
            self.addCaloriesLabel(modifier);
          }

          if (modifier) {
            var counter = trigger.siblings('span');
            var modifierGroup = item.findModifierGroup(modifier);

            counter.text(modifier.quantity);
            counter.attr('data-quantity', modifier.quantity);

            self.updateItemTotal(item, user, edit);
            self.updateModifierNetPriceText(item);
            self._updateModifierQuantityText(modifierGroup);
          }
          return false;
        };
      })(this));
    }
    ,

    bindAddEvents: function (item, user, edit) {
      var self = this;

      $('dd a.add').unbind('click');
      $('dd a.add').on('click', (function () {
        return function (event) {
          var trigger = $(event.currentTarget);
          var modID = trigger.parents("dd").attr("data-id");
          var modifier = item.findModifier(modID);

          item.addModifier(modifier);
          if (modifier.quantity > 0) {
            trigger.addClass('active');
            trigger.siblings('a').addClass('active');
            if (modifier.quantity == modifier.modifier_item_max) {
              self.subtractCaloriesLabel(modifier);
            }
          }

          if (modifier) {
            var counter = trigger.siblings('span');
            var modifierGroup = item.findModifierGroup(modifier);

            counter.text(modifier.quantity);
            counter.attr('data-quantity', modifier.quantity);

            self.updateItemTotal(item, user, edit);
            self.updateModifierNetPriceText(item);
            self._updateModifierQuantityText(modifierGroup);
          }

          return false;
        };
      })(this));
    }
    ,

    bindCheckboxEvents: function (item, user, edit) {
      var self = this;

      $('dd input[type="checkbox"]').unbind('click');
      $('dd input[type="checkbox"]').on('click', (function () {
        return function (event) {

          var trigger = $(event.currentTarget);
          var modID = trigger.parents("dd").attr("data-id");
          var modifier = item.findModifier(modID);
          var modifierGroup = item.findModifierGroup(modifier);

          if (modifierGroup.modifier_group_max_modifier_count == 1) {
            _.each(modifierGroup.modifier_items, function (checkbox) {
              if (checkbox.modifier_item_id == modID) {
                  self.subtractCaloriesLabel(checkbox);
              } else {
                  item.removeModifier(checkbox);
                  $("#modifier_item_" + checkbox.modifier_item_id).attr('checked', false);
                    self.addCaloriesLabel(checkbox);
              }
            });
          }
            //Deselect a checkbox if quantity == 0
          if (self._itemNotAdded(item.toggleModifier(modID))) {
              if (modifierGroup.modifier_group_max_modifier_count != 1) {
                  $("dd[data-id='" + modID + "'] input").attr("checked", false);
              }
              self.addCaloriesLabel(modifier);
          } else {
                self.subtractCaloriesLabel(modifier);
          }
          if (modifierGroup.modifier_group_max_modifier_count == 1) {
              var text = $("#modifier_item_" + modID).prop('checked') ? 'Maximum selected' : 'Choose up to 1 more';
              self.updateItemTotal(item, user, edit);
              self.updateModifierNetPriceText(item);
              self._updateModifierQuantityTextUptoOne(modifierGroup, text);
          } else {
              self.updateItemTotal(item, user, edit);
              self.updateModifierNetPriceText(item);
              self._updateModifierQuantityText(modifierGroup);
          }
        };
      })(this));
    }
    ,
    _updateModifierQuantityTextUptoOne: function (modifierGroup, text) {

    if (modifierGroup !== void (0)) {
        var $MaxQuantity = $("p[data-modifier-group-id='" + modifierGroup.id + "']");
        $MaxQuantity.text(text);
    }
   }
   ,

    addToOrder: function (params) {
      if ($(params.event.target).hasClass('points')) {
        params.user.subtractPoints(params.item.size.points);
        params.dialog.addToOrder([params.item], 'points', params.isCheckout, params.edit);
      } else {
        params.dialog.addToOrder([params.item], 'cash', params.isCheckout, params.edit);
      }
      MenuItemsController.resetItem(params.item);
      Dialog.close_all();
    },

    resetItem: function (item) {
      window.menuItems[item.item_id].resetQuantity();
    },

//MODAL BUTTONS
    bindAddToOrderEvents: function (item, user, dialog) {
      $('button.add').on('click', function (event) {
        if (!item.isValid()) {
          window.alert(item.validationErrorMessages());
          return;
        }
        var edit = $(event.target).hasClass('edit');
        var isCheckout = ($("body").data("route") === "checkouts/new");
        var isGroupOrder = ($(event.target).hasClass('add-to-group-order'));
        MenuItemsController.addToOrder({
          item: item,
          user: user,
          dialog: dialog,
          event: event,
          edit: edit,
          isCheckout: isCheckout
        });
        var items = [];
        if(window.menuTypeUpsellItems) {
          items = MenuItemsController.hasUpsellItems(item.menu_type_id);
        }
        if (!MenuItemsController.comesFromUpsell && items.length > 0) {
          MenuItemsController.proceedToCheckout = false;
          MenuItemsController.openUpsellsModal(items);

          if(isGroupOrder)
          {
              MenuItemsController.proceedToCheckout = true;
          }
        }
      });
    },

    bindCheckoutEvents: function (item, dialog) {
      $('button.checkout').on('click', function (event) {
        if (!item.isValid()) {
          $(this).prop("disabled", false);
          window.alert(item.validationErrorMessages());
          return;
        }
        $(this).prop("disabled", true);

        var hasUpsells = [];
        if(window.menuTypeUpsellItems) {
          hasUpsells = MenuItemsController.hasUpsellItems(item.menu_type_id);
        }
        var resp = dialog.addToOrder([item], null, hasUpsells.length<=0 || MenuItemsController.comesFromUpsell,
          $(event.target).hasClass('edit'));
        if (!MenuItemsController.comesFromUpsell && hasUpsells.length > 0) {
          MenuItemsController.proceedToCheckout = true;
          MenuItemsController.openUpsellsModal(hasUpsells);
        }
        return resp;
      });
    }
    ,

    updateModifierNetPriceText: function (item) {
      _.map($('dt span'), function (extra) {

        var $extra = $(extra);
        var modifierID = $extra.parents('dt').attr('data-id');
        var modifier = item.findModifier(modifierID);

        if (modifier != void(0)) {
          if (modifier.netPrice > 0) {
            $extra.addClass("active");
            $extra.text(modifier.netPrice.to_n().toFixed(2));
          } else if (modifier.netPrice < 0) {
            $extra.addClass("decrease");
            $extra.text(modifier.netPrice.to_n().toFixed(2));
          }
        }
      });
    }
    ,

    updateItemTotal: function (item, user, edit) {
      this._updateItemPrice(item.totalPrice());
      this._updateItemPoints(item.totalModifiersPrice(), item.size.points, edit);
      this._toggleItemPoints(user, item, edit);
    }
    ,

    _updateItemPrice: function (cash) {
      $('button.add.cash').text("Add item - $" + (cash));
    }
    ,

    _updateItemPoints: function (cash, points, edit) {
      if (this._itemRedeemableInPoints(points)) {
        if (edit) {
          $('button.add.points').show();
        }
        if (cash > 0 && window.merchant_json && window.merchant_json.charge_modifiers_loyalty_purchase) {
          $('button.add.points').text("Add item - " + points + " pts + $" + cash.toFixed(2));
        } else {
          $('button.add.points').text("Add item - " + points + " pts");
        }
      } else {
        if (edit) {
          $('button.add.points').hide();
        }
        $('button.add.points').text("Item not redeemable");
      }
    }
    ,

    _toggleItemPoints: function (user, item, edit) {
      if (edit) {
        if (!(user && user.isLoyal() && user.hasEnoughPoints(item.size.points - item.points_used))) {
          $('button.add.points').hide();
        }
      } else {
        if (user && user.isLoyal() && user.hasEnoughPoints(item.size.points)) {
          $('button.add.points').prop('disabled', false);
        } else {
          $('button.add.points').prop('disabled', true);
        }
      }
    }
    ,

    setAllNestedModifierText: function (item) {
      "use strict";

      _.map($('.nm-select'), function (nestedModifier) {
        MenuItemsController.setNestedModifierText($(nestedModifier).data('id'), item);
      });
    }
    ,

    setNestedModifierText: function (id, item) {
      "use strict";

      var nestedItemString = item.nestedItemString(id);
      var nestedItemTextContainer = $('dt[data-id=' + id + '] span');
      var nestedItemButton = $('dd[data-id=' + id + '] button');

      nestedItemTextContainer.text('');
      nestedItemTextContainer.removeClass('nested-text');

      if (nestedItemString !== "") {
        nestedItemTextContainer.text(' - ' + nestedItemString);
        nestedItemTextContainer.addClass('nested-text');
        nestedItemButton.text('Edit');
      } else {
        nestedItemButton.text('Select');
      }
    }
    ,

    disableSelectButtons: function (modifierID, modifierGroup) {
      var selectButtons = $("dl[data-modifier-group-id='" + modifierGroup.id + "'] button:contains('Select')");
      var editButtons = $("button:contains('Edit')");

      if ((modifierGroup.modifier_group_min_modifier_count != modifierGroup.modifier_group_max_modifier_count) && modifierGroup.atModifierMax()) {
        selectButtons.prop('disabled', true);
        editButtons.prop('disabled', false);
      } else {
        selectButtons.prop('disabled', false);
        editButtons.attr('title', '');
      }
    }
    ,

    bindRadioEvents: function (item, user, edit) {
      var self = this;

      $('dd input[type="radio"]:not([name="sizes"])').on('click', (function () {
        return function (event) {
          var trigger = $(event.currentTarget);
          var modID = trigger.parents("dd").attr("data-id");
          var modifier = item.findModifier(modID);
          var modifierGroup = item.findModifierGroup(modifier);

          item.toggleModifier(modID);

          item.findAndZeroModifierGroup(modID);
          item.findModifier(modID).quantity = 1;

          self.updateItemTotal(item, user, edit);
          self.updateModifierNetPriceText(item);
          self._updateModifierQuantityText(modifierGroup);

          _.each(modifierGroup.modifier_items, function (radio) {
            if (radio.modifier_item_id == modID) {
              self.subtractCaloriesLabel(radio);
            } else {
              self.addCaloriesLabel(radio);
            }
          });
            self.setAllNestedModifierText(item);
        };
      })(this));
    }
    ,

    bindNestedModifierEvents: function (item, user) {
      var self = this;

      _.map($('dd .nm-select'), function (nestedModifier) {

        $(nestedModifier).click(function (event) {
          var modifier = item.findModifier($(event.target).attr('data-id'));
          var modifierGroup = item.findModifierGroup(modifier);
          var content = Handlebars.compile(HandlebarsTemplates['nested_modifier']({
            modifier: modifier,
            modifierGroup: modifierGroup
          }));

          if (!$('#current-nm').length) {
            $('#current-nm-container').append(content);
          }

          $('#menu-item-dialog').scrollTo(0);

          _.each(modifier.nestedItems, function (nested) {
            if ($('#modifier_item_' + nested.modifier_item_id).attr('checked') || nested.quantity == nested.modifier_item_max) {
              self.subtractCaloriesLabel(nested);
            }
          });

          self.bindRadioEvents(item, user);
          self.bindCheckboxEvents(item, user);
          self.updateModifierNetPriceText(item);
          self.bindAddEvents(item, user);
          self.bindSubEvents(item, user);
        });
      });
    }
    ,

    _updateModifierQuantityText: function (modifierGroup) {
      "use strict";

      if (modifierGroup !== void(0)) {
        var $mgQuantity = $("p[data-modifier-group-id='" + modifierGroup.id + "']");
        $mgQuantity.text(modifierGroup.getQuantityText());

        var $nestedQuantity = $("p.nested-modifier-quantity");
        $nestedQuantity.text(modifierGroup.getQuantityText());
      }
    }
    ,

    bindItemNoteEvent: function (limit) {
      $("#requests input").keyup(function () {
        $("#char-limit").text(limit - $(this).val().length);
      });
    }
    ,

    addCaloriesLabel: function (modifier) {
      $("#modifier-add-sub-" + modifier.modifier_item_id + "-mobile").text("+");
      $("#modifier-add-sub-" + modifier.modifier_item_id).text("Add");
    }
    ,
    subtractCaloriesLabel: function (modifier) {
      $("#modifier-add-sub-" + modifier.modifier_item_id + "-mobile").text("-");
      $("#modifier-add-sub-" + modifier.modifier_item_id).text("Subtract");
    }
    ,

    _editItemCallback: function (response) {
      this.show({
        item: new MenuItem(response.item),
        user: window.user,
        groupOrder: response.meta.group_order_token,
        edit: true
      });
    }
    ,

    _itemNotAdded: function (modQuantity) {
      return (modQuantity == 0);
    }
    ,

    _itemRedeemableInPoints: function (points) {
      return (points !== "" && points !== undefined);
    }
    /*$("#accordion" ).accordion({
        collapsible: true
    });*/

  }
;
