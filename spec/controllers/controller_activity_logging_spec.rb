# frozen_string_literal: true

require 'spec_helper'

describe SorceryController, type: :controller do
  before(:all) do
    MigrationHelper.migrate("#{Rails.root}/db/migrate/activity_logging")
  end

  after(:all) do
    MigrationHelper.rollback("#{Rails.root}/db/migrate/activity_logging")
    sorcery_controller_property_set(:register_login_time, true)
    sorcery_controller_property_set(:register_logout_time, true)
    sorcery_controller_property_set(:register_last_activity_time, true)
  end

  # ----------------- ACTIVITY LOGGING -----------------------
  context 'with activity logging features' do
    let!(:user) { User.create!(username: 'test_user', email: 'test@example.com', password: 'password') }

    before(:all) { sorcery_reload!([:activity_logging]) }

    before do
      sorcery_controller_property_set(:register_login_time, false)
      sorcery_controller_property_set(:register_last_ip_address, false)
      sorcery_controller_property_set(:register_last_activity_time, false)
    end

    it 'logs login time on login' do
      now = Time.now.in_time_zone
      Timecop.freeze(now) do
        sorcery_controller_property_set(:register_login_time, true)
        login_user(user)

        expect(user.reload.last_login_at).to be_within(0.1).of(now)
      end
    end

    it 'logs logout time on logout' do
      login_user(user)
      now = Time.now.in_time_zone
      Timecop.freeze(now) do
        logout_user

        expect(user.reload.last_logout_at).to be_within(0.1).of(now)
      end
    end

    it 'logs last activity time when logged in' do
      sorcery_controller_property_set(:register_last_activity_time, true)

      login_user(user)
      now = Time.now.in_time_zone
      Timecop.freeze(now) do
        get :some_action

        expect(user.reload.last_activity_at).to be_within(0.1).of(now)
      end
    end

    it 'logs last IP address when logged in' do
      sorcery_controller_property_set(:register_last_ip_address, true)

      login_user(user)

      expect(user.reload.last_login_from_ip_address).to eq('0.0.0.0')
    end

    it 'updates nothing but activity fields' do
      sorcery_controller_property_set(:register_last_activity_time, true)
      user = User.last
      original_email = user.email
      original_activity_at = user.last_activity_at
      login_user(user)
      get :some_action_making_a_non_persisted_change_to_the_user
      user.reload
      expect(user.email).to eq original_email
      expect(user.last_activity_at).not_to eq original_activity_at
    end

    it 'does not register login time if configured so' do
      sorcery_controller_property_set(:register_login_time, false)

      login_user(user)

      expect(user.reload.last_login_at).to be_nil
    end

    it 'does not register logout time if configured so' do
      sorcery_controller_property_set(:register_logout_time, false)
      login_user(user)

      logout_user

      expect(user.reload.last_logout_at).to be_nil
    end

    it 'does not register last activity time if configured so' do
      sorcery_controller_property_set(:register_last_activity_time, false)

      login_user(user)
      get :some_action

      expect(user.reload.last_activity_at).to be_nil
    end

    it 'does not register last IP address if configured so' do
      sorcery_controller_property_set(:register_last_ip_address, false)

      login_user(user)

      expect(user.reload.last_login_from_ip_address).to be_nil
    end
  end
end
