class ErrorsController < ApplicationController
  skip_before_action :set_user_instance
  skip_before_action :setup_skin_id, only: [:error_590]

  layout "error"

  def error_404
    render :status => 404
  end

  def error_422
    render :status => 422
  end

  def error_500
    render :status => 500
  end

  def error_590
    render :status => 590
  end
end
