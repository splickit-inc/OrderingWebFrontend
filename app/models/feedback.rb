class Feedback < BaseModel

  attr_accessor :name, :email, :support_address, :topic, :body, :params, :time, :skin_name

  def send_mail
    FeedbacksMailer.feedback_email(self).deliver
  end

end
