# encoding: utf-8
require 'net/http'
require 'exceptions'

class MerchantsController < ApplicationController
  include CheckoutsHelper, GroupOrdersHelper, CartsHelper

  before_action :set_location, :set_merchant_list, :set_delivery_path, only: [:index]
  before_action :different_merchant?, only: [:show]
  before_action :ensure_group_order?, only: [:show]
  before_action :redirect_correct_merchant, only: [:show]
  before_action :set_see_inactive_merchants

  def index
    @location = session[:location]

    begin
      params = {}

      if @merchant_list.present?
        params[:merchantlist] = @merchant_list
        @merchants = Merchant.where(params, current_user_auth_token_hash)
      elsif @location.present?
        params[:location] = @location
        @merchants = Merchant.where(params, current_user_auth_token_hash)
      elsif session[:lat].present? && session[:lng].present?
        params[:lat] = session[:lat]
        params[:lng] = session[:lng]
        @merchants = Merchant.where(params, current_user_auth_token_hash)
      elsif (resp = GeoIPService.find(request.remote_ip)).present?
        params[:lat], params[:lng] = resp
        session[:lat], session[:lng] = resp
        @merchants = Merchant.where(params, current_user_auth_token_hash)
      elsif skin_zip.present?
        params[:location] = skin_zip
        @merchants = Merchant.where(params, current_user_auth_token_hash)
      elsif !@merchant_list.nil?
        flash.now[:error] = "Please enter a merchantlist param"
      else
        flash.now[:error] = "Please enter a valid zip code."
      end
      process_guest_user_warning
    rescue APIError => error
      session[:location] = nil
      if error.data.present? and error.data[:status] == 401
        sign_out
        redirect_to root_path
      end
      Rails.logger.error "API ERROR: #{error.message}"
      flash.now[:error] = error.message
    end
  end

  def show
    begin
      @catering_needs_config = params[:set_config] if params[:set_config].present?
      @merchant = Merchant.find(params[:id], is_catering? ? "catering" : delivery?, current_user_auth_token_hash)
      @is_catering = is_catering?
      order_type
      @group_order_token = params[:group_order_token]
      # It avoids user enters here when the order is submitted
      if is_a_group_order?
        @group_order = GroupOrder.find({id: params[:group_order_token]}, {use_admin: true})
        set_group_order_session(type: @group_order["group_order_type"])
      end

      session[:last_merchant_seen] = params[:id].to_s

      if delivery? && @group_order_token.blank?
        raise NotSignedIn.new("Please sign in and select a delivery address.") unless signed_in?

        raise MissingAddress.new("Please select a valid delivery address.") if cookies[:userPrefs].nil?

        user_addr_id = JSON.parse(cookies[:userPrefs])["preferredAddressId"]
        unless Merchant.in_delivery_area?(@merchant.merchant_id, user_addr_id, is_catering?, current_user_auth_token_hash)
          redirect_to root_path(location: session[:location]), flash: {error: "Sorry, that address isn't in range."}
        end
      end

      set_cart_order_type(@order_type)

      @modal = params[:my_order].present? && params[:my_order] == "1"

      flash.now[:alert] = @merchant.message if @merchant.message.present?
    rescue APIError => e
      Rails.logger.error "API ERROR: #{ e.message }"
      if cart_catering_order?
        redirect_to merchant_path(params[:merchant_id], params.slice(*[:order_type, :group_order_token]).permit!, catering: "1"), flash: {error: e.message}
      else
        redirect_to merchants_path, flash: {error: e.message}
      end
      if e.data.present? and e.data[:status] == 401
        sign_out
        redirect_to root_path
      end
    rescue MissingAddress, NotSignedIn => e
      redirect_to merchants_path, flash: {error: e.message}
    rescue GroupOrderError => e
      clear_group_order_data
      reset_cart_id
      reset_items_for_new_order
      redirect_to merchant_path(params[:id], order_type: params[:order_type]), flash: {error: e.message}
    end
  end

  def group_order_available_times
    @merchant = Merchant.find(params[:id], delivery?, current_user_auth_token_hash)
    group_order_available_times = @merchant.group_order_available_times(GroupOrder::INVITE_PAY,
                                                                        params[:order_type],
                                                                        current_user_auth_token_hash)

    respond_to do |format|
      format.json {render json: time_options_for_select(group_order_available_times,
                                                        @merchant.time_zone_offset.to_i), status: :ok}
    end
  rescue APIError => e
    respond_to do |format|
      format.json {render json: e.message.capitalize, status: 500}
    end
  end

  def nutrition_sizes_information
    nutrition_information = MenuItem.nutrition_information(params[:id], params[:size_id], current_user_auth_token_hash)

    respond_to do |format|
      format.json {render json: nutrition_information, status: 200}
    end
  rescue APIError => e
    respond_to do |format|
      format.json {render json: e.message, status: 500}
    end
  end

  private

  def merchant_params
    params.permit(:order_type, :group_order_token, :my_order)
  end

  def redirect_correct_merchant
    begin
      merchant = Merchant.info(params[:id], is_catering? ? "catering" : delivery?, current_user_auth_token_hash)
      redirect_to merchant_path(merchant.moved_to_merchant_id, merchant_params) if merchant.moved_to_merchant_id.present?
    rescue APIError => e
      redirect_to root_path, flash: {error: e.message}
    end
  end

  def is_catering?
    params["catering"] == "1"
  end

  def different_merchant?
    if session[:order] && session[:order][:meta] && menu_mismatch?
      reset_cart!
      delete_checkout_detail_data
      redirect_to(merchant_path(params.permit!))
    end
  end

  def catering_type_mismatch?
    is_catering? != cart_catering_order?
  end

  def menu_mismatch?
    (params[:id] && params[:id].to_i != cart_merchant_id.to_i) || catering_type_mismatch?
  end

  def set_location
    return session[:location] = params[:location] if params[:location]
    session[:location] = params[:zip] if params[:zip].present?
  end

  def set_merchant_list
    @merchant_list = params[:merchantlist]
  end

  def skin_zip
    @skin.zip if @skin && @skin.zip
  end

  def set_see_inactive_merchants
    if session[:current_user]
      RequestStore.store[:see_inactive_merchants] = @user.see_inactive_merchants?
    else
      RequestStore.store[:see_inactive_merchants] = false
    end
  end

  def set_delivery_path
    @delivery_path = params[:delivery_path] if signed_in? && params[:delivery_path]
  end

  def ensure_group_order?
    if is_a_group_order? && session[:order]
      if group_order_token != session[:order][:meta][:group_order_token]
        session[:order] = nil
        delete_checkout_detail_data
        session[:group_order] = nil
      end
    end
  end

  def process_guest_user_warning
    return unless is_guest_user?
    has_catering = has_any_merchant_catering?
    has_group_ordering = has_any_merchant_group_ordering?
    if has_catering && has_group_ordering
      flash.now[:notice] = "Please notice that Guest users are not allowed to make Group " +
          "orders."
    elsif has_group_ordering
      flash.now[:notice] = "Please notice that Guest users are not allowed to make Group " +
          "orders."
    end
  end

  def has_any_merchant_catering?
    return false if !@merchants.present? || @merchants.nil?
    has = false
    @merchants.each do |m|
      if m.has_catering
        has = true
        break
      end
    end
    has
  end

  def has_any_merchant_group_ordering?
    return false if !@merchants.present? || @merchants.nil?
    has = false
    @merchants.each do |m|
      if m.group_ordering_on
        has = true
        break
      end
    end
    has
  end
end
