function createRailsForm (method, url) {
  var form = $("<form action='"+ url + "'>");

  if (isUnsupportedHttpMethod) {
    form.attr("method", "post");
    form.append($("<input name='_method' value='" + method +"' type='hidden'>"));
  } else {
    form.attr("method", method);
  }
  $("body").append(form);
  return form;
};

function isUnsupportedHttpMethod (method) {
  return method.toLowerCase() != "post" || method.toLowerCase() != "get"
};