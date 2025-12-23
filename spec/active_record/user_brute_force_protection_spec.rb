# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/user_brute_force_protection_shared_examples'

describe User, :active_record do
  context 'with brute_force_protection submodule' do
    before(:all) do
      MigrationHelper.migrate("#{Rails.root}/db/migrate/brute_force_protection")
      described_class.reset_column_information
    end

    after(:all) do
      MigrationHelper.rollback("#{Rails.root}/db/migrate/brute_force_protection")
    end

    it_behaves_like 'rails_3_brute_force_protection_model'
  end
end
