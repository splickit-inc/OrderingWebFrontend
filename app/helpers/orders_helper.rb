module OrdersHelper
  def build_order_receipt(receipt_items)
    receipt_items.map { |k|
      Hash[k["title"].downcase.gsub(' ', '_').to_sym, k["amount"].gsub('$', '')]
    }.reduce({}, :merge)
  end

  def get_receipt_data(order, skin)
    order["merchant_full_address"] = order["merchant"].full_address if order["merchant"].present?
    order["merchant_transaction_fee"] = number_to_currency(order["merchant"].transaction_fee) if order["merchant"].present?
    order["order_receipt"] = build_order_receipt(order["order_summary"]["receipt_items"])
    order["skin_message"] = skin.show_notes_fields
    order["grand_total"] = generate_total(order["order_receipt"]) if order["order_receipt"].present?
    order["order_receipt"][:subtotal] = number_to_currency(order["order_receipt"][:subtotal]) if order["order_receipt"][:subtotal].present?
    order["order_receipt"][:tax] = number_to_currency(order["order_receipt"][:tax]) if order["order_receipt"][:tax].present?
    order["order_receipt"][:promo_discount] = number_to_currency(order["order_receipt"][:promo_discount]) if order["order_receipt"][:promo_discount].present?
    order["order_receipt"][:donation] = number_to_currency(order["order_receipt"][:donation]) if order["order_receipt"][:donation]
    order["order_receipt"][:delivery_fee] = number_to_currency(order["order_receipt"][:delivery_fee]) if order["order_receipt"][:delivery_fee].present?
    order["order_receipt"][:points_used] = number_to_currency(order["order_receipt"][:points_used]) if order["order_receipt"][:points_used].present?
    order["tip_amt"] = number_to_currency(order["tip_amt"])if order["tip_amt"].present?
  end
end