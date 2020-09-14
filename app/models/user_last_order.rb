class UserLastOrder < UserFavorite
  attr_accessor :last_order_id, :label

  def initialize(params = {})
    self.last_order_id = params["order_id"].to_i
    self.label = params["label"]

    if params["order"].present? && params["menu_items"].present?
      self.items = initialize_favorites(
        params["order"]["items"],
        params["menu_items"]
      )
    end
  end

end
