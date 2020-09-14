require 'exceptions'

class UserAddressesController < ApplicationController
  skip_before_action :set_user_instance, only: [:create]

  before_action :redirect_if_signed_out
  before_action :redirect_if_guest, except: [:new, :create]
  before_action :set_continue, only: [:index]

  def index
    @path = params[:path] # To redirect to a good page
    @addresses = ProfilePresenter.new(@user).addresses
    render "users/address/delivery_address"
  end

  def new
    @path = params[:path]
    render "users/address/new_address"
  end

  def create
    #TODO refactor this code
    begin
      response = User.store_address(user_address_params, current_user_auth_token_hash)
      set_user_instance(true)

      if is_guest_user?
        cookies[:deliveryAddress] = response.to_json
      end
      @path = params[:path]

      if @path.present?
        new_delivery_address_id = response["user_addr_id"]
        params[:continue] = "#{ @path }&user_addr_id=#{ new_delivery_address_id }"
        set_continue
        cookies[:userPrefs] = { preferredAddressId: new_delivery_address_id.to_s }.to_json
      end
      flash[:notice] = "Address successfully added!"
      redirect_to_continue(user_address_index_path)
    rescue APIError => e
      address = user_address_params.delete_if { |k, v| v.empty? }
      address = address.merge(path: params[:path]) if params[:path]
      redirect_to user_address_index_path(address), flash: { error: e.message }
    end
  end

  def destroy
    begin
      User.delete_address(current_user_id, params[:id], @user.splickit_authentication_token)
      set_user_instance(true)

      respond_to do |format|
        format.json { render json: { user_addr_id: params[:id] }, status: :ok }
        format.html do
          flash[:notice] = "Address successfully deleted!"
          redirect_to_continue(user_address_index_path)
        end
      end
    rescue APIError => e
      respond_to do |format|
        format.json { render json: e.message.capitalize, status: :internal_server_error }
        format.html { redirect_to user_address_index_path, flash: { error: e.message } }
      end
    end
  end

  private

  def user_address_params
    params.require(:address).permit(:address1, :address2, :city, :state, :zip, :phone_no,
                                    :instructions,:business_name)

  end
end
