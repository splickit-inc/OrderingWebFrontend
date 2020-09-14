class window.MyOrderController
  @openMyOrder: (response) =>
    order = response.order
    totals = MyOrderController.calcTotals(order.items)
    cashTotal = totals.cash
    pointsTotal = totals.points
    order.iswtjmmj = @isWtjmmj()
    order.subtotal_string = @getSubtotalString(cashTotal, pointsTotal)

    if order.meta != undefined
      order.group_order = (order.meta.group_order_token != "" && order.meta.group_order_token != undefined)

    order.activeMerchantURL = @merchantMenuPath(order.meta)

    Handlebars.registerPartial("my_order_items", Handlebars.compile(
      HandlebarsTemplates['my_order_items']({
        order: order,
      })
    ))

    Handlebars.registerPartial("my_order_upsell_items", Handlebars.compile(
      HandlebarsTemplates['my_order_upsell_items']({
        items: order.items,
        upsell_items: @availableUpsellItems(order)
      })
    ))

    content = Handlebars.compile(HandlebarsTemplates['my_order']({
      order: order,
    }))

    dialog = new Dialog
      title: $('.order a span').text()
      subtitle: @subtitleHTML(order.meta)
      id: 'my-order'
      content: content

    dialog.open()

    if $('body').data('route') == "merchants/show"
      $('button.add-more').prop("disabled", false)

    @bindMenuItemsClickEvents()
    @bindAddUpsell()

    $('button.checkout').on 'click', Dialog.checkout

    $('button.group-order').click ->
      Dialog.submitToGroupOrder(order.meta)

    $("a.add-more").click (event) =>
      onMerchantPage = window.location.pathname.split("/")[2] == order.meta.merchant_id
      if onMerchantPage
        Dialog.close_all()
        event.preventDefault()

  @renderUpsellSection: (order) =>
    Handlebars.registerPartial("my_order_upsell_items", Handlebars.compile(
      HandlebarsTemplates["my_order_upsell_items"]({
        items: order.items,
        upsell_items: @availableUpsellItems(order),
      })))

    $("div#my_order_upsell_items").html(Handlebars.partials["my_order_upsell_items"])
    @bindAddUpsell()

  @renderItemSection: (order) =>
    Handlebars.registerPartial("my_order_items", Handlebars.compile(
      HandlebarsTemplates["my_order_items"]({
        order: order,
      })
    ))

    $("div#my_order_items").html(Handlebars.partials["my_order_items"])
    @bindMenuItemsClickEvents()

  @bindMenuItemsClickEvents: =>
    @bindDeleteItem()
    @bindEditItem()

  @bindDeleteItem: =>
    $('.remove-item').on 'click', MenuItemsController.remove

  @bindEditItem: =>
    $('.edit-item').on 'click', MenuItemsController.edit

  @bindAddUpsell: ->
    $(".add-item").click (event) ->
      item = window.upsellItems[$(this).data "upsell-item-id"]
      if item.hasModifiers()
        MenuItemsController.show({
          item: item,
          user: window.user,
          groupOrder: $("main").data("merchant-group-order-token") != "",
          edit: false,
          comesFromUpsell: true
        })
      else
        menuItems = new MenuItems({ items: [item] })
        menuItems.addToOrder((response) -> MyOrderController.addUpsellItemCallback(response, event))

  @addUpsellItemCallback: (response, event) =>
    order = response.order
    @renderItemSection(order)
    @updateCheckoutButtons(response)
    availableUpsellItems = @availableUpsellItems(order)
    $("div#my_order_upsell_items").empty() if availableUpsellItems.length == 0
    $(event.target).parents("article").remove()

  @availableUpsellItems: (order) ->
    availableUpsellItems = _.reject(window.upsellItems, (val, key) ->
      _.find(order.items, (item) -> (item.item_id).to_n() == (val.item_id).to_n()))

    availableUpsellItems = _.map(availableUpsellItems, (val, key) -> val.toMinParams())

  @subtitleHTML: (orderMetaData) ->
    if (orderMetaData != undefined) && orderMetaData.skin_name
      if activeMerchantURL = @merchantMenuPath(orderMetaData)
        return "#{orderMetaData.skin_name}: <a href=\"#{activeMerchantURL}\">#{orderMetaData.merchant_name}</a>"

    return false

  @merchantMenuPath: (orderMetaData) ->
    if isPresent(orderMetaData) && (orderMetaData.skin_name && orderMetaData.merchant_name && orderMetaData.merchant_id)
      group_order_token = orderMetaData.group_order_token
      catering = orderMetaData.catering
      path = "/merchants/#{ orderMetaData.merchant_id }?order_type=#{ orderMetaData.order_type }"
      path = "#{ path }&group_order_token=#{ group_order_token }" if isPresent(group_order_token)
      path = "#{ path }&catering=1" if isPresent(catering)
      path
    else
      false

  @getSubtotalString: (totalCash, totalPoints) ->
    if totalCash > 0
      if totalPoints > 0
        " - " + totalPoints + " pts + $" + totalCash.toFixed(2)
      else
        " - $" + totalCash.toFixed(2)
    else if totalPoints > 0
      " - " + totalPoints + " pts"
    else
      ""

  @isWtjmmj: () =>
    if window.skin.skinName == "wtjmmj"
      return true

  @calcTotals: (items) ->
    _.reduce(items, (memo, item) ->
      if item.cash
        price = parseFloat(item.cash) || 0
        memo.cash += price
      if item.points_used   
        points = parseInt(item.points_used) || 0
        memo.points += points
      memo  
    , {cash: 0.0, points: 0})
    
  @removeItemCallback: (response, event) =>
    order = response.order

    if window.user != undefined && window.user.points != undefined
      window.user.addPoints(response.user.points_used)

    if order.items.length == 0
      $('main').data('item-count', 0)
      $('button.add-more').prop("disabled", true)
      $('button.checkout').prop("disabled", true)
      $('button.group-order').prop("disabled", true)
      $('button.group-order').text("Submit to Group Order")

    @renderUpsellSection(order)

    @updateCheckoutButtons(response)
    $(event.target).parents("article").remove()

  @updateCheckoutButtons: (response) =>
    totals = @calcTotals(response.order.items)
    cashTotal = totals.cash
    pointsTotal = totals.points

    priceString = @getSubtotalString(cashTotal, pointsTotal)

    Dialog.updateCounter(response)
    Dialog.updateCheckoutTotal(priceString)


