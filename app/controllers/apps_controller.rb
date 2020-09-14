class AppsController < ApplicationController
  skip_before_action :redirect_unsupported_mobile_browsers

  def show
  end

  def redirect_to_app_store
	  user_agent = request.user_agent
		mobile_store_url =
		if @skin.iphone_app_link && user_agent.present? && (user_agent.match(/iPad/) || user_agent.match(/iPhone/))
			@skin.iphone_app_link
		elsif @skin.android_marketplace_link && user_agent.present? && user_agent.match(/Android/)
			@skin.android_marketplace_link
		else
			Rails.logger.error "WEB ERROR: apps_controller - redirect_to_app_store - user agent: #{ user_agent }, iphone store: #{ @skin.iphone_app_link }, android store: #{ @skin.android_marketplace_link } "
			root_path
		end
		redirect_to mobile_store_url
	end
end
