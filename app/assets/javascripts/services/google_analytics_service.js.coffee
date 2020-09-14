class window.GoogleAnalyticsService
   
  @track: (category, action, label, value) ->
    ga('send', 'event', category, action, label, value)