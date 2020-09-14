require 'exceptions'

class FeedbacksController < ApplicationController

  def new
    if @skin.feedback_url.present?
      redirect_to @skin.feedback_url
    else
      @name = params[:name] || current_user_name
      @email = params[:email] || current_user_email
      @feedback = Feedback.new
    end
  end

  def create
    Rails.logger.info "--- feedbacks#create with #{ params.inspect }"
    if params[:honeypot].blank? && params[:human] == "on"
      support_email = "feedback@splickit.com"
      if !@skin.support_email.blank? && !@skin.support_email_categories.blank?
        support_email = @skin.support_email if @skin.support_email_categories.split(',').include?(params[:subject])
      elsif !@skin.support_email.blank?
        support_email = @skin.support_email
      end

      feedback = Feedback.new feedback_params
      feedback.support_address = support_email
      feedback.time = Time.current
      feedback.skin_name = Skin.current_name

      Rails.logger.info "--- creating new feedback email"
      Rails.logger.info "--- sending to #{support_email}"

      feedback.send_mail
    end

    render "feedbacks/thank_you"
  end

  def feedback_params
    params.require(:feedback).permit(:name, :email, :topic, :body)
  end
end
