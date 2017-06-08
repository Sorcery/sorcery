require 'spec_helper'

describe SorceryController, type: :controller do
  let!(:user) { double('user', id: 42) }

  describe 'with jwt auth features' do
    before(:all) do
      sorcery_reload!([:jwt_auth])
    end

    describe '#jwt_login' do
      context 'when success' do
        let(:user_email) { 'test@test.test' }
        let(:user_password) { 'testpass' }
        let(:response_data) do
          {
            user_data: { id: user.id },
            auth_token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6NDJ9.mAd7vnXsLOwacr2AbfDAG6S0C-3pBHPrdYIoevtVRsw'
          }
        end

        before do
          allow(User).to receive(:authenticate).with(user_email, user_password).and_return(user)

          post :test_jwt_auth, params: { email: user_email, password: user_password }
        end

        it 'assigns user to @token variable' do
          expect(assigns[:token]).to eq response_data
        end
      end

      context 'when fails' do
        let(:user_email) { 'test@test.test' }
        let(:user_password) { 'testpass' }

        before do
          post :test_jwt_auth, params: { email: user_email, password: user_password }
        end

        it 'require_login before_action' do
          get :some_action_jwt, format: :json

          expect(response.status).to eq(401)
        end
      end
    end
  end
end