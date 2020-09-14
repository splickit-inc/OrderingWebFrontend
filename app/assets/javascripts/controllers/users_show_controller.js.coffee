class window.UsersShowController
  constructor: (@addressService) ->

  updatePreferredAddress: (nextAddrId) ->
    this.addressService.storePreferredAddress(nextAddrId)
