require 'exceptions'

class GuestsController < ApplicationController
  before_action :redirect_if_signed_in, only: [:new]

  def new
    # log in page should not be cached by browsers... should it?
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    if params[:continue].present?
      session[:continue] = params[:continue]
    end
  end
end
