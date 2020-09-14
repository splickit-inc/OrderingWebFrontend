require "rails_helper"

describe "layouts/application.html.erb" do
  before(:each) do
    def view.current_user_name
      "test"
    end

    def view.current_user_email
      "test"
    end

    def view.error
      "test"
    end

    allow(view).to receive(:current_user_name).and_return("Bob")
    allow(view).to receive(:current_user_email).and_return("bob@cat.com")
    allow(view).to receive(:error).and_return(nil)
    assign(:skin, Skin.initialize)
    render
  end

  it "renders shared/header" do
    expect(rendered).to render_template("shared/_header")
  end

  it "renders shared/flash_notifications" do
    expect(rendered).to render_template("shared/_flash_notifications")
  end

  it "renders shared/footer" do
    expect(rendered).to render_template("shared/_footer")
  end
end
