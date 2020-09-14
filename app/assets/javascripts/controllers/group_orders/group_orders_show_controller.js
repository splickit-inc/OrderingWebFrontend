var MINUTE = 60000;

function GroupOrdersShowController() {
  this.refreshInterval = MINUTE;
  this.groupOrderToken = $("#order-summary").attr("data-group-order-token");
  this.order_summary_element = $("div#order-summary .data");
  this.btnIncrementTime = $('#increment-button');
  this.btnAddItems = $('#add');
  this.btnCheckout = $('#checkout');
  this.btnCancel = $('#btn_cancel');
  this.bindDeleteEvents();
  this.bindRefreshInterval();
  this.bindCancelOrderEvent();
  this.bindIncrementEvent();
};

GroupOrdersShowController.prototype.bindIncrementEvent = function () {
  var self = this;

  this.btnIncrementTime.click(function () {
    self.btnIncrementTime.load();
    var time = "10";

    $.ajax({
      url: "/group_orders/" + self.groupOrderToken + "/increment/" + time,
      type: "POST",
      context: this,
      success: function (response) {
        self.updateExpireTime(response.send_on_local_time_string);
      },
      error: function (response) {
        new WarningModalController({
          warning_title: "Group Order Error",
          warning_message: "Sorry your auto submit time can not be pushed back any farther."
        });
      },
      complete: function () {
        self.btnIncrementTime.finishLoad();
      }
    });
  });
};

GroupOrdersShowController.prototype.updateExpireTime = function (time) {
  $("#expire-at").text(time);
};

GroupOrdersShowController.prototype.bindRefreshInterval = function () {
  var self = this;

  window.setInterval(function refreshItems() {
    self.getGroupOrder();
  }, this.refreshInterval);
};

GroupOrdersShowController.prototype.bindCancelOrderEvent = function () {
  var self = this;

  $("#cancel").click(function (event) {
    self.openCancelOrderDialog(event);
  });
};

GroupOrdersShowController.prototype.bindDeleteEvents = function () {
  var self = this;

  $('[data-item-id]').click(function () {
    var itemID = $(this).attr("data-item-id");

    $.ajax({
      url: "/group_orders/remove_item" + "?" + $.param({
        item_id: itemID,
        group_order_token: self.groupOrderToken
      }),
      type: "DELETE",
      success: function (response) {
        if (response.itemCount === 0) {
          self.disableCheckoutButton(response.itemCount);
          $(".user-items").append('<p>No items have been added to the group order yet.</p>');
        }
        self.hideItem(itemID);
      }
    });
  });
};

GroupOrdersShowController.prototype.openCancelOrderDialog = function (event) {
  event.preventDefault();

  var template = Handlebars.compile(HandlebarsTemplates['group_orders/cancel']());
  var dialog = new Dialog({
    title: "Are you sure you want to cancel this group order?",
    id: "cancel-group-order",
    content: template
  });

  dialog.open();

  $("#cancel-abort").click(function () {
    dialog.close();
  });

  $("#cancel-proceed").click(function () {
    $(".buttons form").submit();
  });
};

GroupOrdersShowController.prototype.disableAddItemsButton = function () {
  this.btnAddItems.disable();
};

GroupOrdersShowController.prototype.disableIncrementTimeButton = function () {
  this.btnIncrementTime.disable();
};

GroupOrdersShowController.prototype.disableCheckoutButton = function () {
  this.btnCheckout.disable();
};

GroupOrdersShowController.prototype.enableCheckoutButton = function () {
  this.btnCheckout.enable();
};

GroupOrdersShowController.prototype.disableCancelButton = function () {
  this.btnCancel.disable();
};

GroupOrdersShowController.prototype.enableCancelButton = function () {
  this.btnCancel.enable();
};

GroupOrdersShowController.prototype.hideItem = function (itemID) {
  $("[data-item=" + itemID + "]").hide();
};

GroupOrdersShowController.prototype.showInviteMorePeopleSection = function (show) {
  if (show == undefined || show === true) {
    $("#invite-more-people").show();
  } else if (show === false) {
    $("#invite-more-people").hide();
  }
};

GroupOrdersShowController.prototype.getGroupOrder = function () {
  var self = this;

  $.ajax({
    url: "/group_order" + "/" + self.groupOrderToken,
    type: "GET",
    success: function (response) {
      if (response.order_summary) {
        self.renderGroupOrderDetails(response);
      }

      if (response.total_submitted_orders.to_i() > 0) {
        self.enableCheckoutButton();
      } else {
        self.disableCheckoutButton();
      }

      if (response.status.toUpperCase() === "SUBMITTED") {
        self.disableIncrementTimeButton();
        self.disableAddItemsButton();
        self.disableCheckoutButton();
        self.disableCancelButton();
        self.showInviteMorePeopleSection(false);
      }
    },
    error: function (response) {
    }
  });
};

GroupOrdersShowController.prototype.updateStatus = function (response) {
  $("section#modifiers span#status").text(response.status);
};

GroupOrdersShowController.prototype.updateOrdersCounter = function (response) {
  $("section#modifiers span#submitted-orders").text(response.total_submitted_orders);
};

GroupOrdersShowController.prototype.renderGroupOrderDetails = function (response) {
  this.order_summary_element.empty();

  if (response.group_order_type.to_i() == 2) {
    this.renderUsersData(response.order_summary.user_items);
    this.updateStatus(response);
  } else {
    this.renderItemsData(response.order_summary.cart_items, response.status);
    this.bindDeleteEvents();
  }
  this.updateOrdersCounter(response);
};

GroupOrdersShowController.prototype.renderItemsData = function (items, group_order_status) {
  console.log(group_order_status);
  _.each(items, function (item) {
    this.order_summary_element.append(Handlebars.compile(HandlebarsTemplates['group_orders/item']({
      order_detail_id: item.order_detail_id,
      item_name: item.item_name,
      item_price: item.item_price,
      item_description: item.item_description,
      item_note: item.item_note,
      can_delete: group_order_status.toUpperCase() != "SUBMITTED"
    })));
  }, this);
};

GroupOrdersShowController.prototype.renderUsersData = function (users) {
  _.each(users, function (user, index) {
    this.order_summary_element.append(Handlebars.compile(HandlebarsTemplates['group_orders/user']({
      user: user,
      index: index + 1
    })));
  }, this);
};
