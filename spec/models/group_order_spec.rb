require "rails_helper"

describe GroupOrder do
  subject { GroupOrder.new }

  it { is_expected.to respond_to(:participant_emails) }
  it { is_expected.to respond_to(:notes) }
  it { is_expected.to respond_to(:merchant_menu_type) }
  it { is_expected.to respond_to(:merchant_id) }
  it { is_expected.to respond_to(:items) }
  it { is_expected.to respond_to(:status) }

  describe "#save" do
    let(:valid_params) { {"merchant_id" => 1, "participant_emails" => "bob@gmail.com"} }
    let(:valid_user) { {email: "tom@bom.com", password: "welcome"} }

    context "success" do
      before(:each) do
        allow(API).to receive_message_chain(:post, :status) { 200 }
        allow(API).to receive_message_chain(:post, :body) { { data: valid_params }.to_json }
      end

      it "returns the response body" do
        expect(GroupOrder.save(valid_params, valid_user)).to eq({"merchant_id" => 1, "participant_emails" => "bob@gmail.com"})
      end

      it "calls API.post with valid params" do
        expect(API).to receive("post").with("/grouporders", valid_params.to_json, valid_user)
        GroupOrder.save(valid_params, valid_user)
      end
    end

    context "failure" do
      before(:each) do
        allow(API).to receive_message_chain(:post, :status) { 404 }
        allow(API).to receive_message_chain(:post, :body) { { error: "error" }.to_json }
      end

      it "raises an APIError" do
        expect { GroupOrder.save(valid_params, valid_user) }.to raise_error(APIError)
      end
    end

    context "email validation" do
      context "invalid emails" do
        let(:invalid_emails1) { {"merchant_id" => 1, "participant_emails" => "bob%gmail.com"} }
        let(:invalid_emails2) { {"merchant_id" => 1, "participant_emails" => "bob@gmail.com ted@gmail.com"} }
        let(:invalid_emails3) { {"merchant_id" => 1, "participant_emails" => "bob@gmail"} }
        let(:invalid_emails4) { {"merchant_id" => 1, "participant_emails" => "bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com"} }

        it 'should not call API' do
          expect(API).not_to receive("post")
          expect { GroupOrder.save(invalid_emails1, valid_user) }.to raise_error(InvalidGroupOrder)
        end

        it 'should detect if it has invalid character combinations' do
          expect { GroupOrder.save(invalid_emails1, valid_user) }.to raise_error InvalidGroupOrder, "The list of participants includes invalid emails"
        end

        it 'should detect if emails are not comma separated' do
          expect { GroupOrder.save(invalid_emails2, valid_user) }.to raise_error InvalidGroupOrder, "The list of participants includes invalid emails"
        end

        it 'should detect if it is missing parts' do
          expect { GroupOrder.save(invalid_emails3, valid_user) }.to raise_error InvalidGroupOrder, "The list of participants includes invalid emails"
        end

        it 'should not cap group order emails at 15' do
          allow(API).to receive_message_chain(:post, :status) { 200 }
          allow(API).to receive_message_chain(:post, :body) { { data: valid_params }.to_json }
          expect { GroupOrder.save(invalid_emails4, valid_user) }.to_not raise_error
        end
      end
    end

    context "valid emails" do
      let(:fifteen_valid_emails) { {"merchant_id" => 1, "participant_emails" => "bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com,bob@gmail.com"} }
      let(:whitespace_valid_emails) { {"merchant_id" => 1, "participant_emails" => "bob@gmail.com,bob@gmail.com, bob@gmail.com, bob@gmail.com"} }

      it 'should allow for up to 15 email' do
        allow(API).to receive_message_chain(:post, :status) { 200 }
        allow(API).to receive_message_chain(:post, :body) { {data: fifteen_valid_emails}.to_json }
        expect(API).to receive("post").with("/grouporders", fifteen_valid_emails.to_json, valid_user)
        GroupOrder.save(fifteen_valid_emails, valid_user)
      end

      it 'should allow whitespace between comma and email' do
        allow(API).to receive_message_chain(:post, :status) { 200 }
        allow(API).to receive_message_chain(:post, :body) { {data: whitespace_valid_emails}.to_json }
        expect(API).to receive("post").with("/grouporders", whitespace_valid_emails.to_json, valid_user)
        GroupOrder.save(whitespace_valid_emails, valid_user)
      end
    end
  end

  describe "#find" do
    let(:valid_params) { {id: "L2N9V-08ERQ"} }
    let(:valid_response) { {"id" => "L2N9V-08ERQ", "participant_emails" => "t@nk.com, fr@nk.com"} }
    let(:valid_user) { {email: "tom@bom.com", password: "welcome"} }

    context "success" do
      before(:each) do
        allow(API).to receive_message_chain(:get, :status) { 200 }
        allow(API).to receive_message_chain(:get, :body) { {data: valid_response}.to_json }
      end

      it "returns the response body" do
        expect(GroupOrder.find(valid_params, valid_user)).to eq(valid_response)
      end

      it "calls API.post with the correct params" do
        expect(API).to receive("get").with("/grouporders/L2N9V-08ERQ", valid_user)
        GroupOrder.find(valid_params, valid_user)
      end
    end

    context "failure" do
      before(:each) do
        allow(API).to receive_message_chain(:get, :status) { 422 }
        allow(API).to receive_message_chain(:get, :body) { { error: "error" }.to_json }
      end

      it "raises an APIError" do
        expect { GroupOrder.find(valid_params, valid_user) }.to raise_error(APIError)
      end
    end
  end

  describe "#add_items" do
    let(:valid_id) { "L2N9V-08ERQ" }
    let(:valid_user) { {email: "tom@bom.com", password: "welcome"} }
    let(:valid_params) { {bacon: "burgers"} }

    before(:each) do
      allow(API).to receive_message_chain(:post, :body) { {}.to_json }
      allow(API).to receive_message_chain(:post, :status) { 200 }
    end

    it "calls Cart.update with the correct params" do
      expect(API).to receive('post').with("/grouporders/#{ valid_id }", valid_params.to_json, valid_user)
      GroupOrder.add_items(valid_id, valid_params, valid_user)
    end
  end

  describe "#delete_item" do
    let(:valid_user) { {email: "tom@bom.com", password: "welcome"} }
    let(:valid_params) { {item_id: "619238", group_order_token: "5436-4w89q-v8j88-8t2v9"} }

    context "success" do
      before(:each) do
        allow(API).to receive_message_chain(:delete, :body) { {}.to_json }
        allow(API).to receive_message_chain(:delete, :status) { 200 }
      end

      it "calls Cart.update with the correct params" do
        expect(API).to receive("delete").with("/cart/5436-4w89q-v8j88-8t2v9/cartitem/619238", valid_user)
        GroupOrder.remove_item(valid_params, valid_user)
      end
    end

    context "failure" do
      before(:each) do
        allow(API).to receive_message_chain(:delete, :status) { 422 }
        allow(API).to receive_message_chain(:delete, :body) { { error: "error" }.to_json }
      end

      it { expect { GroupOrder.remove_item(valid_params, valid_user) }.to raise_error(APIError) }
    end
  end

  describe "#destroy" do
    let(:valid_params) { { id: "L2N9V-08ERQ" } }
    let(:valid_response) { {"id" => "L2N9V-08ERQ", "participant_emails" => "t@nk.com, fr@nk.com", "status" => "cancelled"} }
    let(:valid_user) { {email: "tom@bom.com", password: "welcome"} }

    context "success" do
      before(:each) do
        allow(API).to receive_message_chain(:delete, :status) { 200 }
        allow(API).to receive_message_chain(:delete, :body) { {data: valid_response}.to_json }
      end

      it "returns the response body" do
        expect(GroupOrder.destroy(valid_params, valid_user)).to eq(valid_response)
      end

      it "calls API.post with the correct params" do
        expect(API).to receive("delete").with("/grouporders/L2N9V-08ERQ", valid_user)
        GroupOrder.destroy(valid_params, valid_user)
      end
    end

    context "failure" do
      before(:each) do
        allow(API).to receive_message_chain(:delete, :status) { 422 }
        allow(API).to receive_message_chain(:delete, :body) { { error: "error" }.to_json }
      end

      it "raises an APIError" do
        expect { GroupOrder.destroy(valid_params, valid_user) }.to raise_error(APIError)
      end
    end
  end

  describe "#increment" do
    let(:valid_params) { { id: "L2N9V-08ERQ" } }
    let(:valid_user) { { email: "tom@bom.com", password: "welcome" } }

    it "calls API.post with the correct params" do
      expect(API).to receive("post").with("/grouporders/L2N9V-08ERQ/increment/10", "", valid_user)
      GroupOrder.increment("L2N9V-08ERQ", "10", valid_user)
    end
  end
end
