/**
 * Created by diego.rodriguez on 8/2/17.
 */
function SessionController() {
};

SessionController.prototype.validateSession = function () {
  var performance = window.performance || window.webkitPerformance || window.msPerformance || window.mozPerformance;
  if (!(!!performance && performance.navigation.type === 2 &&
    $('.sign-in').length !== 0)) {
    return;
  }
  //console.log("Verifying session status...");
  $.ajax({
    url: '/session_status?_=' + new Date().getTime(),
    type: "GET",
    success: function (session_status) {
      if (session_status.signed_in) {
        //console.log('Reloading');
        window.location.reload();
      }
    }
  });
};