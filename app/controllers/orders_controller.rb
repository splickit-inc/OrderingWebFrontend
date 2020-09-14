class OrdersController < ApplicationController
  include CartsHelper

  skip_before_action :set_user_instance
  before_action :render_blank_if_orderless, only: [:show_item, :update_item, :delete_item]
  after_action :set_test_items, if: "Rails.env.test?", only: [:create_item, :update_item, :delete_item]

  def show
    Rails.logger.info "Showing items"
    if order_exists?
      render json: { order: { items: get_items, meta: session[:order][:meta] } }, status: :ok
    else
      render json: { order: { items: [] } }, status: :ok
    end
  end

  def create_item
    if valid_params?
      Rails.logger.info "Adding items #{ params[:items] }"

      initialize_order

      new_items = JSON.parse(params[:items])
      new_items.each { |item| item.merge!("uuid" => uuid, "status" => CartsHelper::STATUS[:new]) }

      session[:order][:items] += new_items

      (session[:order][:meta]).merge!(merchant_id: params[:merchant_id],
                                      order_type: params[:order_type],
                                      merchant_name: params[:merchant_name],
                                      skin_name: @skin.skin_name)

      session[:order][:meta][:group_order_token] = params[:group_order_token] if params[:group_order_token].present?

      render json: { order: { items: get_items } }, status: :ok
    else
      head :bad_request
    end
  end

  def show_item
    render json: { item: find_item("uuid" => params[:id]), meta: session[:order][:meta] }, status: :ok
  end

  def update_item
    Rails.logger.info("Updating item with id #{ params[:id] }")

    item = find_item("uuid" => params[:id])

    if item.present?
      item.reject! { |k, v| k.to_s != "order_detail_id" && k.to_s != "status" && !item_params.include?(k.to_s) }
      item.merge!(item_params)
      item["status"] = CartsHelper::STATUS[:updated] if item["order_detail_id"].present?
    end

    render json: { order: { items: get_items }, meta: session[:order][:meta] }, status: :ok
  end

  def delete_item
    Rails.logger.info("Deleting item with id #{ params[:id] }")

    item = find_item("uuid" => params[:id])

    if item.present?
      if item["order_detail_id"].present?
        item["status"] = CartsHelper::STATUS[:deleted]
      else
        session[:order][:items].delete(item)
      end

      render json: { order: { items: get_items }, user: { points_used: item["points_used"] } }, status: :ok
    else
      Rails.logger.error "Unable to find item to delete"

      head :bad_request
    end
  end

  def destroy
    reset_cart!

    redirect_to root_path
  end

  def checkout
    if session[:order] && session[:order][:meta]
      redirect_to new_checkout_path(session[:order][:meta].except(:skin_name).except(:merchant_name))
    else
      redirect_to root_path, flash: { error: "We're sorry, we cannot place your order. Your cart is currently empty." }
    end
  end

  private

  def render_blank_if_orderless
    head :not_found if session[:order].blank?
  end

  def valid_params?
    params[:merchant_id].present? && params[:order_type].present? && params[:items]
  end

  def uuid
    SecureRandom.uuid
  end

  def set_test_items
    Rails.cache.write(:items, session[:order][:items]) if order_exists?
  end

  def item_params
    params.require(:item)
  end
end
