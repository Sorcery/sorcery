# frozen_string_literal: true

require 'spec_helper'

describe User, :active_record do
  context 'with magic_login submodule' do
    before(:all) do
      MigrationHelper.migrate("#{Rails.root}/db/migrate/magic_login")
      described_class.reset_column_information
    end

    after(:all) do
      MigrationHelper.rollback("#{Rails.root}/db/migrate/magic_login")
    end

    let(:user) { create_new_user }

    before do
      User.sorcery_adapter.delete_all
    end

    context 'with loaded plugin configuration' do
      let(:config) { User.sorcery_config }

      before(:all) do
        sorcery_reload!([:magic_login])
      end

      after do
        User.sorcery_config.reset!
      end

      describe 'enables configuration options' do
        it do
          sorcery_model_property_set(:magic_login_token_attribute_name, :test_magic_login_token)
          expect(config.magic_login_token_attribute_name).to eq :test_magic_login_token
        end

        it do
          sorcery_model_property_set(:magic_login_token_expires_at_attribute_name, :test_magic_login_token_expires_at)
          expect(config.magic_login_token_expires_at_attribute_name).to eq :test_magic_login_token_expires_at
        end

        it do
          sorcery_model_property_set(:magic_login_email_sent_at_attribute_name, :test_magic_login_email_sent_at)
          expect(config.magic_login_email_sent_at_attribute_name).to eq :test_magic_login_email_sent_at
        end

        it do
          test_mailer_class = Class.new # need a mailer class to test
          sorcery_model_property_set(:magic_login_mailer_class, test_mailer_class)
          expect(config.magic_login_mailer_class).to eq test_mailer_class
        end

        it do
          sorcery_model_property_set(:magic_login_mailer_disabled, false)
          expect(config.magic_login_mailer_disabled).to be false
        end

        it do
          sorcery_model_property_set(:magic_login_email_method_name, :test_magic_login_email)
          expect(config.magic_login_email_method_name).to eq :test_magic_login_email
        end

        it do
          sorcery_model_property_set(:magic_login_expiration_period, 100_000_000)
          expect(config.magic_login_expiration_period).to eq 100_000_000
        end

        it do
          sorcery_model_property_set(:magic_login_time_between_emails, 100_000_000)
          expect(config.magic_login_time_between_emails).to eq 100_000_000
        end
      end

      describe '#generate_magic_login_token!' do
        context 'when magic_login_token is nil' do
          it "magic_login_token_expires_at and magic_login_email_sent_at aren't nil" do
            user.generate_magic_login_token!
            expect(user.magic_login_token_expires_at).not_to be_nil
            expect(user.magic_login_email_sent_at).not_to be_nil
          end

          it 'magic_login_token is different from the one before' do
            token_before = user.magic_login_token
            user.generate_magic_login_token!
            expect(user.magic_login_token).not_to eq token_before
          end
        end

        context 'when magic_login_token is not nil' do
          it 'changes `user.magic_login_token`' do
            token_before = user.magic_login_token
            user.generate_magic_login_token!
            expect(user.magic_login_token).not_to eq token_before
          end
        end
      end

      describe '#deliver_magic_login_instructions!' do
        context 'when successful' do
          before do
            sorcery_model_property_set(:magic_login_time_between_emails, 30 * 60)
            sorcery_model_property_set(:magic_login_mailer_disabled, false)
            Timecop.travel(10.days.ago) do
              user.send(:"#{config.magic_login_email_sent_at_attribute_name}=", DateTime.now)
            end
            sorcery_model_property_set(:magic_login_mailer_class, SorceryMailer)
          end

          it do
            user.deliver_magic_login_instructions!
            expect(ActionMailer::Base.deliveries.size).to eq 1
          end

          it do
            expect(user.deliver_magic_login_instructions!).to be true
          end
        end

        context 'when failing' do
          context 'when magic_login_time_between_emails is nil' do
            it 'returns false' do
              sorcery_model_property_set(:magic_login_time_between_emails, nil)
              expect(user.deliver_magic_login_instructions!).to be false
            end
          end

          context 'when magic_login_email_sent_at is nil' do
            it 'returns false' do
              user.send(:"#{config.magic_login_email_sent_at_attribute_name}=", nil)
              expect(user.deliver_magic_login_instructions!).to be false
            end
          end

          context 'when now is before magic_login_email_sent_at plus the interval' do
            it 'returns false' do
              user.send(:"#{config.magic_login_email_sent_at_attribute_name}=", DateTime.now)
              sorcery_model_property_set(:magic_login_time_between_emails, 30 * 60)
              expect(user.deliver_magic_login_instructions!).to be false
            end
          end

          context 'when magic_login_mailer_disabled is true' do
            it 'returns false' do
              sorcery_model_property_set(:magic_login_mailer_disabled, true)
              expect(user.deliver_magic_login_instructions!).to be false
            end
          end
        end
      end

      describe '#clear_magic_login_token!' do
        it 'makes magic_login_token_attribute_name and magic_login_token_expires_at_attribute_name nil' do
          user.magic_login_token = 'test_token'
          user.magic_login_token_expires_at = Time.now

          user.clear_magic_login_token!

          expect(user.magic_login_token).to be_nil
          expect(user.magic_login_token_expires_at).to be_nil
        end
      end

      describe '.load_from_magic_login_token' do
        before { user.generate_magic_login_token! }

        it 'returns user when token is found' do
          found_user = User.sorcery_adapter.find(user.id)

          expect(User.load_from_magic_login_token(user.magic_login_token)).to eq found_user
        end

        it 'does NOT return user when token is NOT found' do
          expect(User.load_from_magic_login_token('a')).to be_nil
        end

        it 'returns user when token is found and not expired' do
          sorcery_model_property_set(:magic_login_expiration_period, 500)
          user.generate_magic_login_token!
          found_user = User.sorcery_adapter.find(user.id)

          expect(User.load_from_magic_login_token(user.magic_login_token)).to eq found_user
        end

        it 'does NOT return user when token is found and expired' do
          sorcery_model_property_set(:magic_login_expiration_period, 0.1)
          user.generate_magic_login_token!

          Timecop.travel(Time.now.in_time_zone + 0.5) do
            expect(User.load_from_magic_login_token(user.magic_login_token)).to be_nil
          end
        end

        it 'is always valid if expiration period is nil' do
          sorcery_model_property_set(:magic_login_expiration_period, nil)
          user.generate_magic_login_token!
          found_user = User.sorcery_adapter.find(user.id)

          expect(User.load_from_magic_login_token(user.magic_login_token)).to eq found_user
        end

        it 'returns nil if token is blank' do
          expect(User.load_from_magic_login_token(nil)).to be_nil
          expect(User.load_from_magic_login_token('')).to be_nil
        end

        context 'when in block mode' do
          it 'yields user when token is found' do
            found_user = User.sorcery_adapter.find(user.id)

            User.load_from_magic_login_token(user.magic_login_token) do |loaded_user, failure|
              expect(loaded_user).to eq found_user
              expect(failure).to be_nil
            end
          end

          it 'does NOT yield user when token is NOT found' do
            User.load_from_magic_login_token('a') do |loaded_user, failure|
              expect(loaded_user).to be_nil
              expect(failure).to eq :user_not_found
            end
          end

          it 'yields user and failure reason when token is found and expired' do
            sorcery_model_property_set(:magic_login_expiration_period, 0.1)
            user.generate_magic_login_token!

            Timecop.travel(Time.now.in_time_zone + 0.5) do
              User.load_from_magic_login_token(user.magic_login_token) do |loaded_user, failure|
                expect(loaded_user).to eq user
                expect(failure).to eq :token_expired
              end
            end
          end

          it 'yields a failure reason if token is blank' do
            [nil, ''].each do |token|
              User.load_from_magic_login_token(token) do |loaded_user, failure|
                expect(loaded_user).to be_nil
                expect(failure).to eq :invalid_token
              end
            end
          end
        end
      end
    end
  end
end
