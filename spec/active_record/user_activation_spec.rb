# frozen_string_literal: true

require 'spec_helper'

require 'rails_app/app/mailers/sorcery_mailer'

describe User, :active_record do
  context 'with activation submodule' do
    before(:all) do
      MigrationHelper.migrate("#{Rails.root}/db/migrate/activation")
      described_class.reset_column_information
    end

    after(:all) do
      MigrationHelper.rollback("#{Rails.root}/db/migrate/activation")
    end

    let(:user) { create_new_user }
    let(:new_user) { build_new_user }

    context 'with loaded plugin configuration' do
      before(:all) do
        sorcery_reload!([:user_activation], user_activation_mailer: SorceryMailer)
      end

      after do
        User.sorcery_config.reset!
        sorcery_reload!([:user_activation], user_activation_mailer: SorceryMailer)
      end

      it "enables configuration option 'activation_state_attribute_name'" do
        sorcery_model_property_set(:activation_state_attribute_name, :status)

        expect(User.sorcery_config.activation_state_attribute_name).to eq :status
      end

      it "enables configuration option 'activation_token_attribute_name'" do
        sorcery_model_property_set(:activation_token_attribute_name, :code)

        expect(User.sorcery_config.activation_token_attribute_name).to be :code
      end

      it "enables configuration option 'user_activation_mailer'" do
        sorcery_model_property_set(:user_activation_mailer, TestMailer)

        expect(User.sorcery_config.user_activation_mailer).to equal(TestMailer)
      end

      it "enables configuration option 'activation_needed_email_method_name'" do
        sorcery_model_property_set(:activation_needed_email_method_name, :my_activation_email)

        expect(User.sorcery_config.activation_needed_email_method_name).to eq :my_activation_email
      end

      it "enables configuration option 'activation_success_email_method_name'" do
        sorcery_model_property_set(:activation_success_email_method_name, :my_activation_email)

        expect(User.sorcery_config.activation_success_email_method_name).to eq :my_activation_email
      end

      it "enables configuration option 'activation_mailer_disabled'" do
        sorcery_model_property_set(:activation_mailer_disabled, :my_activation_mailer_disabled)

        expect(User.sorcery_config.activation_mailer_disabled).to eq :my_activation_mailer_disabled
      end

      it 'if mailer is nil and mailer is enabled, throw exception!' do
        expect { sorcery_reload!([:user_activation], activation_mailer_disabled: false) }.to raise_error(ArgumentError)
      end

      it 'if mailer is disabled and mailer is nil, do NOT throw exception' do
        expect { sorcery_reload!([:user_activation], activation_mailer_disabled: true) }.not_to raise_error
      end
    end

    context 'when activating' do
      before(:all) do
        sorcery_reload!([:user_activation], user_activation_mailer: SorceryMailer)
      end

      it "initializes user state to 'pending'" do
        expect(user.activation_state).to eq 'pending'
      end

      specify { expect(user).to respond_to :activate! }

      it "clears activation code and change state to 'active' on activation" do
        activation_token = user.activation_token
        user.activate!
        user2 = User.sorcery_adapter.find(user.id)

        expect(user2.activation_token).to be_nil
        expect(user2.activation_state).to eq 'active'
        expect(User.sorcery_adapter.find_by_activation_token(activation_token)).to be_nil
      end

      context 'when mailer is enabled' do
        it 'sends the user an activation email' do
          old_size = ActionMailer::Base.deliveries.size
          create_new_user

          expect(ActionMailer::Base.deliveries.size).to eq old_size + 1
        end

        it 'calls send_activation_needed_email! method of user' do
          expect(new_user).to receive(:send_activation_needed_email!).once

          new_user.sorcery_adapter.save(raise_on_failure: true)
        end

        it 'subsequent saves do not send activation email' do
          user
          old_size = ActionMailer::Base.deliveries.size
          user.email = 'Shauli'
          user.sorcery_adapter.save(raise_on_failure: true)

          expect(ActionMailer::Base.deliveries.size).to eq old_size
        end

        it 'sends the user an activation success email on successful activation' do
          user
          old_size = ActionMailer::Base.deliveries.size
          user.activate!

          expect(ActionMailer::Base.deliveries.size).to eq old_size + 1
        end

        it 'calls send_activation_success_email! method of user on activation' do
          expect(user).to receive(:send_activation_success_email!).once

          user.activate!
        end

        it 'subsequent saves do not send activation success email' do
          user.activate!
          old_size = ActionMailer::Base.deliveries.size
          user.email = 'Shauli'
          user.sorcery_adapter.save(raise_on_failure: true)

          expect(ActionMailer::Base.deliveries.size).to eq old_size
        end

        it 'activation needed email is optional' do
          sorcery_model_property_set(:activation_needed_email_method_name, nil)
          old_size = ActionMailer::Base.deliveries.size

          expect(ActionMailer::Base.deliveries.size).to eq old_size
        end

        it 'activation success email is optional' do
          sorcery_model_property_set(:activation_success_email_method_name, nil)
          old_size = ActionMailer::Base.deliveries.size
          user.activate!

          expect(ActionMailer::Base.deliveries.size).to eq old_size
        end

        context 'when activation_needed_email is skipped' do
          before do
            @user = build_new_user
            @user.skip_activation_needed_email = true
          end

          it 'does not send the user an activation email' do
            old_size = ActionMailer::Base.deliveries.size

            @user.sorcery_adapter.save(raise_on_failure: true)

            expect(ActionMailer::Base.deliveries.size).to eq old_size
          end

          it 'does not call send_activation_needed_email! method of user' do
            expect(@user).not_to receive(:send_activation_needed_email!)

            @user.sorcery_adapter.save(raise_on_failure: true)
          end

          it 'calls send_activation_success_email! method of user on activation' do
            expect(@user).not_to receive(:send_activation_success_email!)

            @user.activate!
          end
        end

        context 'when activation_success_email is skipped' do
          before do
            @user = build_new_user
            @user.skip_activation_success_email = true
          end

          it 'does not send the user an activation success email on successful activation' do
            old_size = ActionMailer::Base.deliveries.size

            @user.activate!

            expect(ActionMailer::Base.deliveries.size).to eq old_size
          end
        end
      end

      context 'when mailer has been disabled' do
        before do
          sorcery_reload!([:user_activation], activation_mailer_disabled: true, user_activation_mailer: SorceryMailer)
        end

        it 'does not send the user an activation email' do
          old_size = ActionMailer::Base.deliveries.size
          create_new_user

          expect(ActionMailer::Base.deliveries.size).to eq old_size
        end

        it 'does not call send_activation_needed_email! method of user' do
          user = build_new_user

          expect(user).not_to receive(:send_activation_needed_email!)

          user.sorcery_adapter.save(raise_on_failure: true)
        end

        it 'does not send the user an activation success email on successful activation' do
          old_size = ActionMailer::Base.deliveries.size
          user.activate!

          expect(ActionMailer::Base.deliveries.size).to eq old_size
        end

        it 'calls send_activation_success_email! method of user on activation' do
          expect(user).not_to receive(:send_activation_success_email!)

          user.activate!
        end
      end
    end

    describe 'prevent non-active login feature' do
      before(:all) do
        sorcery_reload!([:user_activation], user_activation_mailer: SorceryMailer)
      end

      before do
        User.sorcery_adapter.delete_all
      end

      it 'does not allow a non-active user to authenticate' do
        expect(User.authenticate(user.email, 'secret')).to be_falsy
      end

      it 'allows a non-active user to authenticate if configured so' do
        sorcery_model_property_set(:prevent_non_active_users_to_login, false)

        expect(User.authenticate(user.email, 'secret')).to be_truthy
      end

      context 'when in block mode' do
        it 'does not allow a non-active user to authenticate' do
          sorcery_model_property_set(:prevent_non_active_users_to_login, true)

          User.authenticate(user.email, 'secret') do |user2, failure|
            expect(user2).to eq user
            expect(user2.activation_state).to eq 'pending'
            expect(failure).to eq :inactive
          end
        end

        it 'allows a non-active user to authenticate if configured so' do
          sorcery_model_property_set(:prevent_non_active_users_to_login, false)

          User.authenticate(user.email, 'secret') do |user2, failure|
            expect(user2).to eq user
            expect(failure).to be_nil
          end
        end
      end
    end

    describe 'load_from_activation_token' do
      before(:all) do
        sorcery_reload!([:user_activation], user_activation_mailer: SorceryMailer)
      end

      it 'load_from_activation_token returns user when token is found' do
        expect(User.load_from_activation_token(user.activation_token)).to eq user
      end

      it 'load_from_activation_token does NOT return user when token is NOT found' do
        expect(User.load_from_activation_token('a')).to be_nil
      end

      it 'load_from_activation_token returas user when token is found and not expired' do
        sorcery_model_property_set(:activation_token_expiration_period, 500)

        expect(User.load_from_activation_token(user.activation_token)).to eq user
      end

      it 'load_from_activation_token does NOT return user when token is found and expired' do
        sorcery_model_property_set(:activation_token_expiration_period, 0.1)
        user

        Timecop.travel(Time.now.in_time_zone + 0.5) do
          expect(User.load_from_activation_token(user.activation_token)).to be_nil
        end
      end

      it 'load_from_activation_token returns nil if token is blank' do
        expect(User.load_from_activation_token(nil)).to be_nil
        expect(User.load_from_activation_token('')).to be_nil
      end

      it 'load_from_activation_token is always valid if expiration period is nil' do
        sorcery_model_property_set(:activation_token_expiration_period, nil)

        expect(User.load_from_activation_token(user.activation_token)).to eq user
      end

      describe '#load_from_activation_token' do
        context 'when in block mode' do
          it 'yields user when token is found' do
            User.load_from_activation_token(user.activation_token) do |user2, failure|
              expect(user2).to eq user
              expect(failure).to be_nil
            end
          end

          it 'does NOT yield user when token is NOT found' do
            User.load_from_activation_token('a') do |user2, failure|
              expect(user2).to be_nil
              expect(failure).to eq :user_not_found
            end
          end

          it 'yields user when token is found and not expired' do
            sorcery_model_property_set(:activation_token_expiration_period, 500)

            User.load_from_activation_token(user.activation_token) do |user2, failure|
              expect(user2).to eq user
              expect(failure).to be_nil
            end
          end

          it 'yields the user and failure reason when token is found and expired' do
            sorcery_model_property_set(:activation_token_expiration_period, 0.1)
            user

            Timecop.travel(Time.now.in_time_zone + 0.5) do
              User.load_from_activation_token(user.activation_token) do |user2, failure|
                expect(user2).to eq user
                expect(failure).to eq :token_expired
              end
            end
          end

          it 'yields a failure reason if token is blank' do
            [nil, ''].each do |token|
              User.load_from_activation_token(token) do |user2, failure|
                expect(user2).to be_nil
                expect(failure).to eq :invalid_token
              end
            end
          end

          it 'is always valid if expiration period is nil' do
            sorcery_model_property_set(:activation_token_expiration_period, nil)

            User.load_from_activation_token(user.activation_token) do |user2, failure|
              expect(user2).to eq user
              expect(failure).to be_nil
            end
          end
        end
      end
    end
  end
end
