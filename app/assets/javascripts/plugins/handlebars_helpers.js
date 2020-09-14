Handlebars.registerHelper('json', function (object) {
  JSON.stringify(object);
});

Handlebars.registerHelper('equal', function (lvalue, rvalue, options) {
  if (arguments.length < 3)
    throw new Error("Handlebars helper equal needs 2 parameters");
  if (lvalue != rvalue) {
    return options.inverse(this);
  } else {
    return options.fn(this);
  }
});

Handlebars.registerHelper('greaterThan', function (lvalue, rvalue, options) {
  if (arguments.length < 3) {
    throw new Error("Handlebars helper equal needs 2 parameters");
  }
  if (lvalue > rvalue) {
    return options.fn(this);
  } else {
    return null;
  }
});

Handlebars.registerHelper('isPreferred', function(addrId, options) {
  var addressService = new AddressService();

  if ((1.0 * addrId) == (1.0 * addressService.getPreferredAddress())) {
    return options.fn(this);
  } else {
    return options.inverse(this);
  }
});

Handlebars.registerHelper("blank?", function (object) {
  return isBlank(object);
});

Handlebars.registerHelper("present?", function (object) {
  return !isBlank(object);
});

Handlebars.registerHelper("splitjoin", function (object) {
  return object.split(",").join(" ");
});

Handlebars.registerHelper("And", function (a, b) {
  return a && b;
});

Handlebars.registerHelper("Or", function (a, b) {
  return a || b;
});

Handlebars.registerHelper("Not", function (a) {
  return !a;
});

Handlebars.registerHelper("greaterThanZero", function (object) {
  return parseInt(object) > 0;
});

Handlebars.registerHelper("includes", function(list, elem) {
  return list.indexOf(elem) > -1;
});