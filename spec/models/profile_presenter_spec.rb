require "rails_helper"
require 'ostruct'

describe ProfilePresenter do
  describe "#initialize" do

    it 'should set its attributes based off passed in user' do
      profile = ProfilePresenter.new(create_authenticated_user)
            
      expect(profile.user_id).to eq('2')
      expect(profile.first_name).to eq('Bob')
      expect(profile.last_name).to eq('Roberts')
      expect(profile.contact_no).to eq('4442221111')
      expect(profile.email).to eq('bob@roberts.com')
      expect(profile.credit_card_number).to eq('**** **** **** 9861')
    end

    it 'should return nil for attributes that do not exist on user' do
      profile = ProfilePresenter.new(User.initialize({}))
      expect(profile.user_id).to be_nil
      expect(profile.first_name).to eq("")
      expect(profile.last_name).to eq("")
      expect(profile.contact_no).to be_nil
      expect(profile.email).to be_nil
      expect(profile.credit_card_number).to eq("")
    end
  end
end
