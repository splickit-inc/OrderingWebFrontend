require "rails_helper"

describe UserFavoritesController do
  describe '#create' do
    let(:params) { { user_favorite: { order_id: '1234', favorite_name: 'Special favorite' } } }

    before(:each) do
      sign_in(get_user_data)
    end

    context 'success' do
      let(:api_response) { {
        favorite_id: 85472,
        favorite_name: 'SOFA KING',
        user_message: 'Your favorite was successfully stored.'
      } }

      before do
        allow(API).to receive_message_chain(:post, :status) { 200 }
        allow(API).to receive_message_chain(:post, :body) { {data: api_response}.to_json }
      end

      describe 'json' do
        before do
          change_to_json_request
        end

        it 'returns the correct status code' do
          post :create, params: params
          expect(response.status).to eq(200)
        end

        it 'returns a valid JSON response' do
          post :create, params: params
          expect(response.body).to eq(api_response.to_json)
        end
      end

      describe 'html' do
        it 'redirects to orders history user path' do
          post :create, params: params
          expect(response).to redirect_to(orders_history_user_path)
        end

        it 'return a correct flash' do
          post :create, params: params
          expect(flash[:notice]).to be_present
          expect(flash[:notice]).to eq('Your favorite was successfully stored.')
        end
      end
    end


    context 'failure' do
      before do
        allow(API).to receive_message_chain(:post, :status) { 500 }
        allow(API).to receive_message_chain(:post, :body) { {error: {error: 'you forgot something'}}.to_json }
      end

      describe 'json' do
        before do
          change_to_json_request
        end

        it 'returns the correct status code' do
          post :create, params: params
          expect(response.status).to eq(500)
        end

        it 'returns a valid JSON response' do
          post :create, params: params
          expect(response.body).to eq('You forgot something')
        end
      end

      describe 'html' do
        it 'redirects to orders history user path' do
          post :create, params: params
          expect(response).to redirect_to(orders_history_user_path)
        end

        it 'return a error flash' do
          post :create, params: params
          expect(flash[:error]).to be_present
          expect(flash[:error]).to eq('You forgot something')
        end
      end
    end
  end

  describe '#destroy' do
    let(:params) { {id: '1234'} }

    before(:each) do
      sign_in(get_user_data)
    end

    context 'success' do
      let(:api_response) { {
        user_message: 'Your favorite was successfully deleted'
      } }

      before do
        allow(API).to receive_message_chain(:delete, :status) { 200 }
        allow(API).to receive_message_chain(:delete, :body) { {data: api_response}.to_json }
        @request.env['HTTP_REFERER'] = 'http://www.woot.com'
      end

      it 'returns the correct status code' do
        delete :destroy, params: params
        expect(response.status).to eq(302)
      end

      it 'calls the correct model method' do
        expect(UserFavorite).to receive('destroy').with(params[:id], {:user_auth_token => "ASNDKASNDAS"})
        delete :destroy, params: params
      end

      it 'redirects to the last location' do
        delete :destroy, params: params
        expect(response).to redirect_to('http://www.woot.com')
      end
    end

    context 'failure' do
      before do
        allow(API).to receive_message_chain(:delete, :status) { 500 }
        allow(API).to receive_message_chain(:delete, :body) { {error: {error: 'you forgot something'}}.to_json }
      end

      it 'returns the correct status code' do
        delete :destroy, params: params
        expect(response.status).to eq(500)
      end

      it 'returns a valid JSON response' do
        delete :destroy, params: params
        expect(response.body).to eq('You forgot something')
      end
    end
  end
end
