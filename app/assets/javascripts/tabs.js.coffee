class window.Tabs

  @initialize: ->
    $(window).on 'load hashchange', @select
    $(document).on 'click', '[data-tabs] a', @click

  @click: (event) =>
    link = $(event.currentTarget)
    tab = link.parent()
    target = $(link.attr 'href')
    tab.siblings().removeClass 'active'
    tab.addClass 'active'
    target.siblings('[data-tab-content]').removeClass 'active'
    target.addClass 'active'
    if history.pushState
      history.pushState {}, '', link.attr('href')
    return false

  @select: =>
    $("[data-tabs] a[href='#{ location.hash }']").trigger 'click'
