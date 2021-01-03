require 'spec_helper'
require 'support/generator_helper'

require 'generators/sorcery/install_generator'

describe 'install generator' do
  include GeneratorHelper

  class TestInstallGenerator < Sorcery::Generators::InstallGenerator
    source_root File.expand_path('../../lib/generators/sorcery/templates', __dir__)

    def self.next_migration_number(dirname)
      current_migration_number(dirname) + 1
    end
  end

  tests TestInstallGenerator

  context 'given deprecated --migrations option' do
    let(:installer) do
      generator(options: { migrations: true })
    end

    it 'shows warning' do
      expect(installer).to receive(:warn).with(/\[DEPRECATED\] `--migrations` option is deprecated/)
      installer.check_deprecated_options
    end
  end

  context 'given invalid submodule' do
    it 'raises error' do
      expect {
        generator('invalid_submodule').check_available_submodules
      }.to raise_error(ArgumentError).with_message(/invalid_submodule is not a Sorcery submodule/)
    end
  end

  describe 'initializer' do
    describe 'installation' do
      let(:installation) { invoke!(:install_initializer) }

      it 'creates initializer' do
        expect(installation).to match(/create  config\/initializers\/sorcery.rb/)
      end
    end

    describe 'configuration' do
      context 'given submodule(s)' do
        let(:initializer_contents) do
          File.read(initializer_path)
        end
  
        before do
          invoke!(:install_initializer, 'activity_logging')
        end
  
        it 'adds submodule(s) to initializer' do
          expect(initializer_contents).to match(/Rails\.application\.config\.sorcery\.submodules = \[:activity_logging\]/)
        end
      end
    end

    describe 'uninstallation' do
      let(:uninstallation) { revoke!(:install_initializer) }

      before do
        invoke!(:install_initializer)
      end

      it 'removes initializer' do
        expect(uninstallation).to match(/remove  config\/initializers\/sorcery.rb/)
      end
    end
  end

  describe 'model' do
    describe 'installation' do
      let(:installation) { invoke!(:install_model) }

      it 'skips migration' do
        expect(installation).to match(/generate  model User \-\-skip\-migration/)
      end

      it 'creates model' do
        expect(installation).to match(/create    app\/models\/user\.rb/)
      end
    end

    describe 'configuration' do
      let(:model_contents) do
        File.read(model_path(:user))
      end

      before do
        invoke!(:install_model)
      end

      it 'adds `authenticates_with_sorcery!`' do
        expect(model_contents).to match(/authenticates_with_sorcery!/)
      end
    end

    describe 'uninstallation' do
      let(:uninstallation) { revoke!(:install_model) }

      before do
        invoke!(:install_model)
      end

      it 'removes `authenticates_with_sorcery!`' do
        expect(uninstallation).to match(/subtract  app\/models\/user.rb/)
      end
    end
  end

  describe 'migrations' do
    describe 'installation' do
      let(:installation) { invoke!(:install_migrations, 'activity_logging', options: { only_submodules: true }) }

      it 'creates migration' do
        expect(installation).to match(/create  db\/migrate\/1_sorcery_activity_logging.rb/)
      end
    end

    describe 'uninstallation' do
      let(:uninstallation) { revoke!(:install_migrations, 'activity_logging', options: { only_submodules: true }) }

      it 'removes migration' do
        expect(uninstallation).to match(/remove  db\/migrate\/1_sorcery_activity_logging.rb/)
      end
    end
  end
end
