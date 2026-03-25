# frozen_string_literal: true

require 'spec_helper'

describe User, :active_record do
  context 'with activity logging submodule' do
    before(:all) do
      MigrationHelper.migrate("#{Rails.root}/db/migrate/activity_logging")
      described_class.reset_column_information
    end

    after(:all) do
      MigrationHelper.rollback("#{Rails.root}/db/migrate/activity_logging")
    end

    context 'with loaded plugin configuration' do
      before(:all) do
        sorcery_reload!([:activity_logging])
      end

      after do
        User.sorcery_config.reset!
      end

      it "allows configuration option 'last_login_at_attribute_name'" do
        sorcery_model_property_set(:last_login_at_attribute_name, :login_time)

        expect(User.sorcery_config.last_login_at_attribute_name).to eq :login_time
      end

      it "allows configuration option 'last_logout_at_attribute_name'" do
        sorcery_model_property_set(:last_logout_at_attribute_name, :logout_time)
        expect(User.sorcery_config.last_logout_at_attribute_name).to eq :logout_time
      end

      it "allows configuration option 'last_activity_at_attribute_name'" do
        sorcery_model_property_set(:last_activity_at_attribute_name, :activity_time)
        expect(User.sorcery_config.last_activity_at_attribute_name).to eq :activity_time
      end

      it "allows configuration option 'last_login_from_ip_adress'" do
        sorcery_model_property_set(:last_login_from_ip_address_name, :ip_address)
        expect(User.sorcery_config.last_login_from_ip_address_name).to eq :ip_address
      end

      it 'updates last_login_at via set_last_login_at' do
        user = create_new_user
        now = Time.now.in_time_zone
        expect(user.sorcery_adapter).to receive(:update_attribute).with(:last_login_at, now)

        user.set_last_login_at(now)
      end

      it 'updates last_logout_at via set_last_logout_at' do
        user = create_new_user
        now = Time.now.in_time_zone
        expect(user.sorcery_adapter).to receive(:update_attribute).with(:last_logout_at, now)

        user.set_last_logout_at(now)
      end

      it 'updates last_activity_at via set_last_activity_at' do
        user = create_new_user
        now = Time.now.in_time_zone
        expect(user.sorcery_adapter).to receive(:update_attribute).with(:last_activity_at, now)

        user.set_last_activity_at(now)
      end

      it 'updates last_login_from_ip_address via set_last_ip_address' do
        user = create_new_user
        expect(user.sorcery_adapter).to receive(:update_attribute).with(:last_login_from_ip_address, '0.0.0.0')

        user.set_last_ip_address('0.0.0.0')
      end

      it 'shows if user is logged in' do
        user = create_new_user
        expect(user.logged_in?).to be(false)

        now = Time.now.in_time_zone
        user.set_last_login_at(now)
        expect(user.logged_in?).to be(true)

        now = Time.now.in_time_zone
        user.set_last_logout_at(now)
        expect(user.logged_in?).to be(false)
      end

      it 'shows if user is logged out' do
        user = create_new_user
        expect(user.logged_out?).to be(true)

        now = Time.now.in_time_zone
        user.set_last_login_at(now)
        expect(user.logged_out?).to be(false)

        now = Time.now.in_time_zone
        user.set_last_logout_at(now)
        expect(user.logged_out?).to be(true)
      end

      it 'shows online status of user' do
        user = create_new_user
        expect(user.online?).to be(false)

        now = Time.now.in_time_zone
        user.set_last_login_at(now)
        user.set_last_activity_at(now)
        expect(user.online?).to be(true)

        user.set_last_activity_at(now - 1.day)
        expect(user.online?).to be(false)

        now = Time.now.in_time_zone
        user.set_last_logout_at(now)
        expect(user.online?).to be(false)
      end

      it "allows configuration option 'activity_timeout'" do
        sorcery_model_property_set(:activity_timeout, 30 * 60)
        expect(User.sorcery_config.activity_timeout).to eq 30 * 60
      end

      it 'returns false for online when last_activity_at is nil' do
        user = create_new_user
        expect(user.online?).to be(false)
      end

      it 'returns false for online when user is logged out even with recent activity' do
        user = create_new_user
        now = Time.now.in_time_zone
        user.set_last_login_at(now)
        user.set_last_activity_at(now)
        user.set_last_logout_at(now + 1.second)

        expect(user.online?).to be(false)
      end

      it 'returns false for logged in when last_login_at is nil' do
        user = create_new_user

        expect(user.logged_in?).to be(false)
      end

      it 'returns true for logged in when logged in but never logged out' do
        user = create_new_user
        user.set_last_login_at(Time.now.in_time_zone)

        expect(user.logged_in?).to be(true)
      end

      it 'returns true for logged out when never logged in' do
        user = create_new_user

        expect(user.logged_out?).to be(true)
      end

      it 'reports logged out as inverse of logged in' do
        user = create_new_user
        now = Time.now.in_time_zone
        user.set_last_login_at(now)

        expect(user.logged_in?).to be(true)
        expect(user.logged_out?).to be(false)
      end
    end
  end
end
