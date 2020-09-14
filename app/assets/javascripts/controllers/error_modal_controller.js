ErrorModalController = {
  initialize: function(error_message) {
    ErrorModalController.initErrorModal(error_message)
  },

  initErrorModal: function(error_message) {
    var content_source = HandlebarsTemplates["error_message"]({
      message: error_message,
    });
    var content = Handlebars.compile(content_source);

    var dialog = new Dialog({
      title: "Incomplete Order",
      content: content,
      id: "error-message",
      "class": "error-message",
    });

    dialog.open();

    ErrorModalController.bindModalEvents(dialog);
  },

  bindModalEvents: function(dialog) {
    $("button.modal-close").click(function() {
      dialog.close();
    })
  },
};