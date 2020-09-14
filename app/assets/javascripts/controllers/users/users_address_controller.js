function UsersAddressController() {
  this.addressService = new AddressService();
  this.setDefault(this.getAddress());
  this.setEvents();
};

UsersAddressController.prototype.setEvents = function() {
  var self = this;
  $("input[type='radio']").click(function(event) {
    self.setAddress(event.currentTarget.value);
  });

  $(".delete-address").click(function(event){
    var user_addr_id = $(this).data('user-addr-id');
    self.showDeleteAddress(user_addr_id);
  });
};

UsersAddressController.prototype.getAddress = function() {
  return this.addressService.getPreferredAddress();
};

UsersAddressController.prototype.setAddress = function(address_id) {
  this.addressService.storePreferredAddress(address_id);
};

UsersAddressController.prototype.setDefault = function(address_id) {
  if (address_id != undefined) {
    $("input[value='" + address_id + "']").prop('checked', true);
  } else {
    $("#addresses article:first-of-type input").prop('checked', true);
  }
};

UsersAddressController.prototype.showDeleteAddress = function(user_addr_id){
  var content_source = HandlebarsTemplates["delete_address"]({
    url: "/user/address/" + user_addr_id
  });

  var content = Handlebars.compile(content_source);

  var dialog = new Dialog({
    title: "Delete delivery address",
    content: content,
    id: "delivery-address"
  });

  dialog.openMultiple();

  $('.btn-delete-usr-addr').on('click', function(event){
    var usr_selection = $(this).data('delete');
    if(usr_selection == 'no'){
      dialog.close();
    }
  });

  return dialog;
};
