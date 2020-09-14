require 'exceptions'
require "net/https"

class LoyaltiesController < ApplicationController
  skip_before_action :set_user_instance, only: [:update_card]
  before_action :redirect_if_signed_out
  before_action :redirect_if_guest

  def show
    if @user.loyal?
      if @skin.loyalty_features["supports_history"]
        redirect_to history_user_loyalty_path
      else
        redirect_to rules_user_loyalty_path
      end
    else
      render "users/loyalty/join"
    end
  end

  def manage
    render "users/loyalty/manage"
  end

  def history
    @user_transactions = User.transaction_history(current_user_id, @user.splickit_authentication_token)
    render "users/loyalty/history"
  end

  def rules
    path = "/com.splickit.#{ Skin.current_name }/mobile/webviews/rules/index.html"
    begin
      bucket = ""
      if Rails.env.production?
        bucket = "com.splickit.products.s3.amazonaws.com"
      end
      if Rails.env.previewprod?
        bucket = "com.splickit.products.preview.s3.amazonaws.com"
      end
      if Rails.env.development? || Rails.env.staging? || Rails.env.test? || Rails.env.preview?
        bucket = "com.splickit.products.test.s3.amazonaws.com"
      end

      response = Net::HTTP.get_response(bucket, path)
      unless response.code == 200 || response.code == '200'
        raise "Page not Found"
      end
      @rules = response.body
    rescue => ex
      @rules = @skin.rules_info
    end
    render "users/loyalty/rules"
  end

  def update_card
    begin
      User.update(params[:brand_loyalty],
                  current_user_id,
                  session[:current_user]["splickit_authentication_token"])
      set_user_instance(true)
    rescue APIError => e
      error = e.message
    end

    redirect_to user_loyalty_path, flash: {error: error}
  end
end
