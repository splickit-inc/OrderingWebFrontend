class window.MerchantsIsGuestController
  openDialog: (params) ->
    @continueLink = params.continueLink
    @currentMerchantID = params.currentMerchantID
    @orderType = params.orderType
    @orderMode = params.orderMode

    if(params.title)
      @title = params.title
    else
      @title = "Do you have an account?"

    if(params.bodyContent)
      @body_content = params.bodyContent
    else
      @body_content = "Sorry, you must be logged in to place a #{@orderType} order."

    content_source = HandlebarsTemplates['sessions/sign-in-modal-helper']({
      window
      continueLink: @continueLink
      currentMerchantID: @currentMerchantID
      orderType: @orderType
      orderMode: @orderMode
      bodyContent: @body_content
    })

    content = Handlebars.compile(content_source)

    dialog = new Dialog
      title: @title
      content: content
      id: 'sign-in'

    dialog.open()