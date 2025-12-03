# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/user_magic_login_shared_examples'

describe User, 'with magic_login submodule', :active_record do
  before(:all) do
    MigrationHelper.migrate("#{Rails.root}/db/migrate/magic_login")
    described_class.reset_column_information
  end

  after(:all) do
    MigrationHelper.rollback("#{Rails.root}/db/migrate/magic_login")
  end

  it_behaves_like 'magic_login_model'
end
