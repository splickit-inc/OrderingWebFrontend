var OrderSummaryModalController = {

  initialize: function(order_id) {
    OrderSummaryModalController.initOrderSummaryModal(order_id);
  },

  initOrderSummaryModal: function(order_id) {
    var order = window.orders[order_id];
    var content_source = HandlebarsTemplates["order_summary"]({
      "order": order
    });
    var content = Handlebars.compile(content_source);

    var dialog = new Dialog({
      title: "Order Summary",
      content: content,
      id: "order-summary",
      "class": "order-summary"
    });

    dialog.open();
  }
};
