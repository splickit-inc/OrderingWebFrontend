var MINUTE = 60000;
var YOU_PAY = 1;
var INVITE_PAY = 2;

function GroupOrdersCreateController(merchant_id, order_type, group_order_type) {

  this.refreshInterval = MINUTE * 5;
  this.OrderType = order_type;
  this.GroupOrderType = group_order_type == undefined ? YOU_PAY : group_order_type;
  this.MerchantId = merchant_id;

  this.bindRefreshInterval();
  this.bindChangeGroupOrderType();
  this.disableSendButton();
  this.getGroupOrderAvailableTimes();

};

GroupOrdersCreateController.prototype.bindRefreshInterval = function() {

  var self = this;

  window.setInterval(function refreshItems() {
    self.getGroupOrderAvailableTimes();
  }, this.refreshInterval);

};

GroupOrdersCreateController.prototype.bindChangeGroupOrderType = function() {

  var self = this;

  $('.group-order-type input[type="radio"]').on('click', function() {
    self.GroupOrderType = $(this).val();
    $("#order_submit_time").hide();
    self.disableSendButton();
    self.getGroupOrderAvailableTimes();
  });
};

GroupOrdersCreateController.prototype.getGroupOrderAvailableTimes = function() {
  var self = this;

  if(self.GroupOrderType == INVITE_PAY) {
    self.enableAvailableTimes();

    $.ajax({
      url: "/merchants/" + self.MerchantId + "/group_order_available_times/" + self.OrderType,
      type: "GET",
      success: function(response) {
        $select =  $("#order_submit_time select");
        $select.find('option').remove();
        $.each(response, function( index, value ) {
          $select.append("<option value='" + value[1] + "'>" + value[0] + "</option>");
        });
        self.enableSendButton();
      },
      error: function(response) { }
    });
  }
  else
  {
    self.enableAvailableTimes();
    self.enableSendButton();
  }
};

GroupOrdersCreateController.prototype.disableSendButton = function() {
  var button = $('.new_group_order input[type=submit]');
  button.addClass("disabled");
  button.attr("disabled", true)
};

GroupOrdersCreateController.prototype.enableSendButton = function() {
  var button = $('.new_group_order input[type=submit]');
  button.removeClass("disabled");
  button.attr("disabled", false)
};


GroupOrdersCreateController.prototype.enableAvailableTimes = function(){
  var self = this;
  if(self.GroupOrderType == YOU_PAY) {
    $("#order_submit_time").hide();
    $("#order_submit_time select").find('option').remove();
    $("#group-order-invitees-pay-note").hide();
  }
  else
  {
    $("#order_submit_time").show();
    $("#group-order-invitees-pay-note").show();
  }
}


