var AddFavoriteModalController = {

  initialize: function(order_id) {
    AddFavoriteModalController.initAddFavoriteModal(order_id);
  },

  initAddFavoriteModal: function(order_id) {
    var order = window.orders[order_id];
    var content_source = HandlebarsTemplates["add_favorite"]({
      "order_id": order.order_id,
    });
    var content = Handlebars.compile(content_source);

    var dialog = new Dialog({
      title: "Add Favorite",
      content: content,
      id: "add-favorite",
      "class": "add-favorite"
    });

    dialog.open();
  }
};
