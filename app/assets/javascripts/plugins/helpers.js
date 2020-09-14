/**
 * Created by diego.rodriguez on 6/22/17.
 */
// Enable/Disable for jQuery elements
$.fn.enable = function () {
  /// <summary>
  ///     Sets the disabled state.
  /// </summary>
  return this.each(function () {
    var $item = $(this);
    $item
      .removeAttr('disabled')
      .removeAttr('aria-disabled')
      .removeClass('disabled');
  });
};

$.fn.disable = function () {
  /// <summary>
  ///     Sets the disabled state.
  /// </summary>
  return this.each(function () {
    var $item = $(this);
    $item
      .attr('disabled', 'disabled')
      .attr('aria-disabled', 'true')
      .addClass('disabled');
  });
};