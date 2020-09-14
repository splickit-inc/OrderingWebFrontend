$(document).on 'ready', ->

  this.addressService = new AddressService()
  if window.route == 'users/show'
    $(".tabs").tabs(
      {activate: (event, ui) =>
        window.location = event.currentTarget.href
      }
    )

    chosenAddrId = this.addressService.getPreferredAddress()
    $.map($(".address-check .actions input"), (e, i) ->
        addrId = $(e).val()
        $(e).prop('checked', (addrId == chosenAddrId))
    )

    $(".address-check input").on "click", (event) =>
      addrId = $(event.target).val()
      new UsersShowController(this.addressService).updatePreferredAddress(addrId);


  if window.route == 'user_payments/new'

    $('input#card_number').on 'keypress', (event) ->
      element = event.target
      card_number = element.value.replace /\s/g, ''
      if /[0-9]/.test(String.fromCharCode event.charCode) or event.altKey or event.ctrlKey or event.metaKey
        if card_number.length < 16
          element.value = card_number.replace /(.{4})/g, '$1 '
      else
        return false
  
  $(".delete-credit_card").on 'click', (event) ->
    submit_data = $(this).attr("data-delete-credit-card-url")
    if submit_data
      DeleteCreditCardModalController.initialize(submit_data)
    else
      alert "data delete credit card url is missing"