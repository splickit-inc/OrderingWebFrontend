describe("Order", function() {
  describe("#constructor", function() {
    it("should initialize with the correct values", function() {
      var order = new Order(get_order());
      expect(order.order_id).toEqual("6923234");
      expect(order.tip_amt).toEqual("$0.00");
      expect(order.order_summary).toEqual(get_order().order_summary);
      expect(order.order_receipt).toEqual(get_order().order_receipt);
      expect(order.status).toEqual("O");
      expect(order.order_date).toEqual("2015-05-28");
      expect(order.grand_total).toEqual("$16.79");
      expect(order.skin_message).toEqual(true);
      expect(order.merchant).toEqual({  object: get_order().merchant,
                                        full_address: get_order().merchant_full_address,
                                        transaction_fee: get_order().merchant_transaction_fee })
    });
  });
});