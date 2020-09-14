var loadingPage = {
  show: function(params) {
    if (params && params.callback) {
      $("div#loading-page").show();
      var is_safari = navigator.userAgent.toLowerCase().indexOf("safari") > -1;
      var is_chrome = navigator.userAgent.toLowerCase().indexOf("chrome") > -1;
      if(is_safari && !is_chrome) {
        var show = function () { params.callback() };
        setTimeout(show, 1000);
      } else {
        params.callback();
      }
    } else {
      $("div#loading-page").show();
    }
  },

  hide: function() {
    $("div#loading-page").hide();
  },

  //It will attach event to all elements with loading class
  hook: function(){
    $(".loading").click(function() {
      loadingPage.show();
    });
  }
}