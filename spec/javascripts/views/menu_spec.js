describe("Menu", function() {

  beforeEach(function() {
    loadFixtures('menu_view.html');
  });

  describe("#initialize", function() {

    it("binds the correct events", function() {
      var menu = new Menu;
      var imagesloaded_spy = spyOn($.fn, 'imagesLoaded');
      var highlight_nav_spy = spyOn(menu, 'highlight_nav');
      var dummy_spy = jasmine.createSpy('dummy_spy');
      var debounce_spy = spyOn(_, 'debounce').and.returnValue(dummy_spy);
      menu.initialize();
      $(window).trigger('scroll');
      $(window).trigger('resize');
      expect(imagesloaded_spy).toHaveBeenCalledWith(menu.equalize_heights);
      expect(debounce_spy).toHaveBeenCalledWith(menu.equalize_heights, 300);
      expect(dummy_spy).toHaveBeenCalled();
    });

  });

  describe("#equalize_heights", function() {

    it("sets the heights of each element to be the same", function() {
      var menu = new Menu;
      menu.initialize();
      menu.equalize_heights();
      first_height = $('#first').outerHeight();
      second_height = $('#second').outerHeight();
      third_height = $('#third').outerHeight();
      expect(first_height).toEqual(second_height);
      expect(first_height).toEqual(third_height);
    });

    it("calls equalize_heights on resize", function() {
      var menu = new Menu;
      var equalize_heights_spy = spyOn(menu, 'equalize_heights');
      var debounce_spy = spyOn(_, 'debounce').and.returnValue(menu.equalize_heights);
      menu.initialize();
      $(window).trigger('resize');
      expect(equalize_heights_spy).toHaveBeenCalled();
    });

  });

  describe("#section_offsets", function() {

    it("returns the section offsets in json form", function() {
      var menu = new Menu;
      var alpha_offset = {
        top: $('#alpha').offset().top,
        bottom: $('#alpha').offset().top + $('#alpha').outerHeight()
      }
      var bravo_offset = {
        top: $('#bravo').offset().top,
        bottom: $('#bravo').offset().top + $('#bravo').outerHeight()
      }
      section_offsets = menu.section_offsets();
      expect(section_offsets).toEqual([
        {
          id: 'alpha', top : alpha_offset.top,
          bottom: alpha_offset.bottom
        },
        {
          id: 'bravo', top : bravo_offset.top,
          bottom: bravo_offset.bottom
        }
      ]);
    });

  });

  describe("#highlight_nav", function() {

    // it("sets the active class the correct nav item when the section enters the top quarter of the window", function() {
    //   var menu = new Menu;
    //   var section_offsets = menu.section_offsets();
    //   var highlight_offset = $(window).height() / 4;
    //   var alpha_threshold = section_offsets[0].top - highlight_offset + 1;
    //   var bravo_threshold = section_offsets[1].top - highlight_offset + 1;
    //   var scrolltop_spy = spyOn($.fn, 'scrollTop');
    //   scrolltop_spy.and.returnValue(alpha_threshold);
    //   menu.highlight_nav();
    //   expect($('nav a:first').hasClass('active')).toEqual(true);
    //   scrolltop_spy.and.returnValue(bravo_threshold);
    //   menu.highlight_nav();
    //   expect($('nav a:last').hasClass('active')).toEqual(true);
    // });
    //
    // it("removes the active class from the correct nav item when the section leaves the top quarter of the window", function() {
    //   var menu = new Menu;
    //   var section_offsets = menu.section_offsets();
    //   var highlight_offset = $(window).height() / 4;
    //   var alpha_threshold = section_offsets[0].top - highlight_offset + 1;
    //   var bravo_threshold = section_offsets[1].top - highlight_offset + 1;
    //   var scrolltop_spy = spyOn($.fn, 'scrollTop');
    //   scrolltop_spy.and.returnValue(alpha_threshold);
    //   menu.highlight_nav();
    //   expect($('nav a:last').hasClass('active')).toEqual(false);
    //   scrolltop_spy.and.returnValue(bravo_threshold);
    //   menu.highlight_nav();
    //   expect($('nav a:first').hasClass('active')).toEqual(false);
    // });

  });

});
