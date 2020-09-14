window.OrderService = (function() {
  function OrderService() {
  }

  OrderService.prototype.show = function(callback) {
    return $.ajax({
      type: "GET",
      url: "/order",
      success: callback
    });
  };

  OrderService.prototype.createItem = function(items, callback) {

    var merchantID      = $("main").data("merchant-id");
    var menuType        = $('main').data('merchant-order-type');
    var merchantName    = $("main").data("merchant-name");
    var groupOrderToken = $("main").data("merchant-group-order-token");

    return $.ajax({
      type: "POST",
      url: "/order/item",
      data: {
        items: JSON.stringify(items),
        merchant_id: merchantID,
        order_type: menuType,
        merchant_name: merchantName,
        group_order_token: groupOrderToken
      },
      success: callback
    });
  };

  OrderService.prototype.showItem = function(itemID, callback) {
    return $.ajax({
      type: "GET",
      url: "/order/item/" + itemID,
      success: callback
    });
  };

  OrderService.prototype.updateItem = function(item, callback) {
    return $.ajax({
      type: "PUT",
      url: "/order/item/" + item.uuid,
      data : {
        item: item
      },
      success: callback
    });
  };

  OrderService.prototype.deleteItem = function(itemID, callback) {
    return $.ajax({
      type: "DELETE",
      url: "/order/item/" + itemID,
      success: callback
    });
  };

  OrderService.prototype.saveOrderDetailForCheckout = function(day, time, tip, note, payment, verifyExtra, dine_in, curbside, make, color) {
    var data = $.cookie('orderDetail');
    var cookie = {};

    if(data){
      cookie = JSON.parse(data);
    }
    if(day){
        cookie.day = day;
    }

    cookie.time = time;
    cookie.tip = tip;
    cookie.note = note;
    cookie.payment = payment;
    if (verifyExtra){
        cookie.dine_in = dine_in;
        cookie.curbside = curbside;
        cookie.make = make;
        cookie.color = color;
    }
    $.cookie('orderDetail', JSON.stringify(cookie), { expires: 1, path: '/' });
  };

  return OrderService;
})();
