MAX_NUMBER_PEOPLE = 9999;
MIN_NUMBER_PEOPLE = 1;
NO_AVAILABLE_TIMES = -1;
function CateringNewController(params) {
  this.merchantID = params.merchantID;
  this.createForm = $("#new_catering");
  this.submitButton = $("#new_catering_submit");
  this.numberOfPeople = this.createForm.find("#catering_number_of_people");
  this.date = this.createForm.find("#catering_date");
  this.time = this.createForm.find("#catering_timestamp_of_event");
  this.contactPhone = this.createForm.find("#catering_contact_phone");
  this.note = this.createForm.find("#catering_notes");
  this.lblNoAvailableTime = $(".no_time_label");
  this.errorMessage = [];

  this.maxDays = (params.maxDate - 1); // calendar requires -1 day
  this.maxDate = new Date();
  this.maxDate.setTime(this.maxDate.getTime() + (this.maxDays * 86400000));

  this.initializeDateControls();

  this.initializeSpinner();
  this.bindCreate();
  this.bindDeliveryEvents();
}

CateringNewController.prototype.initializeDateControls = function () {
  var userAgent = window.navigator.userAgent.toLowerCase(),
    iOS = /iphone|ipod|ipad/.test(userAgent),
    android = /android/i.test(userAgent);

  var nativeControlBrowsers = iOS || android;

  if (nativeControlBrowsers) {
    this.initializeNativeDateControls();
  } else {
    this.initializeDatePicker();
  }
};

CateringNewController.prototype.initializeNativeDateControls = function () {
  var self = this;

  var today = new Date(),
    numMonth = today.getMonth() + 1,
    month = (numMonth < 10) ? "0" + numMonth : numMonth,
    todayFormatted = today.getFullYear() + "-" + month + "-" + today.getDate();
  var max = new Date();
  max.setTime(this.maxDate.getTime() + 86400000);
  numMonth = max.getMonth() + 1;
  month = (numMonth < 10) ? "0" + numMonth : numMonth;
  var maxDateFormatted = max.getFullYear() + "-" + month + "-" + max.getDate();
  this.date.attr({
    type: "date",
    min: todayFormatted,
    max: maxDateFormatted,
    value: todayFormatted
  });

  this.date.change(function () {
    self.time.load();
    var d = new Date($(this).val());
    self.times(self.merchantID, d.valueOf() / 1000, self.selectCompleteCallback);
  });
};

CateringNewController.prototype.initializeDatePicker = function () {
  var self = this;

  $("#catering_date, #calendar").datepicker({
    minDate: 0,
    maxDate: this.maxDays,
    buttonText: "<span class='calendar-icon'></span>",
    showOn: "both",
    onSelect: function (dateText, inst) {
      self.time.load();
      var d = new Date(dateText);
      var utc = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate());
      self.times(self.merchantID, utc / 1000, self.selectCompleteCallback);
    }
  });
  $('#catering_date').datepicker("setDate", new Date()).attr('readonly', true);
};

CateringNewController.prototype.initializeSpinner = function () {
  this.numberOfPeople.spinner({
    min: MIN_NUMBER_PEOPLE,
    max: MAX_NUMBER_PEOPLE,
  });

  this.numberOfPeople.spinner("value", MIN_NUMBER_PEOPLE);
};

CateringNewController.prototype.isValid = function () {
  return this.numberPeopleValid() && this.dateValid() && this.timeValid() && this.contactPhoneValid();
};

CateringNewController.prototype.numberPeopleValid = function () {
  var numberOfPeople = Number(this.numberOfPeople.val());

  if (numberOfPeople >= MIN_NUMBER_PEOPLE && numberOfPeople <= MAX_NUMBER_PEOPLE) {
    return true;
  } else {
    this.errorMessage.push("Number of People should be between "+MIN_NUMBER_PEOPLE+" and "+MAX_NUMBER_PEOPLE);
    return false;
  }
};

CateringNewController.prototype.dateValid = function () {
  var todayWithTime = new Date();
  var today = new Date(todayWithTime.getUTCFullYear(), todayWithTime.getUTCMonth(), todayWithTime.getUTCDate());
  var dateWithTime = new Date(this.date.val());
  var date = new Date(dateWithTime.getUTCFullYear(), dateWithTime.getUTCMonth(), dateWithTime.getUTCDate());
  var max = new Date(this.maxDate.getUTCFullYear(), this.maxDate.getUTCMonth(), this.maxDate.getUTCDate());
  if (date >= today) {
    if (date <= max) {
      return true;
    }
    var month = max.getMonth() + 1;
    month = (month < 10) ? "0" + month : month;
    this.errorMessage.push("Date should not be after: " + month + "/" + max.getDate() + "/" + max.getFullYear());
    return false;
  }
  this.errorMessage.push("Date should be after today's date");
  return false;
};

CateringNewController.prototype.timeValid = function () {
  var time = this.time.val();
  var timeText = this.time.find('option:selected').text();
  if (time == NO_AVAILABLE_TIMES) {
    this.errorMessage.push('There are no available times on the selected date, please pick' +
      ' a different one!');
    return false;
  }
  if (!!time && !!time.trim() &&
    !!timeText && !!timeText.trim()) { //not empty
    var timeFormat = /^(0?[1-9]|1[012])(:[0-5]\d) [APap][mM]$/;
    if (timeFormat.test(timeText)) {
      return true;
    }
    this.errorMessage.push('Time "' + timeText + '" is not valid');
    return false;
  }
  this.errorMessage.push("Time can't be empty");
  return false;
};

CateringNewController.prototype.contactPhoneValid = function () {
  var contactPhoneTrimmed = this.contactPhone.val().trim();
  var intLength = contactPhoneTrimmed.replace(/\D/g, "").length;
  var onlyAllowedChar = contactPhoneTrimmed.replace(/(\d|-|\(|\)|\.)/g, "").length == 0;

  if (onlyAllowedChar && intLength == 10) {
    return true;
  } else {
    this.errorMessage.push("Phone should have 10 digits");
    return false;
  }
};

CateringNewController.prototype.bindCreate = function () {
  var self = this;

  this.submitButton.click(function () {
    self.createForm.submit();
  });

  this.createForm.submit(function () {
    if (self.isValid()) {
      return true;
    } else {
      new WarningModalController({
        warning_title: "Catering Error",
        warning_message: self.errorMessage[0]
      });
      self.errorMessage = [];
      return false;
    }
  });
};

CateringNewController.prototype.bindDeliveryEvents = function () {
  var self = this;

  $('#change_delivery_address').on('click', function (e) {
    e.preventDefault();
    var merchantId = $(this).data('merchant-id');
    self.deliveryAddress(merchantId, 'delivery');
  });
};

CateringNewController.prototype.deliveryAddress = function (merchantID, orderType) {
  var delivery_path = "/caterings/update_delivery_address?merchant_id=" + merchantID + "&order_type=" + orderType;
  DeliveryModalController.initialize({
    path: delivery_path,
    subscriptor: 'update_address',
    ajax_type: 'GET'
  });
};

CateringNewController.prototype.selectCompleteCallback = function (select) {
  select.finishLoad();
};

CateringNewController.prototype.times = function (merchant_id, date, completeCallback) {
  $.ajax({
    url: "/caterings/times",
    type: "GET",
    context: this,
    data: {
      merchant_id: merchant_id,
      date: date
    },
    success: function (response) {
      this.updateTimeSelect(response.merchant.catering_times);
    },
    error: function (response) {
      new WarningModalController({
        warning_title: "Catering Error",
        warning_message: "Sorry we don't have times available for this merchant."
      });
    },
    complete: function () {
      completeCallback(this.time);
    }
  });
};

CateringNewController.prototype.updateTimeSelect = function (times) {
  this.time.empty();
  this.time.enable();
  if (times.length === 0) {
    this.time.append($("<option>").text("No time available for this date").val(NO_AVAILABLE_TIMES));
    this.time.disable();
    this.time.addClass("hidden");
    this.lblNoAvailableTime.removeClass("hidden");
    return;
  }
  _.each(times, function (time) {
    this.time.append($("<option>").text(time.time).val(time.ts));
  }, this);
  this.time.removeClass("hidden");
  this.lblNoAvailableTime.addClass("hidden");
};

CateringNewController.prototype.updateDeliveryAddress = function (data) {
  if (isPresent(data.delivery_address_info)) {
    $('#flash_notifications').html('');
    var business_name = data.delivery_address_info.business_name;
    var address1 = data.delivery_address_info.address1;
    var address2 = data.delivery_address_info.address2;
    var city = data.delivery_address_info.city;
    var state = data.delivery_address_info.state;
    var phone_no = data.delivery_address_info.phone_no;
    var zip = data.delivery_address_info.zip;
    var address_element = "<p>" + business_name + "</p><p>" + address1 + ', ' + address2 + '</p><p>' + city + ', ' + state + '  ' + zip + '</p><p>' + phone_no + '</p>';
    $('.custom-address').html(address_element);
  }

  if (isPresent(data.error)) {
    var html_error = "<p id='error' class='message'><span class='message-body'>" + data.error + "</span><span class='close'>x</span></p>";
    $('#flash_notifications').html(html_error);
  }
};