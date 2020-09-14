require "date"

module LoyaltiesHelper
  def user_loyal?
    !@user.nil? && @user.loyal?
  end

  def loyalty_balance(type)
    case type
      when "usd"
        @user.brand_loyalty[type]
      when "points"
        @user.brand_loyalty[type] ? loyalty_points(type) : 0
      else
        loyalty_points(type) if @user.brand_loyalty[type]
    end
  end

  def loyalty_points(type)
    loyalty = @user.brand_loyalty[type].to_i
    loyalty -= total_points_used if @merchant && @order_type
    loyalty
  end

  def loyalty_time
    Time.now.strftime("%-m/%-d/%Y")
  end

  private

  def total_points_used
    begin
      session[:order][:items].map { |item| item["points_used"].to_i }.reduce(:+).to_i
    rescue NoMethodError
      0
    end
  end
end
