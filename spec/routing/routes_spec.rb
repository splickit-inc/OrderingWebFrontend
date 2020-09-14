require "rails_helper"

describe "routes_spec.rb" do
  describe "CacheController" do
    it { expect(post: "/cache/clear_merchant/1234").to route_to(controller: "cache", action: "clear_merchant", id: "1234") }
    it { expect(post: "/cache/clear_merchants").to route_to(controller: "cache", action: "clear_merchants") }
    it { expect(post: "/cache/clear_skin").to route_to(controller: "cache", action: "clear_skin") }
    it { expect(post: "/cache/warm").to route_to(controller: "cache", action: "warm_cache") }
  end

  describe "OrdersController" do
    it { expect(get: "/order").to route_to(controller: "orders", action: "show") }
    it { expect(get: "/order/item/4321").to route_to(controller: "orders", action: "show_item", id: "4321") }
    it { expect(put: "/order/item/6666").to route_to(controller: "orders", action: "update_item", id: "6666") }
    it { expect(post: "/order/item").to route_to(controller: "orders", action: "create_item") }
    it { expect(delete: "/order/item/6666").to route_to(controller: "orders", action: "delete_item", id: "6666") }
  end

  describe "CheckoutsController" do
    it { expect(get: "/empty_cart").to route_to(controller: "checkouts", action: "empty_cart") }
    it { expect(post: "/checkouts").to route_to(controller: "checkouts", action: "create") }
    it { expect(get: "/checkouts/new").to route_to(controller: "checkouts", action: "new") }
  end

  describe "SessionsController" do
    it { expect(get: "/sign_in").to route_to(controller: "sessions", action: "new") }
    it { expect(get: "/sign_out").to route_to(controller: "sessions", action: "destroy") }
    it { expect(post: "/sessions").to route_to(controller: "sessions", action: "create") }
  end

  describe "UsersController" do
    it { expect(get: "/sign_up").to route_to(controller: "users", action: "new") }
    it { expect(get: "/user/account").to route_to(controller: "users", action: "account") }
    it { expect(put: "/user/update_account").to route_to(controller: "users", action: "update_account") }
    it { expect(get: "/user/orders_history").to route_to(controller: "users", action: "orders_history") }
    it { expect(post: "/user").to route_to(controller: "users", action: "create") }
  end

  describe "MerchantsController" do
    it { expect(get: "/").to route_to(controller: "merchants", action: "index") }
    it { expect(get: "/merchants").to route_to(controller: "merchants", action: "index") }
    it { expect(get: "/merchants/1082").to route_to(controller: "merchants", action: "show", id: "1082") }
  end

  describe "GroupOrdersController" do
    it { expect(get: "/group_orders/inactive").to route_to(controller: "group_orders", action: "inactive") }
    it { expect(get: "/group_orders/123/success").to route_to(controller: "group_orders", action: "success", id: "123") }
  end

  describe "ErrorsController" do
    it { expect(get: "/404").to route_to(controller: "errors", action: "error_404") }
    it { expect(get: "/422").to route_to(controller: "errors", action: "error_422") }
    it { expect(get: "/500").to route_to(controller: "errors", action: "error_500") }
    it { expect(get: "/590").to route_to(controller: "errors", action: "error_590") }
  end

  describe "UserFavorites" do
    it { expect(post: "/favorites").to route_to(controller: "user_favorites", action: "create") }
    it { expect(delete: "/favorites/5").to route_to(controller: "user_favorites", action: "destroy", id: "5") }
  end

  describe "AppsController" do
    it { expect(get: "/sms_app_link").to route_to(controller: "apps", action: "redirect_to_app_store") }
  end

  describe "CateringController" do
    it { expect(get: "/caterings/new").to route_to(controller: "caterings", action: "new") }
    it { expect(get: "/caterings/times").to route_to(controller: "caterings", action: "times")}
  end

  describe "HealthchecksController" do
    it { expect(get: "/healthcheck").to route_to(controller: "healthchecks", action: "new") }
  end

  describe "SkinsController" do
    it { expect(post: "/skins/service").to route_to(controller: "skins", action: "service") }
  end
end
