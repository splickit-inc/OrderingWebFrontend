require 'exceptions'

class PasswordResetsController < ApplicationController

  before_action :validate_password, only: [:update_password]

  def request_email
    render "password_resets/request_email"
  end

  def request_token
    @email = params[:email]
    if @email
      response = JSON.parse(API.get("/users/forgotpassword?email=#{CGI.escape @email}", {:email => @email, :use_admin => true}).body)

      if response["error"]
        redirect_to request_email_path, flash: {error: response["error"]["error"]}
      else
        render "password_resets/email_sent"
      end
    else
      redirect_to request_email_path, flash: {error: "Please enter a valid email."}
    end
  end

  def request_reset
    @token = params[:token]
    render "password_resets/request_reset"
  end

  def update_password
    @token = params[:token]
    @password = params[:password]

    if @token and @password
      response = JSON.parse(API.post("/users/resetpassword", {:token => @token, :password => @password}.to_json, {:use_admin => true}).body)

      if response["error"]
        redirect_to(request_reset_path(:token => @token), :error => response["error"]["error"])
      else
        redirect_to(sign_in_path(continue: root_path), :notice => "Your password has been reset. Please sign in below.")
      end
    end
  end

  def validate_password

    if params[:password].length < 8
      error = "Password must be at least 8 characters in length."
    elsif params[:password] != params[:confirm]
      error = "Password confirmation must match your password."
    elsif params[:password].blank? || params[:confirm].blank?
      error = "Password cannot be whitespace."
    end

    if error
      redirect_to(request_reset_path(token: params[:token]), error: error)
    end
  end
end
