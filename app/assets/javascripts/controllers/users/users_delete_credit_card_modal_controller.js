var DeleteCreditCardModalController = {
  initialize: function (action_controller) {
    DeleteCreditCardModalController.showDeleteCreditCardModal(action_controller);
  },

  showDeleteCreditCardModal: function (action_controller) {
    var content_source = HandlebarsTemplates["delete_credit_card"]({
      "action": action_controller,
    });
    var container = Handlebars.compile(content_source);
    var dialog = new Dialog({
      title: "Delete Credit Card",
      content: container,
      id: 'delete-credit-card-dialog',
      "class": "delete-credit-card"
    });
    dialog.open();
  }
};
