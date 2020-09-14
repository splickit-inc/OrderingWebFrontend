require "rails_helper"

describe Feedback do
  describe "#send_mail" do
    it "call FeedbackMailer" do
      feedback = Feedback.new
      deliver_spy = double("delivery")
      expect(deliver_spy).to receive("deliver")
      expect(FeedbacksMailer).to receive("feedback_email").with(feedback).and_return(deliver_spy)
      feedback.send_mail
    end
  end
end
