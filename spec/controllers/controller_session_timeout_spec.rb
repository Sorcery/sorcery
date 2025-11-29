require 'spec_helper'

describe SorceryController, type: :controller do
  let!(:user) { User.create!(username: 'test_user', email: 'test@example.com', password: 'password') }

  # ----------------- SESSION TIMEOUT -----------------------
  context 'with session timeout features' do
    before(:all) do
      sorcery_reload!([:session_timeout])
      sorcery_controller_property_set(:session_timeout, 0.5)
    end

    after do
      Timecop.return
    end

    it 'does not reset session before session timeout' do
      login_user user
      get :test_should_be_logged_in

      expect(session[:user_id]).not_to be_nil
      expect(response).to be_successful
    end

    it 'resets session after session timeout' do
      login_user user
      Timecop.travel(Time.now.in_time_zone + 0.6)
      get :test_should_be_logged_in

      expect(session[:user_id]).to be_nil
      expect(response).to be_a_redirect
    end

    context "with 'invalidate_active_sessions_enabled'" do
      it 'does not reset the session if invalidate_sessions_before is nil' do
        sorcery_controller_property_set(:session_timeout_invalidate_active_sessions_enabled, true)
        login_user user
        allow(user).to receive(:invalidate_sessions_before).and_return(nil)

        get :test_should_be_logged_in

        expect(session[:user_id]).not_to be_nil
        expect(response).to be_successful
      end

      it 'does not reset the session if it was not created before invalidate_sessions_before' do
        sorcery_controller_property_set(:session_timeout_invalidate_active_sessions_enabled, true)
        login_user user
        allow(user).to receive(:invalidate_sessions_before) { Time.now.in_time_zone - 10.minutes }

        get :test_should_be_logged_in

        expect(session[:user_id]).not_to be_nil
        expect(response).to be_successful
      end

      it 'resets the session if the session was created before invalidate_sessions_before' do
        sorcery_controller_property_set(:session_timeout_invalidate_active_sessions_enabled, true)
        login_user user
        allow(user).to receive(:invalidate_sessions_before) { Time.now.in_time_zone }
        get :test_should_be_logged_in

        expect(session[:user_id]).to be_nil
        expect(response).to be_a_redirect
      end

      it 'resets active sessions on next action if invalidate_active_sessions! is called' do
        sorcery_controller_property_set(:session_timeout_invalidate_active_sessions_enabled, true)
        # precondition that the user is logged in
        login_user user
        get :test_should_be_logged_in
        expect(response).to be_successful

        allow(user).to receive(:send) { |_method, value| allow(user).to receive(:invalidate_sessions_before) { value } }
        allow(user).to receive(:save)
        get :test_invalidate_active_session
        expect(response).to be_successful

        get :test_should_be_logged_in
        expect(session[:user_id]).to be_nil
        expect(response).to be_a_redirect
      end

      it 'allows login after invalidate_active_sessions! is called' do
        sorcery_controller_property_set(:session_timeout_invalidate_active_sessions_enabled, true)
        # precondition that the user is logged in
        login_user user
        get :test_should_be_logged_in
        expect(response).to be_successful

        allow(user).to receive(:send) { |_method, value| allow(user).to receive(:invalidate_sessions_before) { value } }
        allow(user).to receive(:save)
        # Call to invalidate
        get :test_invalidate_active_session
        expect(response).to be_successful

        # Check that existing sessions were logged out
        get :test_should_be_logged_in
        expect(session[:user_id]).to be_nil
        expect(response).to be_a_redirect

        # Check that new session is allowed to login
        login_user user
        get :test_should_be_logged_in
        expect(response).to be_successful
        expect(session[:user_id]).not_to be_nil

        # Check an additional request to make sure not logged out on next request
        get :test_should_be_logged_in
        expect(response).to be_successful
        expect(session[:user_id]).not_to be_nil
      end
    end

    it 'works if the session is stored as a string or a Time' do
      session[:login_time] = Time.now.to_s
      # TODO: ???
      expect(User).to receive(:authenticate).with('bla@example.com', 'secret').and_yield(user, nil)

      get :test_login, params: { email: 'bla@example.com', password: 'secret' }

      expect(session[:user_id]).not_to be_nil
      expect(response).to be_successful
    end

    context "with 'session_timeout_from_last_action'" do
      before { create_new_user }

      it 'does not logout if there was activity' do
        sorcery_controller_property_set(:session_timeout_from_last_action, true)

        get :test_login, params: { email: 'bla@example.com', password: 'secret' }
        Timecop.travel(Time.now.in_time_zone + 0.3)
        get :test_should_be_logged_in

        expect(session[:user_id]).not_to be_nil

        Timecop.travel(Time.now.in_time_zone + 0.3)
        get :test_should_be_logged_in

        expect(session[:user_id]).not_to be_nil
        expect(response).to be_successful
      end

      it "with 'session_timeout_from_last_action' logs out if there was no activity" do
        sorcery_controller_property_set(:session_timeout_from_last_action, true)
        get :test_login, params: { email: 'bla@example.com', password: 'secret' }
        Timecop.travel(Time.now.in_time_zone + 0.6)
        get :test_should_be_logged_in

        expect(session[:user_id]).to be_nil
        expect(response).to be_a_redirect
      end
    end

    it 'registers login time on remember_me callback' do
      subject.send(:after_remember_me!, user)

      expect(session[:login_time]).not_to be_nil
      expect(session[:last_action_time]).not_to be_nil
    end
  end
end
