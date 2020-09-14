var __bind = function (fn, me) {
  return function () {
    return fn.apply(me, arguments);
  };
};

window.Dialog = (function () {
  Dialog.opened = [];

  //Class methods
  Dialog.focusDialog = function () {
    return Dialog.opened[Dialog.opened.length - 1];
  };

  Dialog.closeKeyEvent = function (event) {
    if (event.keyCode == 27) {
      Dialog.focusDialog().close();
    }
  };

  Dialog.resizeAll = function () {
    _.each(Dialog.opened, function (dialog) {
      dialog.setContentHeight();
    });
  };

  Dialog.zIndexForNewDialog = function () {
    var last_dialog = _.max(Dialog.opened, function (dialog) {
      return dialog.dialog.zIndex()
    });
    return last_dialog ? last_dialog.dialog.zIndex() : 0;
  };

  Dialog.close_all = function () {
    var dialog, _i, _len, _ref, _results;
    _ref = Dialog.opened;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      dialog = _ref[_i];
      _results.push(dialog.close());
    }
    return _results;
  };

  Dialog.addItemCallback = function (response) {
    if (response.order.items.length > 0) {
      Dialog.updateCounter(response);
      Dialog.displayAddConfirmationPopup();
    }
  };

  Dialog.updateCounter = function (response) {
    var length = 0;
    if (response.order) {
      length = response.order.items.length;
    }

    $('header .order').attr('data-item-count', length);
  };

  Dialog.displayAddConfirmationPopup = function () {
    var checkoutURL, popupClass, title;
    var checkoutText = "Checkout";
    var groupOrderToken = $('main').data('merchant-group-order-token');
    var merchantID = $('main').data('merchant-id');
    var orderType = $('main').data('merchant-order-type');
    var isWtjmmj = this.is_wtjmmj();

    if (groupOrderToken !== "" && groupOrderToken !== void 0) {
      checkoutURL = "/checkouts/new?group_order_token=" + groupOrderToken + "&merchant_id=" + merchantID + "&order_type=" + orderType;
      title = "Item Added to My Cart";
      popupClass = "group-order";

      checkoutText = "Submit to Group Order";

      nav_bar = $('body > header nav.primary');
      var isGroupOrderOrganizer = nav_bar.find(' a.group-order-status');
      if (isGroupOrderOrganizer.length > 0)
        popupClass += " group-order-status";

    } else {
      checkoutURL = "/checkouts/new?merchant_id=" + merchantID + "&order_type=" + orderType;
      title = "Item successfully added";
    }
    $("header").append(Handlebars.compile(HandlebarsTemplates['merchants/item_added_popup']({
      item_added_popup_title: title,
      checkoutURL: checkoutURL,
      checkoutText: checkoutText,
      isWtjmmj: isWtjmmj,
      popupClass: popupClass
    })));

    this.fadeInPopup();
    this.bindPopupClose();
    return this.bindDisplayMyOrder();
  };

  Dialog.fadeInPopup = function () {
    return $('#item-added-popup').fadeIn("fast");
  };

  Dialog.bindPopupClose = function () {
    return $("body").click(function () {
      return $('#item-added-popup').remove();
    });
  };

  Dialog.bindDisplayMyOrder = function () {
    return $("#item-added-view-order").click(function () {
      return window.orderService.show(MyOrderController.openMyOrder);
    });
  };

  Dialog.is_wtjmmj =  function(){
    if (window.skin.skinName == "wtjmmj"){
      return true;
    }
  };

  Dialog.updateCheckoutTotal = function (priceString) {
    return $("#my-order button.checkout").text("Checkout " + priceString);
  };

  Dialog.redirect = function (url) {
    return window.location.href = url;
  };

  Dialog.submitToGroupOrder = function (orderMeta) {
    var redirect_url;
    redirect_url = "/checkouts/new?group_order_token=" + orderMeta.group_order_token;
    redirect_url = redirect_url + ("&merchant_id=" + orderMeta.merchant_id);
    redirect_url = redirect_url + ("&order_type=" + orderMeta.order_type);
    return Dialog.redirect(redirect_url);
  };

  Dialog.checkout = function () {
    return Dialog.redirect("/order/checkout");
  };

  Dialog.removeItem = function (uuid, callback) {
    var orderService;
    orderService = new OrderService();
    return orderService.deleteItem(uuid, callback);
  };

  function Dialog(data) {
    this.data = data != null ? data : {};
    this.Dialog = __bind(this.Dialog, this);
    this.addToOrder = __bind(this.addToOrder, this);
    this.setContentHeight = __bind(this.setContentHeight, this);
    this.close = __bind(this.close, this);
    this.open = __bind(this.open, this);
    this.body = $('body');
    this.overlay = $(HandlebarsTemplates['overlay']());
    this.dialog = $(Handlebars.compile(HandlebarsTemplates['dialog'](this.data))(this.data));
    this.orderService = new OrderService();
    this.onClose = !!data && !!data.onClose ? data.onClose : null;
  }

  Dialog.prototype.open = function () {
    Dialog.close_all();
    return this.openMultiple();
  };

  Dialog.prototype.openMultiple = function () {
    Dialog.opened.push(this);
    var zIndex = Dialog.zIndexForNewDialog();
    this.overlay.zIndex(zIndex);
    this.dialog.zIndex(zIndex + 10);
    $("body").attr('data-dialog-open', '');
    this.body.append([this.overlay, this.dialog]);
    this.setContentHeight();
    this.bindCloseEvents();
    Dialog.focusDialog().dialog.focus();
    return $('input').placeholder();
  };

  Dialog.prototype.close = function () {
    Dialog.opened = _.without(Dialog.opened, this);
    this.unbindCloseEvents();
    this.body.removeAttr('data-dialog-open');
    this.overlay.remove();
    this.dialog.remove();
    if (this.onClose !== null) {
      this.onClose();
      this.onClose = null;
    }
    // Jasmine has problems with one line syntax
    if (focusDialog = Dialog.focusDialog()) {
      return focusDialog.dialog.focus();
    } else {
      return null;
    }
  };

  Dialog.prototype.bindCloseEvents = function () {
    this.overlay.click(this.close);
    this.dialog.on("click", '[data-dialog-close]', this.close);
    this.dialog.on('keydown', Dialog.closeKeyEvent);
  };

  Dialog.prototype.unbindCloseEvents = function () {
    this.overlay.off('click', this.close);
    this.dialog.off('click', '[data-dialog-close]', this.close);
    this.dialog.off('keydown', Dialog.closeKeyEvent);
  };

  Dialog.prototype.setContentHeight = function () {
    var header = this.dialog.find('[data-dialog-header]');
    var footer = this.dialog.find('[data-dialog-footer]');
    var content = this.dialog.find('[data-dialog-content]');

    content.css({
      height: 'auto'
    });

    var height = this.dialog.outerHeight() + 1;

    if (header.length) {
      height -= header.outerHeight();
    }

    if (footer.length) {
      height -= footer.outerHeight();
    }

    content.css({
      height: height
    });

    return this.dialog;
  };

  Dialog.prototype.addToOrder = function (items, payWith, checkout, edit) {
    var cartItems = new MenuItems({
      items: items,
      payWith: payWith
    });
    var itemsJSON = cartItems.getJSONItems();

    if (checkout === true) {
      if (edit === true) {
        return this.orderService.updateItem(itemsJSON[0], Dialog.checkout);
      } else {
        return this.orderService.createItem(itemsJSON, Dialog.checkout);
      }
    } else {
      if (edit === true) {
        return this.orderService.updateItem(itemsJSON[0], Dialog.addItemCallback);
      } else {
        return this.orderService.createItem(itemsJSON, Dialog.addItemCallback);
      }
    }
  };

  return Dialog;
})();
