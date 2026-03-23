# frozen_string_literal: true

require 'spec_helper'

describe User, :active_record do
  context 'with oauth submodule' do
    before(:all) do
      MigrationHelper.migrate("#{Rails.root}/db/migrate/external")
      described_class.reset_column_information
    end

    after(:all) do
      MigrationHelper.rollback("#{Rails.root}/db/migrate/external")
    end

    # ----------------- PLUGIN CONFIGURATION -----------------------

    let(:external_user) { create_new_external_user :twitter }

    describe 'loaded plugin configuration' do
      before(:all) do
        Authentication.sorcery_adapter.delete_all
        User.sorcery_adapter.delete_all

        sorcery_reload!([:external])
        sorcery_controller_property_set(:external_providers, [:twitter])
        sorcery_model_property_set(:authentications_class, Authentication)
        sorcery_controller_external_property_set(:twitter, :key, 'eYVNBjBDi33aa9GkA3w')
        sorcery_controller_external_property_set(:twitter, :secret, 'XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8')
        sorcery_controller_external_property_set(:twitter, :callback_url, 'http://example.com')
      end

      it "responds to 'load_from_provider'" do
        expect(User).to respond_to(:load_from_provider)
      end

      it "'load_from_provider' loads user if exists" do
        external_user
        expect(User.load_from_provider(:twitter, 123)).to eq external_user
      end

      it "'load_from_provider' returns nil if user doesn't exist" do
        external_user
        expect(User.load_from_provider(:twitter, 980_342)).to be_nil
      end

      it "'load_from_provider' returns nil when no authentication record exists" do
        expect(User.load_from_provider(:twitter, 999_999)).to be_nil
      end
    end

    describe '.create_and_validate_from_provider' do
      before(:all) do
        sorcery_reload!([:external])
        sorcery_model_property_set(:authentications_class, Authentication)
      end

      before do
        User.sorcery_adapter.delete_all
        Authentication.sorcery_adapter.delete_all
      end

      it 'creates a new user with the given attributes' do
        user, saved = User.create_and_validate_from_provider(:twitter, '456', username: 'oauth_user', email: 'oauth@example.com')

        expect(saved).to be true
        expect(user).to be_persisted
        expect(user.username).to eq 'oauth_user'
        expect(user.email).to eq 'oauth@example.com'
      end

      it 'builds the associated authentication record' do
        user, saved = User.create_and_validate_from_provider(:twitter, '456', username: 'oauth_user', email: 'oauth@example.com')

        expect(saved).to be true
        expect(user.authentications.count).to eq 1
        expect(user.authentications.first.provider).to eq 'twitter'
        expect(user.authentications.first.uid).to eq '456'
      end

      it 'returns false for saved when validation fails' do
        User.class_eval do
          validates :email, presence: true
        end

        user, saved = User.create_and_validate_from_provider(:twitter, '789', username: 'no_email_user')

        expect(saved).to be false
        expect(user).not_to be_persisted
      ensure
        # Remove the validation we added
        User.clear_validators!
      end

      it 'returns the user object even when save fails' do
        User.class_eval do
          validates :email, presence: true
        end

        user, _saved = User.create_and_validate_from_provider(:twitter, '789', username: 'no_email_user')

        expect(user).to be_a User
        expect(user.username).to eq 'no_email_user'
      ensure
        User.clear_validators!
      end
    end

    describe '.build_from_provider' do
      before(:all) do
        sorcery_reload!([:external])
        sorcery_model_property_set(:authentications_class, Authentication)
      end

      before do
        User.sorcery_adapter.delete_all
      end

      it 'builds a new user with the given attributes without saving' do
        user = User.build_from_provider(username: 'built_user', email: 'built@example.com')

        expect(user).to be_a User
        expect(user.username).to eq 'built_user'
        expect(user.email).to eq 'built@example.com'
        expect(user).not_to be_persisted
      end

      it 'returns the user when no block is given' do
        user = User.build_from_provider(username: 'built_user', email: 'built@example.com')

        expect(user).to be_a User
      end

      it 'returns the user when block yields true' do
        user = User.build_from_provider(username: 'built_user', email: 'built@example.com') { true }

        expect(user).to be_a User
        expect(user.username).to eq 'built_user'
      end

      it 'returns false when block yields false' do
        result = User.build_from_provider(username: 'built_user', email: 'built@example.com') { false }

        expect(result).to be false
      end

      it 'yields the user to the block for inspection' do
        yielded_user = nil
        User.build_from_provider(username: 'inspected_user', email: 'inspect@example.com') do |u|
          yielded_user = u
          true
        end

        expect(yielded_user).to be_a User
        expect(yielded_user.username).to eq 'inspected_user'
      end
    end

    describe '#add_provider_to_user' do
      before(:all) do
        sorcery_reload!([:external])
        sorcery_model_property_set(:authentications_class, Authentication)
      end

      before do
        User.sorcery_adapter.delete_all
        Authentication.sorcery_adapter.delete_all
      end

      it 'adds a new provider to the user' do
        user = create_new_user
        result = user.add_provider_to_user(:facebook, '12345')

        expect(result).to be_truthy
        expect(result).not_to be false
        expect(user.authentications.count).to eq 1
        expect(user.authentications.first.provider).to eq 'facebook'
        expect(user.authentications.first.uid).to eq '12345'
      end

      it 'returns false if the user already has the same provider and uid' do
        user = create_new_user
        user.add_provider_to_user(:facebook, '12345')

        result = user.add_provider_to_user(:facebook, '12345')

        expect(result).to be false
      end

      it 'allows adding different providers to the same user' do
        user = create_new_user
        user.add_provider_to_user(:facebook, '12345')
        result = user.add_provider_to_user(:twitter, '67890')

        expect(result).to be_truthy
        expect(result).not_to be false
        expect(user.authentications.count).to eq 2
      end

      it 'allows adding same provider with different uid' do
        user = create_new_user
        user.add_provider_to_user(:facebook, '12345')
        result = user.add_provider_to_user(:facebook, '67890')

        expect(result).to be_truthy
        expect(result).not_to be false
      end
    end

    describe 'configuration' do
      before(:all) do
        sorcery_reload!([:external])
        sorcery_model_property_set(:authentications_class, Authentication)
      end

      after do
        User.sorcery_config.reset!
      end

      it "allows configuration option 'authentications_class'" do
        sorcery_model_property_set(:authentications_class, UserProvider)

        expect(User.sorcery_config.authentications_class).to eq UserProvider
      end

      it "allows configuration option 'authentications_user_id_attribute_name'" do
        sorcery_model_property_set(:authentications_user_id_attribute_name, :owner_id)

        expect(User.sorcery_config.authentications_user_id_attribute_name).to eq :owner_id
      end

      it "allows configuration option 'provider_attribute_name'" do
        sorcery_model_property_set(:provider_attribute_name, :auth_provider)

        expect(User.sorcery_config.provider_attribute_name).to eq :auth_provider
      end

      it "allows configuration option 'provider_uid_attribute_name'" do
        sorcery_model_property_set(:provider_uid_attribute_name, :auth_uid)

        expect(User.sorcery_config.provider_uid_attribute_name).to eq :auth_uid
      end
    end
  end
end
