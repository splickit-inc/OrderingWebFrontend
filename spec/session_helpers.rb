module SessionHelpers
  def destroy_user_session
    session[:current_user] = nil if (defined?(session))
  end
end
