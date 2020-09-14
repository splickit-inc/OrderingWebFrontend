var NutritionInformation= (function(){
  function NutritionInformation(params) {
    var itemID = params.itemID;
    var sizeID = params.sizeID;
    var callback = params.callback;
    var context = params.context || this;

    return $.ajax({
      type: "GET",
      url: "/merchants/" + itemID + "/nutrition?size_id=" + sizeID,
      success: callback,
      context: context
    });
  };

  return NutritionInformation;
})();
