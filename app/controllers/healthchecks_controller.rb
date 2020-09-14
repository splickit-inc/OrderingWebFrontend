class HealthchecksController < ApplicationController
  skip_before_action :set_user_instance, :log_user_agent, :redirect_unsupported_mobile_browsers,
                     :sign_in_punchh

  def new
    render "sessions/new", status: 200
  end
end