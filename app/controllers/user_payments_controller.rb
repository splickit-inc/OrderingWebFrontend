require 'exceptions'

class UserPaymentsController < ApplicationController
  skip_before_action :set_user_instance, only: [:create]

  before_action :redirect_if_signed_out
  before_action :redirect_if_guest, except: [:create]
  before_action :set_continue, only: [:new, :create]

  def new
    begin
      get_secure_form_data
      render "users/payment_method"
    rescue APIError => e
      redirect_to new_user_payment_path, flash: { error: e.message }
    end
  end

  def create
    begin
      Rails.logger.info "Updating user payment with params #{ params.inspect } at time #{ Time.now.strftime("%H:%M:%S.%3N") }"
      user = User.update(payment_params(params),
                         current_user_id,
                         session[:current_user]["splickit_authentication_token"])
      update_current_user(last_four: user.last_four, flags: user.flags)

      flash[:notice] = "Your card was successfully updated."
      redirect_to_continue(new_user_payment_path)
    rescue APIError => e
      flash[:error] = e.message
      redirect_to_continue(new_user_payment_path)
    end
  end

  def destroy
    begin
      user_response = User.delete_credit_card(current_user_id, current_user_auth_token_hash)
      set_user_instance(true)
      flash[:notice] = user_response["user_message"]
      redirect_to new_user_payment_path
    rescue APIError => e
      flash[:error] = e.message
      redirect_to_continue(new_user_payment_path)
    end
  end

  private

  def payment_params(params)
    { credit_card_saved_in_vault: false,
      credit_card_token_single_use: params['valueio_token'] }
  end
end