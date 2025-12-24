# frozen_string_literal: true

require 'spec_helper'

# require 'shared_examples/controller_oauth2_shared_examples'

describe SorceryController, :active_record, type: :controller do
  before(:all) do
    MigrationHelper.migrate("#{Rails.root}/db/migrate/external")
    MigrationHelper.migrate("#{Rails.root}/db/migrate/activation")
    MigrationHelper.migrate("#{Rails.root}/db/migrate/activity_logging")

    sorcery_reload!([:external])
    set_external_property
  end

  after(:all) do
    MigrationHelper.rollback("#{Rails.root}/db/migrate/external")
    MigrationHelper.rollback("#{Rails.root}/db/migrate/activity_logging")
    MigrationHelper.rollback("#{Rails.root}/db/migrate/activation")
  end

  describe 'using create_from' do
    before do
      stub_all_oauth2_requests!
    end

    it 'creates a new user' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, username: 'name')

      expect(User).to receive(:create_from_provider).with('facebook', '123', { username: 'Noam Ben Ari' })
      get :test_create_from_provider, params: { provider: 'facebook' }
    end

    it 'supports nested attributes' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, username: 'hometown/name')
      expect(User).to receive(:create_from_provider).with('facebook', '123', { username: 'Haifa, Israel' })

      get :test_create_from_provider, params: { provider: 'facebook' }
    end

    it 'does not crash on missing nested attributes' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, username: 'name', created_at: 'does/not/exist')

      expect(User).to receive(:create_from_provider).with('facebook', '123', { username: 'Noam Ben Ari' })

      get :test_create_from_provider, params: { provider: 'facebook' }
    end

    describe 'with a block' do
      it 'does not create user' do
        sorcery_model_property_set(:authentications_class, Authentication)
        sorcery_controller_external_property_set(:facebook, :user_info_mapping, username: 'name')

        u = User.new
        expect(User).to receive(:create_from_provider).with('facebook', '123', { username: 'Noam Ben Ari' }).and_return(u).and_yield(u)
        # test_create_from_provider_with_block in controller will check for uniqueness of username
        get :test_create_from_provider_with_block, params: { provider: 'facebook' }
      end
    end
  end

  # ----------------- OAuth -----------------------
  context 'with OAuth features' do
    let!(:user) { User.create!(username: 'test_user', email: 'test@example.com', password: 'password') }

    before do
      stub_all_oauth2_requests!
    end

    context 'when callback_url begin with /' do
      before do
        sorcery_controller_external_property_set(:facebook, :callback_url, '/oauth/twitter/callback')
      end

      after do
        sorcery_controller_external_property_set(:facebook, :callback_url, 'http://example.com')
      end

      it 'login_at redirects correctly' do
        get :login_at_test_facebook
        expect(response).to be_a_redirect
        expect(response).to redirect_to("https://www.facebook.com/dialog/oauth?client_id=#{Sorcery::Controller::Config.facebook.key}&display=page&redirect_uri=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&response_type=code&scope=email&state")
      end

      it 'logins with state' do
        get :login_at_test_with_state
        expect(response).to be_a_redirect
        expect(response).to redirect_to("https://www.facebook.com/dialog/oauth?client_id=#{Sorcery::Controller::Config.facebook.key}&display=page&redirect_uri=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&response_type=code&scope=email&state=bla")
      end

      it 'logins with Graph API version' do
        sorcery_controller_external_property_set(:facebook, :api_version, 'v2.2')
        get :login_at_test_with_state
        expect(response).to be_a_redirect
        expect(response).to redirect_to("https://www.facebook.com/v2.2/dialog/oauth?client_id=#{Sorcery::Controller::Config.facebook.key}&display=page&redirect_uri=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&response_type=code&scope=email&state=bla")
      end

      it 'logins without state after login with state' do
        get :login_at_test_with_state
        expect(response).to redirect_to("https://www.facebook.com/v2.2/dialog/oauth?client_id=#{Sorcery::Controller::Config.facebook.key}&display=page&redirect_uri=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&response_type=code&scope=email&state=bla")

        get :login_at_test_facebook
        expect(response).to redirect_to("https://www.facebook.com/v2.2/dialog/oauth?client_id=#{Sorcery::Controller::Config.facebook.key}&display=page&redirect_uri=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&response_type=code&scope=email&state")
      end
    end

    context 'when callback_url begin with http://' do
      before do
        sorcery_controller_external_property_set(:facebook, :callback_url, '/oauth/twitter/callback')
        sorcery_controller_external_property_set(:facebook, :api_version, 'v2.2')
      end

      after do
        sorcery_controller_external_property_set(:facebook, :callback_url, 'http://example.com')
      end

      it 'login_at redirects correctly' do
        create_new_user
        get :login_at_test_facebook
        expect(response).to be_a_redirect
        expect(response).to redirect_to("https://www.facebook.com/v2.2/dialog/oauth?client_id=#{Sorcery::Controller::Config.facebook.key}&display=page&redirect_uri=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&response_type=code&scope=email&state")
      end
    end

    it "'login_from' logins if user exists" do
      sorcery_model_property_set(:authentications_class, Authentication)
      expect(User).to receive(:load_from_provider).with(:facebook, '123').and_return(user)
      get :test_login_from_facebook

      expect(flash[:notice]).to eq 'Success!'
    end

    it "'login_from' fails if user doesn't exist" do
      sorcery_model_property_set(:authentications_class, Authentication)
      expect(User).to receive(:load_from_provider).with(:facebook, '123').and_return(nil)
      get :test_login_from_facebook

      expect(flash[:alert]).to eq 'Failed!'
    end

    it 'on successful login_from the user is redirected to the url he originally wanted' do
      sorcery_model_property_set(:authentications_class, Authentication)
      expect(User).to receive(:load_from_provider).with(:facebook, '123').and_return(user)
      get :test_return_to_with_external_facebook, params: {}, session: { return_to_url: 'fuu' }

      expect(response).to redirect_to('fuu')
      expect(flash[:notice]).to eq 'Success!'
    end

    %i[github google vk salesforce paypal slack wechat microsoft instagram auth0 discord battlenet].each do |provider|
      describe "with #{provider}" do
        it 'login_at redirects correctly' do
          get :"login_at_test_#{provider}"

          expect(response).to be_a_redirect
          expect(response).to redirect_to(provider_url(provider))
        end

        it "'login_from' logins if user exists" do
          sorcery_model_property_set(:authentications_class, Authentication)
          expect(User).to receive(:load_from_provider).with(provider, '123').and_return(user)
          get :"test_login_from_#{provider}"

          expect(flash[:notice]).to eq 'Success!'
        end

        it "'login_from' fails if user doesn't exist" do
          sorcery_model_property_set(:authentications_class, Authentication)
          expect(User).to receive(:load_from_provider).with(provider, '123').and_return(nil)
          get :"test_login_from_#{provider}"

          expect(flash[:alert]).to eq 'Failed!'
        end

        it "on successful login_from the user is redirected to the url he originally wanted (#{provider})" do
          sorcery_model_property_set(:authentications_class, Authentication)
          expect(User).to receive(:load_from_provider).with(provider, '123').and_return(user)
          get :"test_return_to_with_external_#{provider}", params: {}, session: { return_to_url: 'fuu' }

          expect(response).to redirect_to 'fuu'
          expect(flash[:notice]).to eq 'Success!'
        end
      end
    end
  end

  describe 'OAuth with User Activation features' do
    before(:all) do
      sorcery_reload!(%i[user_activation external], user_activation_mailer: SorceryMailer)
      sorcery_controller_property_set(
        :external_providers,
        %i[
          facebook
          github
          google
          vk
          salesforce
          paypal
          slack
          wechat
          microsoft
          instagram
          auth0
          line
          discord
          battlenet
        ]
      )

      # TODO: refactor
      sorcery_controller_external_property_set(:facebook, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:facebook, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:facebook, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:github, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:github, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:github, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:google, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:google, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:google, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:vk, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:vk, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:vk, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:salesforce, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:salesforce, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:salesforce, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:paypal, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:paypal, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:paypal, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:slack, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:slack, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:slack, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:wechat, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:wechat, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:wechat, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:microsoft, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:microsoft, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:microsoft, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:instagram, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:instagram, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:instagram, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:auth0, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:auth0, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:auth0, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:auth0, :site, 'https://auth0.example.com')
      sorcery_controller_external_property_set(:line, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:line, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:line, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:discord, :key, 'eYVNBjBDi33aa9GkA3w')
      sorcery_controller_external_property_set(:discord, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
      sorcery_controller_external_property_set(:discord, :callback_url, 'http://example.com')
      sorcery_controller_external_property_set(:battlenet, :key, '4c43d4862c774ca5bbde89873bf0d338')
      sorcery_controller_external_property_set(:battlenet, :secret, 'TxY7IwKOykACd8kUxPyVGTqBs44UBDdX')
      sorcery_controller_external_property_set(:battlenet, :callback_url, 'http://example.com')
    end

    after do
      User.sorcery_adapter.delete_all
    end

    it 'does not send activation email to external users' do
      old_size = ActionMailer::Base.deliveries.size
      create_new_external_user(:facebook)

      expect(ActionMailer::Base.deliveries.size).to eq old_size
    end

    it 'does not send external users an activation success email' do
      sorcery_model_property_set(:activation_success_email_method_name, nil)
      create_new_external_user(:facebook)
      old_size = ActionMailer::Base.deliveries.size
      @user.activate!

      expect(ActionMailer::Base.deliveries.size).to eq old_size
    end

    %i[github google vk salesforce paypal wechat microsoft instagram auth0 discord battlenet].each do |provider|
      it "does not send activation email to external users (#{provider})" do
        old_size = ActionMailer::Base.deliveries.size
        create_new_external_user provider
        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "does not send external users an activation success email (#{provider})" do
        sorcery_model_property_set(:activation_success_email_method_name, nil)
        create_new_external_user provider
        old_size = ActionMailer::Base.deliveries.size
        @user.activate!
        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end
    end
  end

  describe 'OAuth with user activation features' do
    let!(:user) { User.create!(username: 'activation_user', email: 'activation@example.com', password: 'password') }

    before(:all) do
      sorcery_reload!(%i[activity_logging external])
    end

    %w[facebook github google vk salesforce slack discord battlenet].each do |provider|
      context "when #{provider}" do
        before do
          sorcery_controller_property_set(:register_login_time, true)
          sorcery_controller_property_set(:register_logout_time, false)
          sorcery_controller_property_set(:register_last_activity_time, false)
          sorcery_controller_property_set(:register_last_ip_address, false)
          stub_all_oauth2_requests!
          sorcery_model_property_set(:authentications_class, Authentication)
        end

        it 'registers login time' do
          now = Time.now.in_time_zone
          Timecop.freeze(now)
          expect(User).to receive(:load_from_provider).and_return(user)
          expect(user).to receive(:set_last_login_at).with(be_within(0.1).of(now))
          get :"test_login_from_#{provider}"
          Timecop.return
        end

        it 'does not register login time if configured so' do
          sorcery_controller_property_set(:register_login_time, false)
          now = Time.now.in_time_zone
          Timecop.freeze(now)
          expect(User).to receive(:load_from_provider).and_return(user)
          expect(user).not_to receive(:set_last_login_at)
          get :"test_login_from_#{provider}"
        end
      end
    end
  end

  describe 'OAuth with session timeout features' do
    before(:all) do
      sorcery_reload!(%i[session_timeout external])
    end

    let!(:user) { User.create!(username: 'timeout_user', email: 'timeout@example.com', password: 'password') }

    %w[facebook github google vk salesforce slack discord battlenet].each do |provider|
      context "when #{provider}" do
        before do
          sorcery_model_property_set(:authentications_class, Authentication)
          sorcery_controller_property_set(:session_timeout, 0.5)
          stub_all_oauth2_requests!
        end

        after do
          Timecop.return
        end

        it 'does not reset session before session timeout' do
          expect(User).to receive(:load_from_provider).with(provider.to_sym, '123').and_return(user)
          get :"test_login_from_#{provider}"

          expect(session[:user_id]).not_to be_nil
          expect(flash[:notice]).to eq 'Success!'
        end

        it 'resets session after session timeout' do
          expect(User).to receive(:load_from_provider).with(provider.to_sym, '123').and_return(user)
          get :"test_login_from_#{provider}"
          expect(session[:user_id]).to eq user.id.to_s
          Timecop.travel(Time.now.in_time_zone + 0.6)
          get :test_should_be_logged_in

          expect(session[:user_id]).to be_nil
          expect(response).to be_a_redirect
        end
      end
    end
  end

  def stub_all_oauth2_requests!
    access_token = instance_double(OAuth2::AccessToken)
    # Needed for Instagram
    allow(access_token).to receive(:[]).with(:client_id).and_return('eYVNBjBDi33aa9GkA3w')
    response = instance_double(OAuth2::Response)
    allow(response).to receive(:body) {
      {
        'id' => '123',
        'user_id' => '123', # Needed for Salesforce
        'sub' => '123', # Needed for Auth0
        'name' => 'Noam Ben Ari',
        'first_name' => 'Noam',
        'last_name' => 'Ben Ari',
        'link' => 'http://profile.example.com/testuser1',
        'hometown' => {
          'id' => '110619208966868',
          'name' => 'Haifa, Israel'
        },
        'location' => {
          'id' => '106906559341067',
          'name' => 'Pardes Hanah, Hefa, Israel'
        },
        'bio' => "I'm a new daddy, and enjoying it!",
        'gender' => 'male',
        'email' => 'nbenari@example.com',
        'timezone' => 2,
        'locale' => 'en_US',
        'languages' => [
          {
            'id' => '108405449189952',
            'name' => 'Hebrew'
          },
          {
            'id' => '106059522759137',
            'name' => 'English'
          },
          {
            'id' => '112624162082677',
            'name' => 'Russian'
          }
        ],
        'verified' => true,
        'updated_time' => '2011-02-16T20:59:38+0000',
        # response for VK auth
        'response' => [
          {
            'id' => '123',
            'first_name' => 'Noam',
            'last_name' => 'Ben Ari'
          }
        ],
        'user' => {
          'name' => 'Sonny Whether',
          'id' => '123',
          'email' => 'bobby@example.com'
        },
        # response for wechat auth
        'unionid' => '123',
        # response for instagram
        'data' => {
          'username' => 'pnmahoney',
          'bio' => 'turn WHAT down?',
          'website' => '',
          'profile_picture' => 'http://images.example.com/test-profile.jpg',
          'full_name' => 'Patrick Mahoney',
          'counts' => {
            'media' => 2,
            'followed_by' => 100,
            'follows' => 71
          },
          'id' => '123'
        }
      }.to_json
    }
    allow(access_token).to receive(:get) { response }
    # access_token params for VK auth
    allow(access_token).to receive_messages(token: '187041a618229fdaf16613e96e1caabc1e86e46bbfad228de41520e63fe45873684c365a14417289599f3', params: { 'user_id' => '100500', 'email' => 'nbenari@example.com' })

    allow_any_instance_of(OAuth2::Strategy::AuthCode).to receive(:get_token).and_return(access_token) # rubocop:disable RSpec/AnyInstance
  end

  def set_external_property
    sorcery_controller_property_set(
      :external_providers,
      %i[
        facebook
        github
        google
        vk
        salesforce
        paypal
        slack
        wechat
        microsoft
        instagram
        auth0
        line
        discord
        battlenet
      ]
    )
    sorcery_controller_external_property_set(:facebook, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:facebook, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:facebook, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:github, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:github, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:github, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:google, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:google, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:google, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:vk, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:vk, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:vk, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:salesforce, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:salesforce, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:salesforce, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:paypal, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:paypal, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:paypal, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:slack, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:slack, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:slack, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:wechat, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:wechat, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:wechat, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:microsoft, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:microsoft, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:microsoft, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:instagram, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:instagram, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:instagram, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:auth0, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:auth0, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:auth0, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:auth0, :site, 'https://auth0.example.com')
    sorcery_controller_external_property_set(:line, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:line, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:line, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:discord, :key, 'eYVNBjBDi33aa9GkA3w')
    sorcery_controller_external_property_set(:discord, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
    sorcery_controller_external_property_set(:discord, :callback_url, 'http://example.com')
    sorcery_controller_external_property_set(:battlenet, :key, '4c43d4862c774ca5bbde89873bf0d338')
    sorcery_controller_external_property_set(:battlenet, :secret, 'TxY7IwKOykACd8kUxPyVGTqBs44UBDdX')
    sorcery_controller_external_property_set(:battlenet, :callback_url, 'http://example.com')
  end

  def provider_url(provider)
    config = Sorcery::Controller::Config
    redirect_uri = 'http%3A%2F%2Fexample.com'

    urls = {
      github: 'https://github.com/login/oauth/authorize?' \
              "client_id=#{config.github.key}&display&redirect_uri=#{redirect_uri}" \
              '&response_type=code&scope&state',
      paypal: 'https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/authorize?' \
              "client_id=#{config.paypal.key}&display&redirect_uri=#{redirect_uri}" \
              '&response_type=code&scope=openid%20email&state',
      google: 'https://accounts.google.com/o/oauth2/auth?' \
              "client_id=#{config.google.key}&display&redirect_uri=#{redirect_uri}" \
              '&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email%20' \
              'https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile&state',
      vk: 'https://oauth.vk.com/authorize?' \
          "client_id=#{config.vk.key}&display&redirect_uri=#{redirect_uri}" \
          "&response_type=code&scope=#{config.vk.scope}&state",
      salesforce: 'https://login.salesforce.com/services/oauth2/authorize?' \
                  "client_id=#{config.salesforce.key}&display&redirect_uri=#{redirect_uri}" \
                  "&response_type=code&scope#{"=#{config.salesforce.scope}" unless config.salesforce.scope.nil?}&state",
      slack: 'https://slack.com/oauth/authorize?' \
             "client_id=#{config.slack.key}&display&redirect_uri=#{redirect_uri}" \
             '&response_type=code&scope=identity.basic%2C%20identity.email&state',
      wechat: 'https://open.weixin.qq.com/connect/qrconnect?' \
              "appid=#{config.wechat.key}&redirect_uri=#{redirect_uri}" \
              '&response_type=code&scope=snsapi_login&state=teststate#wechat_redirect',
      microsoft: 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize?' \
                 "client_id=#{config.microsoft.key}&display&redirect_uri=#{redirect_uri}" \
                 '&response_type=code&scope=openid%20email%20https%3A%2F%2Fgraph.microsoft.com%2FUser.Read&state',
      instagram: 'https://api.instagram.com/oauth/authorize?' \
                 "client_id=#{config.instagram.key}&display&redirect_uri=#{redirect_uri}" \
                 "&response_type=code&scope=#{config.instagram.scope}&state",
      auth0: 'https://auth0.example.com/authorize?' \
             "client_id=#{config.auth0.key}&display&redirect_uri=#{redirect_uri}" \
             '&response_type=code&scope=openid%20profile%20email&state',
      discord: 'https://discordapp.com/api/oauth2/authorize?' \
               "client_id=#{config.discord.key}&display&redirect_uri=#{redirect_uri}" \
               '&response_type=code&scope=identify&state',
      battlenet: 'https://eu.battle.net/oauth/authorize?' \
                 "client_id=#{config.battlenet.key}&display&redirect_uri=#{redirect_uri}" \
                 '&response_type=code&scope=openid&state'
    }

    urls[provider]
  end
end
