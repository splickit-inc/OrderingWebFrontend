class FeedbacksMailer < ActionMailer::Base

  default from: "support@order140.com"

  def feedback_email feedback
    @feedback = feedback
    mail(to: feedback.support_address,
         reply_to: feedback.email,
         subject: "#{ feedback.skin_name } #{ feedback.topic } Feedback")
  end
end
