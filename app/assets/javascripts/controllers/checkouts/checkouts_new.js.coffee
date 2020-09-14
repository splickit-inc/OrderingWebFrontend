LEAD_TIME_INTERVAL = 120000;

class window.CheckoutsNew
  constructor: (params = {})->
    @leadTimesRefreshInterval = LEAD_TIME_INTERVAL
    #$('#discount-text').on 'click', @display_promo_form
    $('input#curbside').on 'click', @showHideCurbside
    $('select#make').on 'change', @saveOrderDetailForCheckout
    $('select#color').on 'change', @saveOrderDetailForCheckout
    $('input#dine_in').on 'click', @enableDisableCheckbox
    $('#tip select').on 'change', @update_total
    $('div#time select#day').on 'change', @update_time_values
    $('#time select').on 'change', @saveOrderDetailForCheckout
    $("#details form#create_checkout_form").on 'submit', @submit_form
    $('#summary form').on 'submit', @submit_summary_form
    $('#payment input').on 'click', @enable_or_disable_tip
    $('#note').on 'keyup', @save_note_value
    #$('#payment input:checked').trigger 'click'
    $('#gift-add-button').on 'click', @requestGiftCard
    $('#gift-replace-button').on 'click', @showGiftDialog
    $("button#create_checkout_submit").click -> $("form#create_checkout_form").submit()

    $('.edit-item').on 'click', MenuItemsController.edit
    $('.remove-item').on 'click', MenuItemsController.remove

    #$('#gift_add_button,button').on 'click', ->
    #  bindSubEvents: function (item, user, edit) {


    @verifyExtraParams = false
    day = $('#time select option[selected]').attr('value')
    time = $('#time select#time option[selected]').attr('value')
    @win = new Navigation()

    $("#time select#time").val(time) if time != undefined && time != ''

    @display_promo_form() if params.showPromoForm

    @update_total()

    loadingPage.hook()

    ErrorModalController.initialize(params.errorMessage) if params.errorMessage

    @openResetDialog() if params.cartDialog

    @bindLeadTimesPopUpInterval() if !params.cartDialog && params.refreshDialog

    @validateCookieCurbside()
    @enable_or_disable_tip()


  showGiftBalance: =>
    #verify if not exists
    if !$("input#gift-number:hidden").length && !$("#gift-number").length
      $("div#replace-gift-content").css('display', 'inline-block')

  showGiftDialog: (event) =>
    _this = this
    content_body = HandlebarsTemplates["gift_dialog"]({
      message: "error_message",
    })
    dialog = new Dialog({
      title: "Replace Gift Card"
      content: content_body
      id: "gift-replace"
      buttons: [{ text: "Continue", id: "gift-replace-confirm"}, { text: "Cancel", class: "reset", attr: "data-dialog-close"}]
    });
    dialog.open()


    $('#gift-replace-confirm').on 'click', ->
      _this.requestGiftCard(event)
      #window.CheckoutsNew.prototype.requestGiftCard(event)

  requestGiftCard: (event)=>
    if event.target.id == "gift-add-button"
      card = $('div.payment-type input#gift-number').val()
      new_card = "1"
    else if event.target.id == "gift-replace-button"
      card = $('input#gift-replace-input').val()
      new_card = "0"
    $.ajax '/user/add/',
      type: 'POST',
      dataType: "script",
      data: {'card_number': card, 'new_card': new_card}
      async: false,
      success: (data) ->
        #console.log "ok"
      error: (e) ->
        #console.log "eror"
  validateCookieCurbside: =>
    if $("input#curbside").is(":checked")
      if @win.window_size() == 'small'
        $("select.curbside_select").css('display', 'block')
      else
        $("select.curbside_select").css('display', 'inline-block')

  showHideCurbside: (event) =>
    if $("select.curbside_select").is(":hidden")
      if @win.window_size() == 'small'
        $("select.curbside_select").css('display', 'block')
      else
        $("select.curbside_select").css('display', 'inline-block')
    else
      $("select.curbside_select").hide()
    @enableDisableCheckbox(event)

  enableDisableCheckbox: (event) =>
    @verifyExtraParams = true
    if event.target.id == "dine_in"
      if $("input#curbside").is(":checked")
        $("input#curbside").prop("checked", false)
        $("select.curbside_select").hide()
    else
      if $("input#dine_in").is(":checked")
        $("input#dine_in").prop("checked", false)

    @saveOrderDetailForCheckout()

  openResetDialog: ->
    message = "Sorry, this group order has already been submitted. If you want to continue, your order will be placed individually."
    content = "<div data-dialog-content=''>#{ message }</div>"

    dialog = new Dialog({
      title: "Group Order Submitted",
      content: content,
      id: "group-order-error",
      "class": "group-order-error",
      buttons: [{ text: "Continue", attr: "data-dialog-close"}, { text: "Cancel", class: "reset" }]
    })

    dialog.open()

    $("button.reset").click(() ->
      delete_form = createRailsForm("delete", "/order")
      delete_form.submit()
    )

  bindLeadTimesPopUpInterval: =>
    window.setInterval(@showLeadTimeModal, @leadTimesRefreshInterval);

  showLeadTimeModal: () =>
    new WarningModalController({
      warning_title: "Lead Times Expired",
      warning_message: "Your pick up / delivery times are no longer valid due to inactivity. Please press here to refresh the options",
      button_callback: @leadTimesDialogCallback,
      no_close: true
    })

  leadTimesDialogCallback: (event) ->
    $(this).prop("disabled", true)
    location.reload(true)

  save_note_value: =>
    $('#char-limit').text 250 - $('#note').val().length
    @saveOrderDetailForCheckout()

  update_total: =>
    total = parseFloat $('table#total').data 'total-before-tip'
    tip = @get_tip $('select#tip').val()
    points = parseInt $('tr#points').data 'total-points' if $('tr#points').data 'total-points'
    totalresult = total + tip

    price_string = "#{ @format_price(totalresult) }"

    if points > 0
      if totalresult > 0
        price_string = "#{ @format_price(totalresult) } + #{ points } pts"
      else
        price_string = "#{ points } pts"
    $('tr#tip td:nth(1)').text @format_price(tip)
    $('table#total td:nth(1)').text price_string

    $("button#create_checkout_submit").text "Submit to Group Order"

    if !@is_group_order()
      $("button#create_checkout_submit").text "Place order ("+price_string+")"
    @saveOrderDetailForCheckout()

  update_time_values: =>
    _this = this
    day = $('select#day').val()
    timeSelect = $('div#time select#time')
    timeSelect.empty()
    $.ajax '/checkouts/get_times_by_day',
      type: 'GET',
      dataType: "JSON",
      data: { 'day': day }
      async: false,
      success: (data) ->
        $.each data, (i, object) ->
          if i==0
            timeSelect.append($("<option></option>").attr({"value": object[1], 'selected': 'selected'}).text(object[0]))
          else
            timeSelect.append($("<option></option>").attr("value", object[1]).text(object[0]))
      ,complete: (data) ->
        _this.saveOrderDetailForCheckout()


  format_price: (price) ->
    "$#{ price.toFixed 2 }"

  get_tip : (tip_selected) ->
    parseFloat(!isNaN(tip_selected) && tip_selected || 0)

  display_promo_form: ->
    #$('#discount-text').hide()
    $('#discount-form').show()
  
  enable_or_disable_tip: (event) =>
    payment_container = $('#payment input:checked').closest 'div.payment-type'
    @saveOrderDetailForCheckout()
    if $('div.payment-type.gift-card').length
      @showGiftBalance()
      if payment_container.hasClass 'gift-card'
        #if $("#gift-balance").is(":visible")
        @showGiftCardInput(true,event)
      else
        @showGiftCardInput(false,event)
    tip_select = $('#tip select')
    if payment_container.hasClass 'cash'
      tip_select.val 0
      tip_select.attr 'disabled', true
    else
      tip_select.removeAttr 'disabled'
    @update_total()

  showGiftCardInput: (show,event) =>
    if show
      if $(".gift_add").is(":hidden")
        if @win.window_size() == 'small'
          $(".gift_add").css('display', 'block')
        else
          $(".gift_add").css('display', 'inline-block')
    else if $(".gift_add").is(":visible")
      $(".gift_add").hide()

  submit_form: ->
    $("#buttons button").attr 'disabled', true
    checked = $("div#payment input:radio:checked").first()
    if checked.length > 0
      payment_type = $('<input>').attr({ type: "hidden", name: "payment_type" }).val(checked.val())
      $(this).append payment_type
    GoogleAnalyticsService.track 'orders', 'placeOrder'

  submit_summary_form: ->
    time_sel = $('#time_selected').val()
    tip_sel = $('#tip_selected').val()
    note_val = $('#note').val()

    input_time_sel = $('<input>').attr('type', 'hidden').attr('name', 'time_selected').val(time_sel)
    $(this).append $(input_time_sel)

    input_tip_sel = $('<input>').attr('type', 'hidden').attr('name', 'tip_selected').val(tip_sel)
    $(this).append $(input_tip_sel)

    input_note_val = $('<input>').attr('type', 'hidden').attr('name', 'note_value').val(note_val)
    $(this).append $(input_note_val)

  saveOrderDetailForCheckout: =>
    day_sel = $('#time select#day').find('option:selected').val()
    time_sel = $('#time select#time').find('option:selected').val()
    tip_sel = $('select#tip').children('option:selected').text()
    payment_val = $('.payment-type input[type=radio]:checked').val()
    note_val = $('#note').val()
    dine_val = false
    curbside_val = false
    make = null
    color = null

    if @verifyExtraParams
      if $("input#curbside").is(":checked")
        curbside_val = true
        make = $('select#make').val()
        color = $('select#color').val()
      else if $("input#dine_in").is(":checked")
        dine_val = true

    service = new OrderService()
    service.saveOrderDetailForCheckout(day_sel,time_sel, tip_sel, note_val, payment_val, @verifyExtraParams, dine_val,curbside_val, make, color)

  is_group_order: =>
    group_order_token = $("#order_group_order_token").val()
    group_order_token != undefined  && group_order_token.trim() != ''

  refresh_select_tips: (options_for_tip_select) =>
    text_selected = $("select#tip option:selected").text()
    options = "<select class='select' id='tip' name='tip'><option value=''>Please select a tip amount</option>"
  
    for tip in options_for_tip_select
      options += '<option value=' + tip[1] + '>' + tip[0] + '</option>'

    options += "</select>"
    $("select#tip").html(options)
    $('select#tip').find('option:contains(' + text_selected + ')').attr("selected", true)
    @update_total()