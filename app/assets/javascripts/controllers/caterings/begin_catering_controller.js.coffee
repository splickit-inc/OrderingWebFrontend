class window.BeginCateringController
  init: (params = {}) =>
# these don't work in the map
    $('a.pickup.button').on('click', (event) ->
      BeginCateringController.buttonAction(event, 'pickup')
      GoogleAnalyticsService.track('merchants', 'showMenu', 'pickup')
    )

    # these don't work in the map
    $('a.delivery.button').on('click', (event) ->
      BeginCateringController.buttonAction(event, 'delivery')
      GoogleAnalyticsService.track('merchants', 'showMenu', 'delivery')
    )

    DeliveryModalController.initialize({
      path: parseParams().delivery_path
    }) if isPresent(parseParams().delivery_path)

    MerchantsIndexController.itemCount = $('main').data('item-count')
    MerchantsIndexController.activeMerchantID = $('main').data('active-merchant-id')
    MerchantsIndexController.activeCateringOrder = $('main').data('active-catering-order')

  @getCateringPath: (currentMerchantID, orderType) ->
    differentMerchants = @activeMerchantID != currentMerchantID

    if !differentMerchants && @activeCateringOrder
      return "/merchants/#{ currentMerchantID }?order_type=#{ orderType }&catering=1"
    else
      return "/caterings/new?merchant_id=#{ currentMerchantID }&order_type=#{ orderType }"

  @getCateringBeginPath: (currentMerchantID, orderType) ->
    differentMerchants = @activeMerchantID != currentMerchantID

    if !differentMerchants && @activeCateringOrder
      return "/merchants/#{ currentMerchantID }?order_type=#{ orderType }&catering=1"
    else
      return "/caterings/begin?merchant_id=#{ currentMerchantID }&order_type=#{ orderType }"

  @orderTypeButtonAction: (orderType, currentMerchantID, is_guest_user) =>
    switch orderType
      when 'delivery'
        if(window.signed_in || is_guest_user)
          DeliveryModalController.initialize({
            path: @getCateringBeginPath(currentMerchantID, orderType),
            current_path: "/caterings/begin?merchant_id=#{ currentMerchantID }"
          })
        else
          continueUrl = encodeURIComponent("/caterings/begin?merchant_id=#{currentMerchantID}&delivery_path=" + encodeURIComponent(encodeURIComponent(@getCateringBeginPath(currentMerchantID, orderType))))
          window.openLoginModal({continueUrl: continueUrl})
      when 'pickup'
        continueUrl = @getCateringBeginPath(currentMerchantID, orderType)
        #continueUrl = "/merchants/#{ currentMerchantID }?order_type=#{ orderType }&catering=1&set_config=1"
        if(window.signed_in || is_guest_user)
          window.location = continueUrl
        else
          window.openLoginModal({continueUrl: encodeURIComponent(continueUrl)})
      else
        window.location = "/caterings/begin?merchant_id=#{ currentMerchantID }"

  @guestUserPermissionsCheck: (orderType, currentMerchantID, isGuest) =>
    orderMode = "catering"
    if isGuest
      @showBasicModal({
        continueUrl: encodeURIComponent("/caterings/new?merchant_id=#{ currentMerchantID }&order_type=#{ orderType }"),
        currentMerchantID: currentMerchantID,
        orderType: orderType,
        orderMode: orderMode,
      });
      return true;

  @buttonAction: (event, orderType) =>
    event.preventDefault()
    $element = $(event.target)
    currentMerchant = $element.data('merchant-id')
    is_guest_user = $element.data('user-is-guest')
    activeMerchantExists = isPresent(@activeMerchantID)
    currentMerchantExists = isPresent(currentMerchant)
    itemsInCart = @itemCount > 0
    differentMerchants = @activeMerchantID != currentMerchant
    differentOrderTypes = @activeCateringOrder != true

    #if(@guestUserPermissionsCheck(orderType, currentMerchant, is_guest_user))
    #  return

    if activeMerchantExists && currentMerchantExists && itemsInCart && (differentMerchants || differentOrderTypes)
      new MerchantsChangeController().openDialog({
        redirectCallback: "/caterings/begin?merchant_id=#{ currentMerchant }",
        currentMerchantID: currentMerchant,
        orderType: orderType,
        differentMerchants: differentMerchants,
        event: event
      })
    else
      @orderTypeButtonAction(orderType, currentMerchant, is_guest_user)

  parseParams = (search = window.location.search) ->
    d = (str)-> decodeURIComponent str.replace /\+/g, ' '
    query = search.substring 1
    regex = /(.*?)=([^\&]*)&?/g
    params = {}
    params[d(m[1])] = d(m[2]) while m = regex.exec query
    params

  @showBasicModal = (params = {}) =>
    new MerchantsIsGuestController().openDialog({
      continueLink: params.continueUrl,
      currentMerchantID: params.currentMerchantID,
      orderType: params.orderType,
      orderMode: params.orderMode,
      title: params.title,
      bodyContent: params.bodyContent
    })