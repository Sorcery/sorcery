# frozen_string_literal: true

require 'spec_helper'

describe User, :active_record do
  context 'with brute_force_protection submodule' do
    before(:all) do
      MigrationHelper.migrate("#{Rails.root}/db/migrate/brute_force_protection")
      described_class.reset_column_information
    end

    after(:all) do
      MigrationHelper.rollback("#{Rails.root}/db/migrate/brute_force_protection")
    end

    let(:user) { create_new_user }

    before do
      User.sorcery_adapter.delete_all
    end

    context 'with loaded plugin configuration' do
      let(:config) { User.sorcery_config }

      before(:all) do
        sorcery_reload!([:brute_force_protection])
      end

      after do
        User.sorcery_config.reset!
      end

      specify { expect(user).to respond_to(:failed_logins_count) }
      specify { expect(user).to respond_to(:lock_expires_at) }

      it "enables configuration option 'failed_logins_count_attribute_name'" do
        sorcery_model_property_set(:failed_logins_count_attribute_name, :my_count)
        expect(config.failed_logins_count_attribute_name).to eq :my_count
      end

      it "enables configuration option 'lock_expires_at_attribute_name'" do
        sorcery_model_property_set(:lock_expires_at_attribute_name, :expires)
        expect(config.lock_expires_at_attribute_name).to eq :expires
      end

      it "enables configuration option 'consecutive_login_retries_amount_allowed'" do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 34)
        expect(config.consecutive_login_retries_amount_limit).to eq 34
      end

      it "enables configuration option 'login_lock_time_period'" do
        sorcery_model_property_set(:login_lock_time_period, 2.hours)
        expect(config.login_lock_time_period).to eq 2.hours
      end

      describe '#login_locked?' do
        it 'is locked' do
          user.send("#{config.lock_expires_at_attribute_name}=", Time.now + 5.days)
          expect(user).to be_login_locked
        end

        it "isn't locked" do
          user.send("#{config.lock_expires_at_attribute_name}=", nil)
          expect(user).not_to be_login_locked
        end
      end
    end

    describe '#register_failed_login!' do
      it 'locks user when number of retries reached the limit' do
        expect(user.lock_expires_at).to be_nil

        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 1)
        user.register_failed_login!
        lock_expires_at = User.sorcery_adapter.find_by_id(user.id).lock_expires_at

        expect(lock_expires_at).not_to be_nil
      end

      context 'when unlock_token_mailer_disabled is true' do
        it 'does not automatically send unlock email' do
          sorcery_model_property_set(:unlock_token_mailer_disabled, true)
          sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
          sorcery_model_property_set(:login_lock_time_period, 0)
          sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)

          3.times { user.register_failed_login! }

          expect(ActionMailer::Base.deliveries.size).to eq 0
        end
      end

      context 'when unlock_token_mailer_disabled is false' do
        before do
          sorcery_model_property_set(:unlock_token_mailer_disabled, false)
          sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
          sorcery_model_property_set(:login_lock_time_period, 0)
          sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
        end

        it 'does not automatically send unlock email' do
          3.times { user.register_failed_login! }

          expect(ActionMailer::Base.deliveries.size).to eq 1
        end

        it 'generates unlock token before mail is sent' do
          3.times { user.register_failed_login! }

          expect(ActionMailer::Base.deliveries.last.body.to_s.match(user.unlock_token)).not_to be_nil
        end
      end

      it 'does not increment counter when user is already locked' do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)

        2.times { user.register_failed_login! }

        expect(user.login_locked?).to be true

        user.register_failed_login!

        # Counter should not increment when already locked (stays at limit)
        expect(User.sorcery_adapter.find_by_id(user.id).failed_logins_count).to eq 2
      end

      it 'increments failed logins count when below threshold' do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 5)

        user.register_failed_login!
        reloaded_user = User.sorcery_adapter.find_by_id(user.id)

        expect(reloaded_user.failed_logins_count).to eq 1
        expect(reloaded_user.lock_expires_at).to be_nil
      end

      it 'does not lock when below the threshold' do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 5)

        3.times { user.register_failed_login! }
        reloaded_user = User.sorcery_adapter.find_by_id(user.id)

        expect(reloaded_user.failed_logins_count).to eq 3
        expect(reloaded_user.lock_expires_at).to be_nil
      end
    end

    describe '.authenticate' do
      it 'unlocks after lock time period passes' do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0.2)
        2.times { user.register_failed_login! }

        lock_expires_at = User.sorcery_adapter.find_by_id(user.id).lock_expires_at
        expect(lock_expires_at).not_to be_nil

        Timecop.travel(Time.now.in_time_zone + 0.3) do
          User.authenticate('bla@example.com', 'secret')

          lock_expires_at = User.sorcery_adapter.find_by_id(user.id).lock_expires_at
          expect(lock_expires_at).to be_nil
        end
      end

      it 'does not unlock if time period is 0 (permanent lock)' do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)

        2.times { user.register_failed_login! }

        unlock_date = user.lock_expires_at
        Timecop.travel(Time.now.in_time_zone + 1) do
          user.register_failed_login!

          expect(user.lock_expires_at.to_s).to eq unlock_date.to_s
        end
      end
    end

    describe '#login_unlock!' do
      it 'unlocks after entering unlock token' do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)
        sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
        3.times { user.register_failed_login! }

        expect(user.unlock_token).not_to be_nil

        token = user.unlock_token
        user = User.load_from_unlock_token(token)

        expect(user).not_to be_nil

        user.login_unlock!
        expect(User.load_from_unlock_token(user.unlock_token)).to be_nil
      end

      it 'resets failed_logins_count, clears lock_expires_at, and clears unlock_token' do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)
        3.times { user.register_failed_login! }

        user.login_unlock!
        reloaded_user = User.sorcery_adapter.find_by_id(user.id)

        expect(reloaded_user.failed_logins_count).to eq 0
        expect(reloaded_user.lock_expires_at).to be_nil
        expect(reloaded_user.unlock_token).to be_nil
      end
    end

    describe '#login_locked?' do
      it 'returns true when user is locked' do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 60)

        2.times { user.register_failed_login! }

        expect(user.login_locked?).to be true
      end

      it 'returns false when user is not locked' do
        expect(user.login_locked?).to be false
      end
    end

    describe '.load_from_unlock_token' do
      before do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)
        sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      end

      it 'returns user when token is found' do
        3.times { user.register_failed_login! }

        found_user = User.load_from_unlock_token(user.unlock_token)

        expect(found_user).to eq user
      end

      it 'returns nil when token is not found' do
        expect(User.load_from_unlock_token('nonexistent_token')).to be_nil
      end

      it 'returns nil when token is blank' do
        expect(User.load_from_unlock_token(nil)).to be_nil
        expect(User.load_from_unlock_token('')).to be_nil
      end
    end

    describe 'configuration' do
      before(:all) do
        sorcery_reload!([:brute_force_protection])
      end

      after do
        User.sorcery_config.reset!
      end

      it "allows configuration option 'unlock_token_attribute_name'" do
        sorcery_model_property_set(:unlock_token_attribute_name, :my_unlock_token)

        expect(User.sorcery_config.unlock_token_attribute_name).to eq :my_unlock_token
      end

      it "allows configuration option 'unlock_token_email_method_name'" do
        sorcery_model_property_set(:unlock_token_email_method_name, :my_unlock_email)

        expect(User.sorcery_config.unlock_token_email_method_name).to eq :my_unlock_email
      end

      it "allows configuration option 'unlock_token_mailer'" do
        sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)

        expect(User.sorcery_config.unlock_token_mailer).to eq SorceryMailer
      end

      it "allows configuration option 'unlock_token_mailer_disabled'" do
        sorcery_model_property_set(:unlock_token_mailer_disabled, true)

        expect(User.sorcery_config.unlock_token_mailer_disabled).to be true
      end
    end

    describe '#send_unlock_token_email!' do
      it 'does not send email when unlock_token_email_method_name is nil' do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)
        sorcery_model_property_set(:unlock_token_mailer_disabled, false)
        sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
        sorcery_model_property_set(:unlock_token_email_method_name, nil)

        old_size = ActionMailer::Base.deliveries.size
        3.times { user.register_failed_login! }

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end
    end

    describe '.authenticate with locked user' do
      it 'returns locked failure when user is permanently locked' do
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)

        2.times { user.register_failed_login! }

        User.authenticate(user.email, 'secret') do |_user, failure|
          expect(failure).to eq :locked
        end
      end
    end
  end
end
