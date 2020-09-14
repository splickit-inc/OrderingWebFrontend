function UsersOrdersHistoryController() {
    this.setEvents();
};

UsersOrdersHistoryController.prototype.setEvents = function() {
  $(".pagination").rPage();
  $("button.add-favorite").click(function(e){
    var order_id = $(this).data("order-id");
    if (order_id) {
      AddFavoriteModalController.initialize(order_id);
    } else {
      alert("Order ID missing");
    }
  });
  $("div#order-data td:not(.add-favorite-button)").click(function(){
    var order_id = $(this).siblings("td.add-favorite-button").children("button").data("order-id");
    if (order_id) {
      OrderSummaryModalController.initialize(order_id);
    } else {
      alert("Order ID missing");
    }
  });
  $("div#order-data td:not(.add-favorite-button)").on("touchstart", function(){
    $(this).parent("tr").addClass("select");
  });
  $("div#order-data td:not(.add-favorite-button)").on("touchend", function(){
    $(this).parent("tr").removeClass("select");
  });
};
