require 'spec_helper'

describe SorceryController, type: :controller do
  let!(:user) { double('user', id: 42) }
  before(:each) do
    request.env['HTTP_ACCEPT'] = "application/json" if ::Rails.version < '5.0.0'
    Timecop.freeze(Time.new(2019, 01, 14, 19, 00, 00))
  end

  describe 'with jwt auth features' do
    let(:user_email) { 'test@test.test' }
    let(:user_password) { 'testpass' }
    let(:auth_token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjQyLCJleHAiOjE1NDc3MTkyMDAsImlhdCI6MTU0NzQ2MDAwMH0.QM5mTkYiDwI-10cEOq4b_bfrwe99BRuef6pnIB-jqIk' }
    let(:response_data) do
      {
        user_data: {
            sub: user.id,
            exp: 1547719200,
            iat: 1547460000
        },
        auth_token: auth_token
      }
    end

    before(:all) do
      sorcery_reload!([:jwt_auth])
    end

    describe '#jwt_auth' do
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

        context 'without auth header' do
          it 'does return 401' do
            get :some_action_jwt, format: :json

            expect(response.status).to eq(401)
            expect(JSON.parse(response.body)["error"]["message"]).not_to be nil
          end
        end

        context 'with incorrect auth header' do
          let(:incorrect_header) { '123.123.123' }

          it 'does return 401' do
            request.headers.merge! Authorization: incorrect_header

            get :some_action_jwt, format: :json

            expect(response.status).to eq(401)
            expect(JSON.parse(response.body)["error"]["message"]).not_to be nil
          end
        end
        
        context "token is expired" do
          before do
            Timecop.freeze(Time.new(2099, 01, 14, 19, 00, 00))
            request.headers.merge! Authorization: auth_token
          end

          it "does return 401" do
            get :some_action_jwt, format: :json
  
            expect(response.status).to eq(401)
            expect(JSON.parse(response.body)["error"]["message"]).not_to be nil
          end

          after do
            Timecop.return
          end
        end
      end
    end
  end

  after do
    Timecop.return
  end
end
