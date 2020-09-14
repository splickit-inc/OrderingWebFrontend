describe('Tabs', function() {

  beforeEach(function() {
    loadFixtures('tabs_view.html');
  });

  describe('#initialize', function() {

    it("registers event handlers", function() {

      var load_hashchange_spy = spyOn(window.Tabs, 'select');
      var click_spy = spyOn(window.Tabs, 'click');

      Tabs.initialize();

      $('[data-tabs] a').trigger('click');
      expect(click_spy).toHaveBeenCalled();

      window.location.hash = '#third';
      $(window).trigger('hashchange');
      expect(load_hashchange_spy).toHaveBeenCalled();
      expect(click_spy).toHaveBeenCalled();

    });

  });

});
