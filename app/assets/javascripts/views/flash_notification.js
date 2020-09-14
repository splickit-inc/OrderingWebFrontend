function FlashNotification(el) {
  this.bindFlash(el);
};

FlashNotification.prototype.bindFlash = function(el) {
  el.find(".close").click(function() {
    el.hide();
  });
};

