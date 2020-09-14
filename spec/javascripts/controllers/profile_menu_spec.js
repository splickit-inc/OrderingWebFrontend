describe('ProfileMenu', function() {

  beforeEach(function() {
    loadFixtures('profile_menu_view.html');
  });

  describe('#constructor', function() {

    it("sets variables", function() {
      var profileMenu = new ProfileMenu;
      profileMenu.initialize();
      var $trigger = $('[data-profile-menu-trigger]');
      var $menu = $('[data-profile-menu]');
      expect(profileMenu.$trigger).toEqual($trigger);
      expect(profileMenu.$menu).toEqual($menu);
    });

    it("appends the overlay to the body", function() {
      var profileMenu = new ProfileMenu;
      profileMenu.initialize();
      var $overlay = $('[data-profile-menu-overlay]');
      expect($overlay.length).toEqual(1);
    });

  });

  describe('#initialize', function() {

    it("sets up the menu open click event", function() {
      var jQueryOnSpy = spyOn($.fn, 'on');
      var profileMenu = new ProfileMenu;
      profileMenu.initialize();
      expect(jQueryOnSpy).toHaveBeenCalledWith('click', profileMenu.click);
    });

    it("sets up the close click event", function() {
      var jQueryOnSpy = spyOn($.fn, 'on');
      var profileMenu = new ProfileMenu;
      profileMenu.initialize();
      expect(jQueryOnSpy).toHaveBeenCalledWith('click', profileMenu.close);
    });

  });

  describe('#click', function() {

    it("opens the menu if it's not visible", function() {
      var profileMenu = new ProfileMenu;
      var openSpy = spyOn(profileMenu, 'open');
      profileMenu.initialize();
      var $trigger = $('[data-profile-menu-trigger]');
      $trigger.trigger('click');
      expect(openSpy).toHaveBeenCalled();
    });

    it("closes the menu if it's visible", function() {
      var profileMenu = new ProfileMenu;
      var closeSpy = spyOn(profileMenu, 'close');
      profileMenu.initialize();
      var $trigger = $('[data-profile-menu-trigger]');
      $trigger.trigger('click');
      $trigger.trigger('click');
      expect(closeSpy).toHaveBeenCalled();
    });

  });

  describe('#open', function() {

    it("adds the 'open' class to the menu and overlay", function() {
      var profileMenu = new ProfileMenu;
      profileMenu.initialize();
      var $trigger = $('[data-profile-menu-trigger]');
      var $menu = $('[data-profile-menu]');
      var $overlay = $('[data-profile-menu-overlay]');
      $trigger.trigger('click');
      expect($menu).toHaveClass('open');
      expect($overlay).toHaveClass('open');
    });

  });

  describe('#close', function() {

    it("removes the 'open' class from the menu and overlay", function() {
      var profileMenu = new ProfileMenu;
      profileMenu.initialize();
      var $trigger = $('[data-profile-menu-trigger]');
      var $menu = $('[data-profile-menu]');
      var $overlay = $('[data-profile-menu-overlay]');
      $trigger.trigger('click');
      $overlay.trigger('click');
      expect($menu).not.toHaveClass('open');
      expect($overlay).not.toHaveClass('open');
    });

  });

});
