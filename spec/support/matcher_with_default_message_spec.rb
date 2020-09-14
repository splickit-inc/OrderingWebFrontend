require "rails_helper"

RSpec::Matchers.define :be_visible do |expected|
  match do |actual|
    (actual.visible? == true)
  end
end

RSpec::Matchers.define :be_hidden do |expected|
  match do |actual|
    (actual.visible? == false)
  end  
end  

RSpec::Matchers.define :have_content do |expected|
  match do |actual|
    (actual.content? == true)
  end
end



