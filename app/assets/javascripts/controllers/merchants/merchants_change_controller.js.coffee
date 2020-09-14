class window.MerchantsChangeController
  openDialog: (params) ->
    @event = params.event
    @redirectCallback = params.redirectCallback
    @currentMerchantID = params.currentMerchantID
    @orderType = params.orderType
    @differentMerchants = params.differentMerchants

    content_source = content_source = HandlebarsTemplates['merchant_change']({
      oldMerchantName: $('main').data('active-merchant-name')
      newMerchantName: $(@event.target).data("merchant-name")
      self: this
    })

    content = Handlebars.compile(content_source)

    dialog = new Dialog
      title: @title()
      content: content
      id: 'change-store'

    dialog.open()

    $('.button.continue').on('click', (e) =>
      e.preventDefault()
      @redirectCallback(@orderType, @currentMerchantID)
    )

  title: () ->
    return "Change store?" if @differentMerchants
    "Change order?"

