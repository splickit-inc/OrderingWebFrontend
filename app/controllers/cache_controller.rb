class CacheController < ActionController::Base

  http_basic_authenticate_with name: "admin", password: "temppass"

  def clear_merchant
    begin
      clear_cache("*-#{params[:id]}")
      render json: {id: params[:id], status: 200, message: "success"}, status: 200
    rescue => e
      render json: {id: params[:id], status: 422, message: e.message}, status: 422
    end
  end

  def clear_merchants
    begin
      clear_cache("view-partial-*")
      render json: {skin: "all skins", status: 200, message: "success"}, status: 200
    rescue => e
      render json: {skin: "all skins", status: 422, message: e.message}, status: 422
    end
  end

  private

  def clear_cache(key)
    Rails.cache.delete_matched(key)
  end
end
