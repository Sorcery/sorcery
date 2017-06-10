require 'spec_helper'

describe SorceryController, type: :controller do
  let!(:user) { double('user', id: 42) }

  describe 'with jwt auth features' do
    let(:user_email) { 'test@test.test' }
    let(:user_password) { 'testpass' }
    let(:auth_token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6NDJ9.rrjj-sXvbIjT8y4MLGb88Cv7XvfpJXj-HEgaBimT_-0' }
    let(:response_data) do
      {
        user_data: { id: user.id },
        auth_token: auth_token
      }
    end

    before(:all) do
      sorcery_reload!([:jwt_auth])
    end

    describe '#jwt_login' do
      context 'when success' do
        before do
          allow(User).to receive(:authenticate).with(user_email, user_password).and_return(user)

          post :test_jwt_auth, params: { email: user_email, password: user_password }
        end

        it 'assigns user to @token variable' do
          expect(assigns[:token]).to eq response_data
        end
      end

      context 'when fails' do
        before do
          allow(User).to receive(:authenticate).with(user_email, user_password).and_return(nil)

          post :test_jwt_auth, params: { email: user_email, password: user_password }
        end

        it 'assigns user to @token variable' do
          expect(assigns[:token]).to eq nil
        end
      end
    end

    describe '#jwt_require_auth' do
      context 'when success' do
        before do
          allow(User).to receive(:find).with(user.id).and_return(user)
          allow(user).to receive(:set_last_activity_at)
        end

        it 'does return 200' do
          request.headers.merge! Authorization: auth_token

          get :some_action_jwt, format: :json

          expect(response.status).to eq(200)
        end
      end

      context 'when fails' do
        let(:user_email) { 'test@test.test' }
        let(:user_password) { 'testpass' }

        it 'does return 401' do
          get :some_action_jwt, format: :json

          expect(response.status).to eq(401)
        end
      end
    end
  end
end