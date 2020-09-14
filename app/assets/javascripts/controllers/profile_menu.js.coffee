class window.ProfileMenu
  constructor: ->
    @$trigger = $('[data-profile-menu-trigger]')
    @$menu = $('[data-profile-menu]')
    @$overlay = $('[data-profile-menu-overlay]')
    unless @$overlay.length
      @$overlay = $(HandlebarsTemplates['overlay_profile']()).insertAfter @$menu
  initialize: =>
    @$trigger.on 'click', @click
    @$overlay.on 'click', @close
  click: =>
    if @$menu.is(':visible') then @close() else @open()
    return false
  open: =>
    @$menu.add(@$overlay).addClass 'open'
  close: =>
    @$menu.add(@$overlay).removeClass 'open'
