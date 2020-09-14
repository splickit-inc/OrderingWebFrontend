var WarningModalController = (function () {
  function WarningModalController(params) {
    this.warning_title = params.warning_title;
    this.warning_message = params.warning_message;
    this.no_close = params.no_close || false;
    this.button_callback = params.button_callback;

    this.open();
  };

  WarningModalController.prototype.open = function () {
    var content_source = HandlebarsTemplates["warning_message"]({
      title: this.warning_title,
      message: this.warning_message,
    });
    var content = Handlebars.compile(content_source);

    this.dialog = new Dialog({
      title: this.warning_title,
      content: content,
      id: "error-message",
      "class": "error-message",
    });

    this.button_callback = this.button_callback || this.dialog.close;

    this.dialog.open();

    if (this.no_close) {
      this.dialog.unbindCloseEvents();
      $("span[data-dialog-close]").hide();
    }

    this.bindModalEvents();
  };

  WarningModalController.prototype.bindModalEvents = function () {
    $("button.modal-close").click(this.button_callback);
  };

  return WarningModalController;
})();