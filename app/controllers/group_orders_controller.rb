require "exceptions"

class GroupOrdersController < ApplicationController
  include CartsHelper

  skip_before_action :set_user_instance, only:[:remove_item]

  before_action :redirect_if_signed_out, only: [:add_items, :remove_item]
  before_action :valid_merchant?, only: [:new]
  before_action :verify_order_type, only: [:new]
  before_action :redirect_if_guest, except: [:add_items, :remove_item]
  before_action :admin_redirect_if_signed_out, except: [:add_items, :remove_item]

  def show
    begin
      @group_order = GroupOrder.find(params, current_user_auth_token_hash)

      respond_to do |format|
        format.json { render json: @group_order }
        format.html do
          set_admin_group_order_token(@group_order["group_order_token"])
          @merchant = Merchant.info(@group_order["merchant_id"],
                                    @group_order["merchant_menu_type"] == "delivery",
                                    current_user_auth_token_hash)
        end
      end

    rescue APIError => e
      redirect_to root_path, error: e.message
    end
  end

  def success
    @group_order_token = params[:id]
  end

  def new
    begin
      @merchant = Merchant.info(params[:merchant_id], delivery?, current_user_auth_token_hash)

      if params[:user_addr_id]
        unless Merchant.in_delivery_area?(@merchant.merchant_id, params[:user_addr_id],params[:has_catering], current_user_auth_token_hash)
          redirect_to root_path(location: session[:location]), flash: { error: "Sorry, that address isn't in range." }
        end
      end

      group_order_type_selected = params[:group_order_type] || GroupOrder::ORGANIZER_PAY

      @merchant.group_order_available_times(group_order_type_selected, params[:order_type] || params[:merchant_menu_type],
                                            current_user_auth_token_hash)

      # Review merchant_menu_type dependence
      @group_order = GroupOrder.new(merchant_menu_type: params[:merchant_menu_type],
                                    participant_emails: params[:participant_emails],
                                    notes: params[:notes],
                                    submit_at_ts: params[:submit_at_ts],
                                    group_order_type: group_order_type_selected)

    rescue APIError => e
      redirect_to root_path(location: session[:location]),
                  flash: { error: e.message }
    end
  end

  def create
    begin
      params[:group_order].delete(:submit_at_ts) if params[:group_order][:group_order_type] == GroupOrder::ORGANIZER_PAY
      @group_order = GroupOrder.save(group_order_params.to_h, current_user_auth_token_hash)

      set_preferred_address
      reset_cart!

      redirect_to group_order_path(@group_order["group_order_token"]), notice: "Group order successfully created!"
    rescue APIError, InvalidGroupOrder => e
      redirect_to new_group_orders_path(group_order_params.to_h), error: e.message
    end
  end

  def add_items
    begin
      GroupOrder.add_items(params[:group_order_token], items_params, current_user_auth_token_hash)

      reset_cart!

      if @user.group_order_token.present?
        redirect_to group_order_path(@user.group_order_token),
                    flash: { notice: "Item added successfully" }
        return
      end

      redirect_to confirmation_group_orders_path
    rescue APIError => e
      redirect_to merchant_path(params[:merchant_id], params.permit(:group_order_token, :merchant_id)), error: e.message
    end
  end

  def remove_item
    begin
      @group_order = GroupOrder.remove_item(params.permit(:group_order_token, :item_id).to_h, current_user_auth_token_hash)

      render json: { itemID: params[:item_id], itemCount: number_of_items }, status: :ok
    rescue APIError => e
      render json: { item_id: params[:item_id], message: e.message }, status: 500
    end
  end

  def destroy
    begin
      GroupOrder.destroy(params, current_user_auth_token_hash)

      clear_order!

      redirect_to root_path, flash: { notice: "Your group order was cancelled" }
    rescue APIError => e
      redirect_to root_path, error: e.message
    end
  end

  def submit
    begin
      GroupOrder.submit(params[:id], current_user_auth_token_hash)

      clear_order!

      redirect_to success_group_order_path(params[:id])
    rescue APIError => e
      redirect_to group_order_path(params[:id]), flash: { error: e.message }
    end
  end

  def increment
    @group_order = GroupOrder.increment(params[:id], params[:time], current_user_auth_token_hash)

    respond_to do |format|
      format.json { render json: @group_order, status: :ok }
      format.html { redirect_to group_order_path(params[:id]) }
    end
  rescue APIError => e
    respond_to do |format|
      format.json { render json: e.message.capitalize, status: :unprocessable_entity }
      format.html { redirect_to group_order_path(params[:id]), error: e.message }
    end
  end

  def confirmation
  end

  def inactive
  end

  private

  def verify_order_type
    reset_cart! if cart_catering_order?
  end

  def admin_redirect_if_signed_out
    redirect_to(sign_in_path(continue: request.fullpath, admin_login: "1")) unless signed_in?
  end

  def number_of_items
    if @group_order && @group_order["order_summary"] && @group_order["order_summary"] != true
      @group_order["order_summary"]["cart_items"].length
    else
      0
    end
  end

  def set_preferred_address
    cookies[:userPrefs] = { preferredAddressId: params[:group_order][:user_addr_id] }.to_json if params[:group_order][:user_addr_id]
  end

  def set_admin_group_order_token(token)
    set_current_group_order_token(token)
  end

  def valid_delivery_addresses
    return nil if params[:menu_type] == "pickup"

    delivery_locations = @user.delivery_locations
    if delivery_locations
      delivery_locations.collect! do |location|
        if Merchant.in_delivery_area?(params[:merchant_id], location["user_addr_id"], params[:has_catering], {user_auth_token: current_user_auth_token})
          location
        end
      end
      delivery_locations.compact
    else
      []
    end
  end

  def items_params
    item_params = {
      user_id: current_user_id,
      merchant_id: params["merchant_id"]
    }

    item_params[:items] = []

    session[:order][:items].each do |item|
      item_params[:items] << {
        item_id:  item["item_id"],
        quantity: item["quantity"],
        mods:     item["mods"],
        size_id:  item["size_id"],
        note:     item["note"]
      }
    end

    item_params
  end

  def clear_order!
    session.delete(:group_order)
    set_current_group_order_token(nil)
    reset_cart!
  end

  def user_params
    params.require(:group_order).permit(
      :participant_emails,
      :notes,
      :merchant_menu_type,
      :merchant_id
    )
  end

  def valid_merchant?
    redirect_to root_path, error: "Invalid merchant." unless params[:merchant_id]
  end

  def group_order_params
    params.require(:group_order).permit(:merchant_id, :group_order_type, :merchant_menu_type, :notes,
                                        :participant_emails, :submit_at_ts, :user_addr_id)
  end
end
