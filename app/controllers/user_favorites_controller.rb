class UserFavoritesController < ApplicationController
  before_action :redirect_if_signed_out
  before_action :redirect_if_guest

  def create
    favorite = params['user_favorite']
    if favorite['favorite_name'].blank?
      respond_to do |format|
        format.json { render json: "Please name your favorite", status: 500 }
        format.html { redirect_to orders_history_user_path,
                                  flash: { error: "Please name your favorite"} }
      end
    else
      favorite_response = UserFavorite.create(params['user_favorite'],
                                              current_user_auth_token_hash)
      respond_to do |format|
        format.json { render json: favorite_response, status: 200 }
        format.html { redirect_to orders_history_user_path,
                                flash: { notice: favorite_response["user_message"] } }
      end
    end
    rescue APIError => e
      respond_to do |format|
        format.json { render json: e.message.capitalize, status: 500 }
        format.html { redirect_to orders_history_user_path,
                                flash: { error: e.message.capitalize } }
    end
  end

  def destroy
    begin
      favorite_response = UserFavorite.destroy(params["id"],
                           current_user_auth_token_hash)
      respond_to do |format|
        format.json { render json: favorite_response, status: 200 }
        format.html { redirect_back(fallback_location: root_path, notice: favorite_response["user_message"]) }
      end
    rescue APIError => e
      render json: e.message.capitalize, status: 500
    end
  end
end
