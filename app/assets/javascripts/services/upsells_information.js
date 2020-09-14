var UpsellsInformation= (function(){
  function UpsellsInformation(params) {
    var item = params.item;
    var callback = params.callback;
    var context = params.context || this;
    console.log(params);

    return $.ajax({
      item: item,
      success: callback,
      context: context
    });
  };

  return UpsellsInformation;
})();
