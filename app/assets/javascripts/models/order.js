var Order = (function () {
  function Order(params) {

    if (params !== undefined) {
      this.order_id = params.order_id;
      this.tip_amt = params.tip_amt;
      this.order_summary = params.order_summary;
      this.order_receipt = params.order_receipt;
      this.status = params.status;
      this.order_date = params.order_date2;
      this.grand_total = params.grand_total;
      this.skin_message = params.skin_message;
      this.merchant = { object: params.merchant,
                        full_address: params.merchant_full_address,
                        transaction_fee: params.merchant_transaction_fee };
    }
  }

  return Order;
})();