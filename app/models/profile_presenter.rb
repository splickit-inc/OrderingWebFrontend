class ProfilePresenter < BaseModel
  
  attr_accessor :user_id, :first_name, :last_name, :contact_no, :email, :credit_card_number, :addresses

  def initialize user
    @user_id = user.user_id
    @first_name = user.first_name.present? ? user.first_name.capitalize : ""
    @last_name = user.last_name.present? ? user.last_name.capitalize : ""
    @contact_no = user.contact_no
    @email = user.email
    @credit_card_number = user.last_four.present? ? "**** **** **** #{user.last_four}" : ""
    @addresses = user.delivery_locations.present? ? user.delivery_locations.map { |hash| OpenStruct.new hash } : []
  end
end
