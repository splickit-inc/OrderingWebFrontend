require "exceptions"
require "cgi"

class SessionsController < ApplicationController
  skip_before_action :set_user_instance

  before_action :set_continue, only: [:new, :create]
  before_action :redirect_if_signed_in, :set_continue_params, only: [:new, :create]

  def create
    sign_in(user_params)
    redirect_to_continue
  rescue APIError => error
    @error = error
    puts session[:error]
    puts @error
    render :new
  end

  def new
    # log in page should not be cached by browsers... should it?
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def destroy
    sign_out

    redirect_to root_path
  end

  def session_status
    render json: {signed_in: signed_in?}, status: :ok
  end

  private

  def user_params
    decode_params(params.require(:user).permit(:email, :password, :remember))
  end

  def set_continue_params
    if params[:continue_path].present?
      query_params = URI(params[:continue_path]).query
      if query_params.present?
        forwarding_url = "#{ params[:continue_path] }&"
      else
        forwarding_url = "#{ params[:continue_path] }?"
      end
      query_params = params.keys.select {|key| key.include? "query"}
      query_params.each do |param|
        forwarding_url += "#{ param.gsub("query_", "") }=#{ CGI::escape(params[param]) }&"
      end
      forwarding_url.chomp!("&")
      session[:continue] = CGI::escape(forwarding_url)
    end
  end

  def is_facebook?
    return true if session[:current_user]["flags"][4] == "F"
  end
end
