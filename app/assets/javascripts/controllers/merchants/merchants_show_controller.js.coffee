class window.MerchantsShowController
  show: (params = {}) =>
    menu = new Menu
    menu.initialize()
    $('.user-favorite, .user-lastorder').each (index) ->
      target = $(this).data('target')
      targetID = $(this).data(target + '-id')
      targetItems = if target == "favorite" then window.favoriteItems[targetID] else window.lastOrderItems[targetID]
      targetOrderTotal = _.reduce targetItems, ((memo, menuItem) ->
        memo + menuItem.totalPrice().to_n()
      ), 0
      $(".user-" + target + "[data-" + target + "-id='" + targetID + "'] ." + target + "-price").text("$#{ targetOrderTotal.toFixed(2) }")

    $('.user-favorite h3, .user-lastorder h3, .user-favorite img, .user-lastorder img').on 'click', ->
      target = $(this).parent().data('target')
      targetItems = if target == "favorite" then window.favoriteItems[$(this).data target + '-id'] else window.lastOrderItems[$(this).data target + '-id']
      dialog = new Dialog
      dialog.addToOrder(targetItems)

    $('.items article').on 'click', ->
      groupOrder = ($('main').data('merchant-group-order-token') != "")
      item = window.menuItems[$(this).data 'menu-item-id']
      if(window.isCatering && window.order_type = 'pickup' && !!window.cateringNeedsConfig)
        if(window.cateringNeedsConfig == '2')
          dialog = new Dialog
            id: 'sign-in'
            content: HandlebarsTemplates['basic_modal_ok_cancel']({
              bodyContent: "Would you like to start your catering order?"
              currentMerchantID: params.merchantID
              orderType: window.order_type
              continueLink: encodeURIComponent("/caterings/begin?merchant_id=#{ params.merchantID }")
            })
          dialog.open()
          return

        if(window.signed_in)
          window.location = "/caterings/begin?merchant_id=#{ params.merchantID }"
          return
        else
          dialog = new Dialog
            customHeader: HandlebarsTemplates['sessions/sign_in_header'](window)
            id: 'sign-in'
            content: HandlebarsTemplates['sessions/sign_in']({
              window
              with_login: true
              continueUrl: encodeURIComponent(BeginCateringController.getCateringPath(params.merchantID, window.order_type))
              withoutGuest: true
            })

          dialog.open()
          return

      MenuItemsController.show({
        item: item,
        user: window.user,
        groupOrder: groupOrder,
        edit: false
      })

    $('.remove-favorite').on 'click', ->
      favorite_id = $(this).data('favorite-id')
      if favorite_id
        RemoveFavoriteModalController.initialize(favorite_id)
      else
        alert "Favorite ID missing"

    $("button.btn-remove-favorite").on 'click', ->
      RemoveFavoriteModalController.closeModal();

    enquire.register '(max-width: 640px)',
      match: @collapseMenuNav,
      unmatch: @expandMenuNav

    if $('#menu_header').outerHeight() > $('#menu_header a:first').outerHeight()
      @collapseMenuNav() unless $('#menu_header').data('collapsed')

    new OrderService().show(MyOrderController.openMyOrder) if params.modal

  expandMenuNav: () ->
    $(document).off 'click', 'nav#menu_header a'
    $('nav#menu_header').removeClass 'open'
    $('nav#menu_header').removeAttr 'data-collapsed'
    $('nav#menu_header a').removeClass 'current'
    $('nav#menu_header a').attr 'data-scroll', true

  collapseMenuNav: () ->
    $('nav#menu_header').attr 'data-collapsed', true
    $('nav#menu_header a.current').attr 'data-scroll', false
    $(document).on 'click', 'nav#menu_header a', ->
      link = $(this)
      if link.hasClass 'current'
        $('nav#menu_header').addClass 'open'
        $('nav#menu_header a').removeClass 'current'
        $('nav#menu_header a').attr 'data-scroll', true
        false
      else
        $('nav#menu_header').removeClass 'open'
        $(this).addClass 'current'
        $(this).attr 'data-scroll', false

