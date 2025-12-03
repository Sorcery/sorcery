# frozen_string_literal: true

require 'spec_helper'

require 'rails_app/app/mailers/sorcery_mailer'
require 'shared_examples/user_activation_shared_examples'

describe User, 'with activation submodule', :active_record do
  before(:all) do
    MigrationHelper.migrate("#{Rails.root}/db/migrate/activation")
    described_class.reset_column_information
  end

  after(:all) do
    MigrationHelper.rollback("#{Rails.root}/db/migrate/activation")
  end

  it_behaves_like 'rails_3_activation_model'
end
