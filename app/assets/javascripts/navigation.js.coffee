class window.Navigation
  FIXED_IMAGE_BRANDS = ["goodcentssubs", "bibibop"]

  constructor: ->
    @$window = $(window)
    @$body = $ 'body'
    @$header = @$body.find '> header'
    @$primary_nav = @$header.find 'nav.primary'
    @$secondary_nav = @$header.find 'nav.secondary'
    @$logo = @$header.find 'a.logo img'
    @$logo_container = @$header.find 'a.logo'
    @$address = @$header.find 'address'
    @$store_hours_container = @$address.find 'div#store_hours_container'
    @$icon_to_show_store_hours = @$address.find 'div#icon_to_show_store_hours'
    @$is_clicked_to_show = true
    @$order_div = @$header.find 'div.order'
    @$user_div = @$header.find 'div.user'
    @$dropdown_link = @$header.find 'a.dropdown-toggle'
    @$dropdown_user = @$header.find 'a.dropdown-user'
    @$order_dialog_triggers = @$header.find '.order'
    @$main = @$body.find 'main'
    @$loyalty_card =  @$main.find '.loyalty-card'
    @header_original_height = @$header.outerHeight()
    @primary_nav_original_height = @$primary_nav.outerHeight()
    @secondary_nav_original_height = @$secondary_nav.outerHeight()
    @store_hours_container_height = @$store_hours_container.outerHeight()
    @loyalty_card_height = @$loyalty_card.outerHeight()
    @skin_name = @$body.data 'skin-name'
    @initialize()
    @adapt_to_window_size()
    @bind_events()

  initialize: =>
    @$secondary_nav.css 'height', @$secondary_nav.find('a:first').outerHeight()
    if @window_size() == 'small'
      @$header.css 'min-height', @primary_nav_original_height + @loyalty_card_height
    else
      @$header.css 'min-height', @header_original_height

  @calculate_logo: =>
    logo = $("body a.logo img")
    logo_width = logo.prop('naturalWidth')
    logo_height = logo.prop('naturalHeight')
    proportion = logo_width / logo_height

    if !@skin_name?
      @skin_name = $("body").attr 'data-skin-name'

    ###if logo_height > 81 && FIXED_IMAGE_BRANDS.indexOf(@skin_name) == -1
      logo_width = "#{ 81 * proportion }px"
      logo.css 'min-width', "#{ 58 * proportion }px"

      logo_height = '78px'
      logo.css 'min-height', '58px'
      logo.css 'vertical-align', 'middle'
      logo.css 'padding', '0.1rem'

    else if FIXED_IMAGE_BRANDS.indexOf(@skin_name) > -1
      logo_width = 'auto'
      logo_height = 'auto'
    logo.css 'max-width', logo_width
    logo.css 'max-height', logo_height###

  bind_events: ->
    @$window.on 'resize', _.debounce(@adapt_to_window_size, 300)
    @$window.on 'scroll', @collapse_header
    @$window.on 'load', @get_original_logo_height
    @$user_div.on 'click', @toggle_user_menu_or_follow_link
    @$dropdown_link.on 'click', @toggle_dropdow_menu
    @$dropdown_user.on 'click', @toggle_dropdow_user_menu
    @$order_dialog_triggers.on 'click', @show_order_dialog
    @$secondary_nav.on 'click', @toggle_secondary_nav_menu_or_scroll_to_item
    @$icon_to_show_store_hours.on 'click', @show_store_hours

  get_original_logo_height: =>
    @logo_original_height = @$logo.outerHeight()

  window_size: =>
    if @$header.css('border-collapse') == 'separate'
      return 'small'
    if @$header.css('border-collapse') == 'collapse'
      return 'large'

  header_height: =>
    actual_height = @$header.outerHeight()
    top_margin = parseInt @$header.css 'margin-top'
    return actual_height + top_margin

  secondary_nav_stacked: =>
    @$secondary_nav.hasClass('stacked') or @window_size() == 'small'

  adapt_to_window_size: =>
    if @window_size() == 'large'
      @create_user_menu()
      @create_user_menu2()
      @$user_div.css 'height', ''
      @stack_or_unstack_secondary_nav()
    else
      @destroy_user_menu()
      @destroy_user_links()
      @stack_or_unstack_secondary_nav()
      if @$loyalty_card.height() != null
        @$loyalty_card.css 'margin-top', @$logo.height()/2 + 'px'
        @$header.css 'min-height', @primary_nav_original_height + @loyalty_card_height + @$logo.height()/3 + 'px'
      else
        @$header.css 'min-height', @primary_nav_original_height

  create_user_menu: ->
    return if @$body.find('> div.user').length
    if window.signed_in
      user_div_clone = @$user_div.clone()
      user_div_clone.find(".close-menu").remove()
      user_div_clone.appendTo @$body

  create_user_menu2: ->
    return if @$body.find('> div.user').length
    if window.signed_in == false
      user_div_clone = @$user_div.clone()
      user_div_clone.find(".close-menu").remove()
      user_div_clone.appendTo @$body

  destroy_user_menu: ->
    @$body.find('> div.user').remove()

  destroy_user_links: ->
    @$header.find('nav.primary > a:not(.logo):not(.dropdown-toggle):not(.dropdown-user):not(.group-order-status.first)').remove()

  stack_or_unstack_secondary_nav: ->
    first_child = @$secondary_nav.children ':first'
    @$secondary_nav.removeClass 'stacked'
    @$secondary_nav.css 'transition', ''
    @$secondary_nav.css 'height', ''
    if @window_size() == 'small' or (@$secondary_nav.outerHeight() > first_child.outerHeight() and @secondary_nav_stacked() == false)
      @$secondary_nav.addClass 'stacked'
      @$secondary_nav.css 'height', first_child.outerHeight()
    else if @secondary_nav_stacked() == true
      @$secondary_nav.removeClass 'stacked'
      @$secondary_nav.css 'height', ''
    setTimeout =>
      @$secondary_nav.css 'transition', 'height .3s ease'
    , 0

  toggle_user_menu_or_follow_link: (event) =>
    if @window_size() == 'small'

      return if ['A', 'H3', 'P'].indexOf(event.target.tagName) >= 0 && !$(event.target).hasClass('close-menu')

      user_div_height = 0
      @$user_div.children().each ->
        user_div_height += $(this).outerHeight()

      if @$header.hasClass 'open'
        @$primary_nav.removeClass 'scrolling'
        @$user_div.css 'max-height', 0
        @$loyalty_card.css 'opacity', 1
      else
        @$user_div.css 'max-height', user_div_height
        max_height = $(window).height()
        if user_div_height + @primary_nav_original_height > max_height
          @$primary_nav.addClass 'scrolling'
          @$loyalty_card.css 'opacity', 0

      @$header.toggleClass 'open'

    else
      return unless $(event.target).hasClass 'user'

      user_div_copy = @$body.find '> div.user'
      user_div_copy.toggleClass 'open'
      overlay = $("<div class='overlay'></div>")
      overlay.on 'click', =>
        overlay.remove()
        user_div_copy.toggleClass 'open'
      overlay.insertBefore user_div_copy
      return false

  toggle_dropdow_menu: (event) =>
    if @window_size() == 'small'
      return if ['A', 'H3', 'P'].indexOf(event.target.tagName) >= 0 && !$(event.target).hasClass('close-menu')

      user_div_height = 0
      @$user_div.children().each ->
        user_div_height += $(this).outerHeight()

      if @$header.hasClass 'open'
        @$primary_nav.removeClass 'scrolling'
        @$user_div.css 'max-height', 0
        @$loyalty_card.css 'opacity', 1
      else
        @$user_div.css 'max-height', user_div_height
        max_height = $(window).height()
        if user_div_height + @primary_nav_original_height > max_height
          @$primary_nav.addClass 'scrolling'
          @$loyalty_card.css 'opacity', 0

      @$header.toggleClass 'open'

    else
      return unless $(event.target).hasClass 'dropdown-toggle'
      user_div_copy = @$body.find '> div.user'
      user_div_copy.toggleClass 'open'
      overlay = $("<div class='overlay'></div>")
      overlay.on 'click', =>
        overlay.remove()
        user_div_copy.toggleClass 'open'
      overlay.insertBefore user_div_copy
      return false

  toggle_dropdow_user_menu: (event) =>
    if @window_size() == 'small'
      return if ['A', 'H3', 'P'].indexOf(event.target.tagName) >= 0 && !$(event.target).hasClass('close-menu')

      user_div_height = 0
      @$user_div.children().each ->
        user_div_height += $(this).outerHeight()

      if @$header.hasClass 'open'
        @$primary_nav.removeClass 'scrolling'
        @$user_div.css 'max-height', 0
        @$loyalty_card.css 'opacity', 1
      else
        @$user_div.css 'max-height', user_div_height
        max_height = $(window).height()
        if user_div_height + @primary_nav_original_height > max_height
          @$primary_nav.addClass 'scrolling'
          @$loyalty_card.css 'opacity', 0

      @$header.toggleClass 'open'

    else
      return unless $(event.target).hasClass 'dropdown-user'
      user_div_copy = @$body.find '> div.user'
      user_div_copy.toggleClass 'open'
      overlay = $("<div class='overlay'></div>")
      overlay.on 'click', =>
        overlay.remove()
        user_div_copy.toggleClass 'open'
      overlay.insertBefore user_div_copy
      return false

  toggle_secondary_nav_menu_or_scroll_to_item: (event) =>
    link = $(event.target)
    target = $(link.attr 'href')

    event.preventDefault()

    if @window_size() == 'small' or @$secondary_nav.hasClass 'stacked'

      if event.target.tagName == 'NAV'
        @toggle_secondary_nav()
        return

      @$secondary_nav.find('a').removeClass 'current'

      if @$secondary_nav.hasClass 'open'
        setTimeout =>
          $(event.target).addClass 'current'
        , 300
        $('html, body').animate
          scrollTop: target.offset().top - @$primary_nav.outerHeight() - link.outerHeight() + 3
        , 600

      @toggle_secondary_nav()

    else
      @$secondary_nav.find('a').removeClass 'current'
      $(event.target).addClass 'current'
      $('html, body').animate
        scrollTop: target.offset().top - @$primary_nav.outerHeight() - link.outerHeight() + 3
      , 600

  toggle_secondary_nav: =>
    if @$secondary_nav.hasClass 'open'
      @close_secondary_nav()
    else
      @open_secondary_nav()

  open_secondary_nav: =>
    height = 0
    @$secondary_nav.children().each ->
      height += $(this).outerHeight()
    max_height = $(window).height() - @header_height()
    if height < max_height
      @$secondary_nav.css 'height', height
    else
      @$secondary_nav.css 'height', max_height
      setTimeout =>
        @$secondary_nav.addClass 'scrolling'
      , 300
    @$secondary_nav.addClass 'open'

  close_secondary_nav: =>
    @$secondary_nav.css 'height', @$secondary_nav.find('a:first').outerHeight()
    @$secondary_nav.removeClass 'scrolling'
    @$secondary_nav.scrollTop 0
    @$secondary_nav.removeClass 'open'

  my_order_callback: (response) ->
    isMerchantShowPage = $("body").data("route") == "merchants/show"
    if response.order && response.order.items && response.order.items.length > 0 && !isMerchantShowPage
      Dialog.redirect("#{ MyOrderController.merchantMenuPath(response.order.meta) }&my_order=1")
    else
      MyOrderController.openMyOrder(response)

  show_order_dialog: =>
    window.orderService.show(@my_order_callback)
    return false

  collapse_header: =>
    @$icon_to_show_store_hours.removeClass 'address-back-arrow-icon'
    @$icon_to_show_store_hours.addClass 'address-forward-arrow-icon'
    @$store_hours_container.css 'display', 'none'
    @$is_clicked_to_show = true

    return unless window.route == 'merchants/show'
    scroll_position = @$window.scrollTop()

    return if scroll_position < 0
    return if @window_size() == 'large'
    @$header.css 'min-height', @header_original_height + 'px'
    if @window_size() == 'large'
      maximum_offset = @header_original_height - @primary_nav_original_height
    else
      maximum_offset = @header_original_height

    if $('#nav-header-bg').height() > 0
      maximum_offset -= 18

    header_margin = Math.max -maximum_offset, -scroll_position
    reduction_ratio = scroll_position / maximum_offset
    logo_margin = @$logo_container.css('margin-top').replace 'px', ''
    min_height = @primary_nav_original_height - 2*logo_margin
    logo_height_difference = (reduction_ratio * @logo_original_height) - min_height

    @$header.css
      'margin-top': header_margin + 'px'
      'background-position': 'center ' + Math.abs(header_margin) + 'px'
    if @window_size() == 'small'
      @$address.css 'opacity', (maximum_offset - scroll_position * 2) / 1.35 / 100

    return unless @window_size() == 'large'

    if FIXED_IMAGE_BRANDS.indexOf(@skin_name) == -1
      if scroll_position <= maximum_offset
        @$logo.css 'height', @logo_original_height - logo_height_difference + 'px'
      else
        @$logo.css 'height', @primary_nav_original_height - (logo_margin * 2) + 'px'

  show_store_hours: =>
    if @$is_clicked_to_show
      @$icon_to_show_store_hours.removeClass 'address-forward-arrow-icon'
      @$icon_to_show_store_hours.addClass 'address-back-arrow-icon '
      @$store_hours_container.css
        'display': 'block'
      @$header.css 'min-height', (@header_original_height + @store_hours_container_height) + 'px'
      @$is_clicked_to_show = false
    else
      @$icon_to_show_store_hours.removeClass 'address-back-arrow-icon '
      @$icon_to_show_store_hours.addClass 'address-forward-arrow-icon '
      @$store_hours_container.css
        'display': 'none'
      @$header.css 'min-height', @header_original_height + 'px'
      @$is_clicked_to_show = true
