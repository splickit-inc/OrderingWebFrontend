class window.AddressService

  @constructor: () ->

  getPreferredAddress: () ->
    if (@getCookie())
      cookie = JSON.parse(@getCookie())
    else
      cookie = {}

    cookie.preferredAddressId

  storePreferredAddress: (addressId) ->
    if (@getCookie())
      cookie = JSON.parse(@getCookie())
    else
      cookie = {}

    cookie.preferredAddressId = addressId
    $.cookie(@cookieName(), JSON.stringify(cookie), { expires: 1, path: '/' })
    cookie

  getCookie: () ->
    $.cookie(@cookieName())

  cookieName: () ->
    "userPrefs"
    
