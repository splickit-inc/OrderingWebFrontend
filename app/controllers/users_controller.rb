require 'exceptions'

class UsersController < ApplicationController
  skip_before_action :set_user_instance, only: [:update_account]

  before_action :redirect_if_signed_out, except: [:new, :create]
  before_action :redirect_if_signed_in, only: [:new, :create]
  before_action :redirect_if_guest, except: [:new, :create, :add_gift_card]
  before_action :set_continue, only: [:new, :create]

  def new
    # log in page should not be cached by browsers... should it?
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def create
    user = User.create(user_params)
    if !user || user.errors.present?
      @user = user
      render :new
    else
      set_user_session(user)
      set_user_instance(true)
      flash[:notice] = "Your account was successfully created." if !@user.is_guest?
      if @user.is_guest?
        check_continue_to_guest
      end
      redirect_to_continue
    end
  rescue APIError => error
    @user = User.initialize(user_params)
    @error = error
    render_page = user_params[:is_guest] == "true" ? "guests/new" : "new"
    render render_page
  end

  def account
  end

  def update_account
    begin
      user = User.update(user_params, current_user_id, session[:current_user]["splickit_authentication_token"])

      update_current_user(first_name: user.first_name, last_name: user.last_name,
                          email: user.email, contact_no: user.contact_no)

      redirect_to account_user_path, flash: { notice: "Your account was successfully updated." }
    rescue PasswordMismatch, APIError => e
      redirect_to account_user_path, flash: { error: e.message }
    end
  end

  def orders_history
    begin
      page = params[:page] || 1
      order_data = @user.orders(@user.splickit_authentication_token, page)
      @orders = order_data[:orders]
      @orders_count = order_data[:count]
      @orders_pag = Kaminari.paginate_array([], total_count: @orders_count.to_i).page(page).per(10)
    rescue APIError => e
      redirect_to merchants_path, flash: { error: e.message }
    end
  end

  def add_gift_card
    card = params[:card_number].strip
    new_card =  params[:new_card]
    """@response = @user.add_gift_card(card,current_user_auth_token_hash)
    respond_to do |format|
      format.json {render json: @response}
    end"""
    begin
      @response_gift = User.add_gift_card(card,current_user_id,current_user_auth_token_hash)
      last_four = @response_gift["card_number"].chars.last(4).join if @response_gift["card_number"].present?
      flash.now[:notice] = @response_gift["message"] if @response_gift && @response_gift["message"].present?
      respond_to do |format|
        format.js{ render "users/add_gift_card", :locals => {:new_card => new_card, :currency=>(@response_gift["currency_symbol"] if @response_gift["currency_symbol"].present?),
                                                             :balance => (@response_gift["balance"] if @response_gift["balance"].present?) ,:last_four =>last_four}}
        #format.js
      end

    rescue APIError => e
      flash.now[:error] = e.message
      respond_to do |format|
        format.js
      end
    end
  end

  private

  def user_params
    decode_params(params.require(:user).permit(:first_name, :last_name, :email, :contact_no,
                                               :marketing_email_opt_in, :zipcode, :birthday,
                                               :password, :password_confirmation, :is_guest))
  end
end
