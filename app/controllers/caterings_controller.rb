# encoding: utf-8
require 'net/http'
require 'exceptions'

class CateringsController < ApplicationController
  include CartsHelper, CateringsHelper

  before_action :redirect_if_signed_out, except: [:begin]
  before_action :reset_order_data, only: [:new, :begin]
  before_action :redirect_if_wrong_delivery_data, only: [:new, :update_delivery_address, :begin]
  before_action :get_params_to_catering_pages, only: [:new, :begin]

  def get_params_to_catering_pages
    @merchant = Merchant.info(params[:merchant_id], "catering", current_user_auth_token_hash)
    if params[:order_type].present?
      @has_order_type = order_type
    end
    @catering_data = @merchant.catering_data(order_type, current_user_auth_token_hash)
    dt_now_utc = date_time_now_utc(@catering_data["available_catering_times"]["time_zone"])
    @times = Catering.times(params[:merchant_id], @catering_data["available_catering_times"],
                            current_user_auth_token_hash, dt_now_utc.to_i)
    session[:available_catering_times] = @catering_data["available_catering_times"]
    if delivery? && !is_guest_user?
      @delivery_address = @user.delivery_locations.find { |hash_addresses| hash_addresses["user_addr_id"].to_i == @user_addr_id.to_i }
    end

    if is_guest_user? && delivery?
      @delivery_address = JSON.parse(cookies[:deliveryAddress])
    end
  end

  def new

  rescue APIError => e
    redirect_to root_path, flash: { error: e.message }
  end

  def begin

  rescue APIError => e
    redirect_to root_path, flash: { error: e.message }
  end

  def update_delivery_address
    if delivery?
      @delivery_address = @user.delivery_locations.find { |hash_addresses| hash_addresses["user_addr_id"].to_i == @user_addr_id.to_i }
      @delivery_address["phone_no"] = number_to_phone(@delivery_address["phone_no"])

      respond_to do |format|
        format.json { render json: { delivery_address_info: @delivery_address }, status: :ok }
      end
    end
  end

  def create
    @catering = Catering.create(catering_params, current_user_auth_token_hash)

    initialize_order

    set_cart_id(@catering["ucid"])

    session[:order][:meta] = { merchant_id: params[:merchant_id], order_type: params[:order_type],
                               catering: true, skin_name: @skin.skin_name }

    redirect_to merchant_path(params[:merchant_id], order_type: order_type, catering: "1")

  rescue APIError => e
    redirect_to new_catering_path(merchant_id: params[:merchant_id], order_type: order_type), flash: { error: e.message }
  end

  def times
    available_catering_times = session[:available_catering_times]
    unless available_catering_times.present?
      catering_data = Merchant.catering_data(params[:merchant_id], order_type,
                                              current_user_auth_token_hash)
      available_catering_times = catering_data["available_catering_times"]
    end
    @times = Catering.times(params[:merchant_id], available_catering_times,
                                                        current_user_auth_token_hash,
                            params[:date])

    respond_to do |format|
      format.json { render json: { merchant: { merchant_id: params[:merchant_id], catering_times: @times } }, status: :ok }
    end
  rescue APIError => e
    respond_to do |format|
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  private

  def catering_params
    params.require(:catering)
      .permit(:number_of_people, :timestamp_of_event, :merchant_id, :contact_name, :contact_phone, :notes)
      .to_h.merge(params.permit(:merchant_id, :user_addr_id).to_h)
  end

  def reset_order_data
    reset_cart!
    delete_checkout_detail_data
  end
end
