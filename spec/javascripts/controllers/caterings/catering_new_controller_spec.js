describe("CateringsNewController", function() {
  beforeEach(function() {
    loadFixtures('caterings/new.html');
  });

  describe("#bindCreate", function () {
    it("should bind submit event to Continue Menu input click", function () {
      var clickSpy = spyOn($.fn, "click");
      new CateringNewController({merchantID: 1080, maxDate: 4});
      expect(clickSpy).toHaveBeenCalled();

      var submitSpy = spyOn($.fn, "submit");
      new CateringNewController({merchantID: 1080, maxDate: 4});
      $("#new_catering_submit").trigger("click");
      expect(submitSpy).toHaveBeenCalled();
    });

    it("should verify form elements", function () {
      var validSpy = spyOn(CateringNewController.prototype, "isValid");
      new CateringNewController({merchantID: 1080, maxDate: 4});
      $("#new_catering_submit").trigger("click");
      expect(validSpy).toHaveBeenCalled();
    });
  });

  describe("validations", function () {
    var cateringController;

    beforeEach(function() {
      cateringController = new CateringNewController({merchantID: 1080, maxDate: 4});
    });

    describe("#isValid", function () {
      it("should return false when page does not fulfill validations", function () {
        cateringController.numberOfPeople.val("-1");

        // Waiting for long term catering orders

        // var today = new Date().getMonth() + 1 + "/" + new Date().getDate() + "/" + new Date().getFullYear();
        // cateringController.date.val(today);

        cateringController.contactPhone.val("555-555-5555");

        expect(cateringController.isValid()).toBeFalsy();

        // cateringController.numberOfPeople.val("1");
        //
        // var date = new Date().getMonth() + 1 + "/" + new Date().getDate() + "/" + new Date().getFullYear() - 1;
        // cateringController.date.val(date);
        //
        // cateringController.contactPhone.val("555-555-5555");

        expect(cateringController.isValid()).toBeFalsy();

        cateringController.numberOfPeople.val("1");

        // var today = new Date().getMonth() + 1 + "/" + new Date().getDate() + "/" + new Date().getFullYear();
        // cateringController.date.val(today);

        cateringController.contactPhone.val("555-555-55551");

        expect(cateringController.isValid()).toBeFalsy();
      });

      it("should return true when page fulfill all validations", function () {
        cateringController.numberOfPeople.val("1");

        var today = new Date().getMonth() + 1 + "/" + new Date().getDate() + "/" + new Date().getFullYear();
        cateringController.date.val(today);
        initTimeSelect(new Date('2017-07-05T12:23:00Z').getTime() / 1000, "12:23 pm");
        cateringController.contactPhone.val("555-555-5555");

        expect(cateringController.isValid()).toBeTruthy();
      });
    });

    describe("#numberPeopleValid", function () {
      it("should return false when number is not between 1 and 100", function () {
        cateringController.numberOfPeople.val("-100");
        expect(cateringController.numberPeopleValid()).toBeFalsy();
      });

      it("should return false when text is blank", function () {
        cateringController.numberOfPeople.val("");
        expect(cateringController.numberPeopleValid()).toBeFalsy();
      });

      it("should return false when text is not a number", function () {
        cateringController.numberOfPeople.val("asd1za");
        expect(cateringController.numberPeopleValid()).toBeFalsy();
      });

      it("should return true when number is between 1 and 100", function () {
        cateringController.numberOfPeople.val("1");
        expect(cateringController.numberPeopleValid()).toBeTruthy();
      });
    });

    describe("#dateValid", function () {
      it("should return false when date is before today", function () {
        cateringController.date.val("01/21/2016");
        expect(cateringController.dateValid()).toBeFalsy();
      });
      it("should return false when date is after max date (4-> 3 days)", function () {
        cateringController.date.val("07/19/3017");
        expect(cateringController.dateValid()).toBeFalsy();
      });

      it("should return false when text is blank", function () {
        expect(cateringController.dateValid()).toBeFalsy();
      });

      it("should return false when text is not a date", function () {
        cateringController.date.val("sdasd12a");
        expect(cateringController.dateValid()).toBeFalsy();
      });

      it("should return true when date is today or after today", function () {
        var today = new Date().getMonth() + 1 + "/" + new Date().getDate() + "/" + new Date().getFullYear();
        cateringController.date.val(today);
        expect(cateringController.dateValid()).toBeTruthy();
      });
    });

    function initTimeSelect(time, timeText) {
      cateringController.time.append($("<option selected ></option>")
        .attr("value", time)
        .text(timeText));
    }

    describe("#timeValid", function () {
      it("should return false when time is empty", function () {
        initTimeSelect(0, "");
        expect(cateringController.timeValid()).toBeFalsy();
      });

      it("should return false when time has an invalid format", function () {
        initTimeSelect(new Date('2017-07-05T13:22:00Z').getTime() / 1000, "13:22");
        expect(cateringController.timeValid()).toBeFalsy();
      });

      it("should return false when text is not a valid time", function () {
        initTimeSelect(5623, "56:23 pm");
        cateringController.time.text("56:23 pm");
        expect(cateringController.timeValid()).toBeFalsy();
      });

      it("should return true when time is properly formatted", function () {
        // first is selected by default, so it must be valid
        initTimeSelect(new Date('2017-07-05T12:23:00Z').getTime() / 1000, "12:23 pm");
        expect(cateringController.timeValid()).toBeTruthy();
      });
    });

    describe("#contactPhoneValid", function () {
      it("should return false when phone does not follow phone regexp", function () {
        cateringController.contactPhone.val("555-555-555");
        expect(cateringController.dateValid()).toBeFalsy();
      });

      it("should return false when text is blank", function () {
        expect(cateringController.dateValid()).toBeFalsy();
      });

      it("should return true when phone does follow phone regexp", function () {
        cateringController.contactPhone.val("555-555-5555");
        expect(cateringController.dateValid()).toBeFalsy();
      });
    });
  });
});
