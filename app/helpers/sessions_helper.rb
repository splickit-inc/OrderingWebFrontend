module SessionsHelper
  include CartsHelper

  def sign_in(params = {})
    user = User.authenticate(params)
    continue = session[:continue]
    order = session[:order]
    order.delete(:cart_id) if order.present?
    group_order_token = session[:current_user] ? session[:current_user]["group_order_token"] : nil
    group_order = session[:group_order]
    sign_out
    set_user_session(user)
    set_user_instance
    #TODO change var 'remember_me' to response API
    is_remember?(params)

    #TODO: refactor stuff
    session[:continue] = continue if continue.present?
    if order.present?
      session[:order] = order
      reset_items_for_new_order
    end
    session[:current_user]["group_order_token"] = group_order_token if group_order_token.present?
    session[:group_order] = group_order if group_order.present?
  end

  def sign_out
    session[:current_user]["group_order_token"] = nil unless session[:current_user].blank?
    reset_session
    reset_cookies
  end

  def reset_cookies
    for cookie in cookies
      cookies.delete(cookie[0])
    end
  end

  def come_from_dialog?
    params[:dialog].to_s == "1"
  end

  def admin_login?
    params[:admin_login].to_s == "1"
  end

  def is_caterings?
    if session['continue'].to_s.scan("caterings").length > 0
      return true
    end
  end

  def is_guest_user?
    return false if !current_user.present? || current_user.nil?
    current_user.is_guest?
  end

  def is_remember?(params = {})
    if params["remember"].present?
      session[:remember_me] = {"remember_me" => params["remember"] != "0"}
    else
      session[:remember_me] = {"remember_me" => false}
    end
    save_cookie_session
  end

  def save_cookie_session
    if session[:remember_me].present? and session[:remember_me]["remember_me"]
      user = session[:current_user]
      cookies[:remember_me] = {
          splickit_authentication_token: user["splickit_authentication_token"]
      }.to_json
    end
  end
end
