module UsersHelper
  def user_loyal?
    @user.present? && @user.loyal?
  end

  def trimmed_first_name
    session[:current_user]["first_name"][0, 20] if signed_in? && !current_user.is_guest? && session[:current_user]["first_name"]
  end
end
