class window.MerchantsIndexController
  index: (params = {}) =>
    if window.merchants_json
      if isBlank(params.mapUrl) && mapBoxAvailable
        merchants_json_for_map = []

        merchants_json_for_map.push(MerchantsIndexController.merchantDataForMap(merchant)) for merchant in merchants_json

        new MapsController({merchantsData: merchants_json_for_map})

      #location page caterings and group order checkboxes events
      $(".checkbox-group-order, .checkbox-catering").on("click", (event) ->
        order_type_check = $(this).parents(".checkbox-container").siblings().find("input")
        catering_buttons = $(this).parents(".buttons").find('.catering-buttons > a.catering.button');
        if $(this).is(':checked')
          catering_buttons.each((index, element) ->
            $(element).attr("disabled", "disabled")
          )
          $(order_type_check).prop('checked', false)
          $(order_type_check).removeAttr('checked')
        else
          catering_buttons.each((index, element) ->
            $(element).removeAttr("disabled")
          )
      )

      # these don't work in the map
      $('a.pickup.button').on('click', (event) ->
        MerchantsIndexController.buttonAction(event, 'pickup')
        GoogleAnalyticsService.track('merchants', 'showMenu', 'pickup')
      )

      # these don't work in the map
      $('a.delivery.button').on('click', (event) ->
        MerchantsIndexController.buttonAction(event, 'delivery')
        GoogleAnalyticsService.track('merchants', 'showMenu', 'delivery')
      )

      # these don't work in the map
      $('a.catering.button').on('click', (event) ->
        MerchantsIndexController.buttonAction(event, 'catering')
        GoogleAnalyticsService.track('merchants', 'showMenu', 'catering')
      )

    DeliveryModalController.initialize({path: params.deliveryPath}) if isPresent(params.deliveryPath)

    MerchantsIndexController.itemCount = $('main').data('item-count')
    MerchantsIndexController.activeMerchantID = $('main').data('active-merchant-id')
    MerchantsIndexController.activeCateringOrder = $('main').data('active-catering-order')

  @merchantDataForMap: (merchant) ->
    phone = if isPresent(merchant.phone_no)
      merchant.phone_no.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3')
    else
      ""

    content = "
      <div class='info-window#{ if merchant.delivery == 'Y' then ' delivery' else '' }'>
        <h3>#{ merchant.brand }</h3>
        <p>#{ merchant.address1 }, #{ merchant.city }, #{ merchant.state } #{ merchant.zip }</p>
        <p>#{ phone }</p>
        <figure class='buttons'>
          <a class='delivery button' href='/merchants/#{ merchant.merchant_id }?order_type=delivery' data-merchant-id='#{ merchant.merchant_id }' data-merchant-name='#{ merchant.name }'>
            Delivery
          </a>
          <a class='pickup button' href='/merchants/#{ merchant.merchant_id }?order_type=pickup' data-merchant-id='#{ merchant.merchant_id }' data-merchant-name='#{ merchant.name }'>
            Pickup
          </a>
        </figure>
      </div>
    "

    json = {
      latitude: merchant.lat,
      longitude: merchant.lng,
      content: content
    }

  @getCateringPath: (currentMerchantID, orderType) ->
    differentMerchants = @activeMerchantID != currentMerchantID

    if !differentMerchants && @activeCateringOrder
      return "/merchants/#{ currentMerchantID }?order_type=#{ orderType }&catering=1"
    else
      return "/caterings/new?merchant_id=#{ currentMerchantID }&order_type=#{ orderType }"

  @getOrderRedirectPath: (currentMerchantID, orderType) =>
    if @isCatering(currentMerchantID)
      return @getCateringPath(currentMerchantID, orderType)
    if @isGroupOrder(currentMerchantID)
      return "/group_orders/new?merchant_id=#{ currentMerchantID }&order_type=#{ orderType }"

    return "/merchants/#{ currentMerchantID }?order_type=#{ orderType }"

  @isCatering: (merchantID) ->
    $catering = $("input[type='checkbox'][data-merchant-id='" + merchantID + "'].checkbox-catering")
    $catering.is(":checked")

  @isGroupOrder: (merchantID) ->
    $group_order = $("input[type='checkbox'][data-merchant-id='" + merchantID + "'].checkbox-group-order")
    $group_order.is(":checked")

  @orderModifier: (merchantID) =>
    return "catering" if @isCatering(merchantID)
    return "group" if @isGroupOrder(merchantID)
    "standard"

  @orderTypeButtonAction: (orderType, currentMerchantID) =>
    if skin.isGoodCents()
      external_host = "https://goodcentssubs.olo.com/"
      switch currentMerchantID
        when 106004
          return window.location = external_host+"menu/goodcents-1033-lorene";
        when 106043
          return window.location = external_host+"menu/goodcents-1035-cobblestone-cntr";
        when 106082
          return window.location = external_host+"menu/goodcents-1037-103rd-s-memorial-d";
        when 106067
          return window.location = external_host+"menu/goodcents-1009-kansas-kearney";
        when 106068
          return window.location = external_host+"menu/goodcents-1021-battlefield";
        when 106051
          return window.location = external_host+"menu/goodcents-33-s-glenstone";
        when 106053
          return window.location = external_host+"menu/goodcents-39-national";
        when 106009
          return window.location = external_host+"menu/goodcents-1008-grnwy-rd-loop-303";
        when 106718
          return window.location = external_host+"menu/goodcents-1020-kyrene-elliot";
        when 106006
          return window.location = external_host+"menu/goodcents-72-n-19-ave-union-hil";
        when 106007
          return window.location = external_host+"menu/goodcents-80-thunderbird";
        when 106008
          return window.location = external_host+"menu/goodcents-187-bell-rd-89th";
        

    switch orderType
      when 'delivery'
        DeliveryModalController.initialize({
          path: @getOrderRedirectPath(currentMerchantID, orderType)
        })
      when 'catering'
        window.location = "/caterings/begin?merchant_id=#{ currentMerchantID }"
      else
        window.location = @getOrderRedirectPath(currentMerchantID, orderType)

  @guestUserPermissionsCheck: (orderType, currentMerchantID, isGuest) =>
    isCatering = @isCatering(currentMerchantID)
    isGroupOrder = @isGroupOrder(currentMerchantID)
    if(isCatering)
      orderMode = "catering"
    else
      orderMode = "group"

    if isGuest && (isCatering || isGroupOrder)
      new MerchantsIsGuestController().openDialog({
        continueLink: encodeURIComponent(@getOrderRedirectPath(currentMerchantID, orderType)),
        currentMerchantID: currentMerchantID,
        orderType: orderType,
        orderMode: orderMode,
      })
      return true;

  @buttonAction: (event, orderType) =>
    $element = $(event.target)
    currentMerchant = $element.data('merchant-id')
    is_guest_user = $element.data('user-is-guest')

    activeMerchantExists = isPresent(@activeMerchantID)
    currentMerchantExists = isPresent(currentMerchant)
    itemsInCart = @itemCount > 0
    differentMerchants = @activeMerchantID != currentMerchant
    differentOrderTypes = @activeCateringOrder != @isCatering(currentMerchant)

    event.preventDefault()
    if(@guestUserPermissionsCheck(orderType, currentMerchant, is_guest_user))
      return

    if activeMerchantExists && currentMerchantExists && itemsInCart && (differentMerchants || differentOrderTypes)
      new MerchantsChangeController().openDialog({
        redirectCallback: @orderTypeButtonAction,
        currentMerchantID: currentMerchant,
        orderType: orderType,
        differentMerchants: differentMerchants,
        event: event
      })
    else
      @orderTypeButtonAction(orderType, currentMerchant)
