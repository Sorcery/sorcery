require 'spec_helper'

describe SorceryController, type: :controller do
  let!(:user) { double('user', id: 42) }

  context 'with session token features' do
    before(:all) do
      sorcery_reload!([:single_session])
    end

    after(:all) do
      sorcery_controller_property_set(:verify_session_token_enabled, false)
    end

    before(:each) do
      allow(user).to receive(:session_token) { 'valid-session-token' }
      allow(user).to receive(:regenerate_session_token) { 'valid-session-token' }

      allow(user).to receive(:email)
      allow(user).to receive_message_chain(:sorcery_config, :username_attribute_names, :first) { :email }
    end

    it 'does not reset session if token is valid' do
      login_user user
      session[:token] = 'valid-session-token'

      get :test_should_be_logged_in

      expect(session[:user_id]).not_to be_nil
      expect(response).to be_successful
    end

    it 'does reset session if token is invalid' do
      login_user user
      session[:token] = 'invalid-session-token'

      get :test_should_be_logged_in

      expect(session[:user_id]).to be_nil
      expect(response).not_to be_successful
    end

    it 'regenerates token on login' do
      expect(user).to receive(:regenerate_session_token)
      login_user user
    end
  end
end
