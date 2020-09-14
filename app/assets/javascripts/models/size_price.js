var SizePrice = (function () {
  'use strict';

  function SizePrice(params) {
    if (params !== undefined) {
      this.size_id = params.size_id;
      this.price = params.price;
      this.size_name = params.size_name;
      this.points = params.points;
      this.enabled = params.enabled;
    }
  }

  return SizePrice;
}());
