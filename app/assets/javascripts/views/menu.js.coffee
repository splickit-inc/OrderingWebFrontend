class window.Menu

  constructor: (nav_selector, sections_selector) ->
    @$window = $(window)
    # @$main = $('main')
    # @$nav = $('nav#menu_header')
    # @$nav_links = @$nav.find 'a'
    @$sections = $('main > section')
    # @nav_height = @$nav.outerHeight()
    # @nav_offset = @$nav.offset().top

  initialize: ->
    @$window.imagesLoaded @equalize_heights
    # @$window.on 'scroll', @stick_nav
    # @$window.on 'scroll', @highlight_nav
    @$window.on 'resize', _.debounce(@equalize_heights, 300)

  equalize_heights: =>
    max_heights = []
    for section in @$sections
      $articles = $(section).find 'article'
      $articles.css 'height': 'auto'
      heights = []
      for article in $articles
        heights.push $(article).height()
      max_height = Math.max.apply Math, heights
      max_heights.push max_height
      $articles.css 'height': max_height
    return max_heights

  section_offsets: =>
    section_offsets = []
    for section in @$sections
      $section = $(section)
      top = $section.offset().top
      bottom = top + $section.outerHeight()
      section_offsets.push {
        id: $section.attr('id'),
        top: top,
        bottom: bottom
      }
    return section_offsets

  highlight_nav: =>
    # scroll_position = @$window.scrollTop()
    # highlight_position = scroll_position + @$window.height() / 4
    # for section in @section_offsets()
    #   if highlight_position >= section.top and highlight_position < section.bottom
    #     @$nav_links.removeClass 'active'
    #     active_link = @$nav_links.filter("[href='##{ section.id }']").addClass 'active'
    # return active_link
