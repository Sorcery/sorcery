# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/user_activity_logging_shared_examples'

describe User, :active_record do
  context 'with activity logging submodule' do
    before(:all) do
      MigrationHelper.migrate("#{Rails.root}/db/migrate/activity_logging")
      described_class.reset_column_information
    end

    after(:all) do
      MigrationHelper.rollback("#{Rails.root}/db/migrate/activity_logging")
    end

    it_behaves_like 'rails_3_activity_logging_model'
  end
end
