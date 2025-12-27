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
    end
  end
end
