var RemoveFavoriteModalController = {
  initialize: function (favorite_id) {
    RemoveFavoriteModalController.showDeleteFavoriteModal(favorite_id);
  },

  showDeleteFavoriteModal: function (favorite_id) {
    var content_source = HandlebarsTemplates["remove_favorite"]({
      "action": '/favorites/' + favorite_id,
    });
    var container = Handlebars.compile(content_source);
    var dialog = new Dialog({
      title: "Delete Favorite",
      content: container,
      id: 'remove-favorite-dialog',
      "class": "remove-favorite"
    });
    dialog.open();
    RemoveFavoriteModalController.bindModalEvents(dialog);
  },

  bindModalEvents: function (dialog) {
    $('a.modal-btn-remove-favorite-no').click(function () {
      dialog.close();
    });
  }
};
