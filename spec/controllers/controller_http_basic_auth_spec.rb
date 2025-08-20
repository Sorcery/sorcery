require 'spec_helper'

describe SorceryController, type: :controller do
  let!(:user) { User.create!(username: 'test_user', email: 'bla@bla.com', password: 'password') }

  describe 'with http basic auth features' do
    before(:all) do
      sorcery_reload!([:http_basic_auth])

      sorcery_controller_property_set(:controller_to_realm_map, 'sorcery' => 'sorcery')
    end

    after(:each) do
      logout_user
    end

    it 'requests basic authentication when before_action is used' do
      get :test_http_basic_auth

      expect(response.status).to eq 401
    end

    it 'authenticates from http basic if credentials are sent' do
      @request.env['HTTP_AUTHORIZATION'] = "Basic #{Base64.encode64("#{user.email}:secret")}"
      expect(User).to receive('authenticate').with('bla@bla.com', 'secret').and_return(user)
      get :test_http_basic_auth, params: {}, session: { http_authentication_used: true }

      expect(response).to be_successful
    end

    it 'fails authentication if credentials are wrong' do
      @request.env['HTTP_AUTHORIZATION'] = "Basic #{Base64.encode64("#{user.email}:wrong!")}"
      expect(User).to receive('authenticate').with('bla@bla.com', 'wrong!').and_return(nil)
      get :test_http_basic_auth, params: {}, session: { http_authentication_used: true }

      expect(response).to redirect_to root_url
    end

    it "allows configuration option 'controller_to_realm_map'" do
      sorcery_controller_property_set(:controller_to_realm_map, '1' => '2')

      expect(Sorcery::Controller::Config.controller_to_realm_map).to eq('1' => '2')
    end

    it 'displays the correct realm name configured for the controller' do
      sorcery_controller_property_set(:controller_to_realm_map, 'sorcery' => 'Salad')
      get :test_http_basic_auth

      expect(response.headers['WWW-Authenticate']).to eq 'Basic realm="Salad"'
    end

    it "signs in the user's session on successful login" do
      @request.env['HTTP_AUTHORIZATION'] = "Basic #{Base64.encode64("#{user.email}:secret")}"
      expect(User).to receive('authenticate').with('bla@bla.com', 'secret').and_return(user)

      get :test_http_basic_auth, params: {}, session: { http_authentication_used: true }

      expect(session[:user_id]).to eq user.id.to_s
    end
  end
end
