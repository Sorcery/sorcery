require 'spec_helper'
require 'shared_examples/user_reset_password_shared_examples'

describe User, 'with reset_password submodule', active_record: true do
  before(:all) do
    MigrationHelper.migrate("#{Rails.root}/db/migrate/reset_password")
    User.reset_column_information
  end

  after(:all) do
    MigrationHelper.rollback("#{Rails.root}/db/migrate/reset_password")
  end

  it_behaves_like 'rails_3_reset_password_model'
end
