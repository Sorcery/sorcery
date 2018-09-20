require 'spec_helper'
require 'shared_examples/user_oauth_shared_examples'

describe User, 'with oauth submodule', active_record: true do
  before(:all) do
    MigrationHelper.migrate("#{Rails.root}/db/migrate/external")
    User.reset_column_information
  end

  after(:all) do
    MigrationHelper.rollback("#{Rails.root}/db/migrate/external")
  end

  it_behaves_like 'rails_3_oauth_model'
end
