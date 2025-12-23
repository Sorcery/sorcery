# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/user_oauth_shared_examples'

describe User, :active_record do
  context 'with oauth submodule' do
    before(:all) do
      MigrationHelper.migrate("#{Rails.root}/db/migrate/external")
      described_class.reset_column_information
    end

    after(:all) do
      MigrationHelper.rollback("#{Rails.root}/db/migrate/external")
    end

    it_behaves_like 'rails_3_oauth_model'
  end
end
