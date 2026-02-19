require 'spec_helper'
require 'shared_examples/user_single_session_shared_examples'

describe User, 'with single_session submodule', active_record: true do
  before(:all) do
    MigrationHelper.migrate("#{Rails.root}/db/migrate/single_session")
    User.reset_column_information
  end

  after(:all) do
    MigrationHelper.rollback("#{Rails.root}/db/migrate/single_session")
  end

  it_behaves_like 'rails_single_session_model'
end
