# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV['RAILS_ENV'] ||= 'test'

require 'rails/all'
require 'rspec/rails'
require 'timecop'
require 'byebug'

def setup_orm; end

def teardown_orm; end

require 'orm/active_record'

require 'rails_app/config/environment'

class TestMailer < ActionMailer::Base; end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec

  config.use_transactional_fixtures = true

  config.before(:suite) { setup_orm }
  config.after(:suite) { teardown_orm }
  config.before { ActionMailer::Base.deliveries.clear }

  config.include Sorcery::TestHelpers::Internal
  config.include Sorcery::TestHelpers::Internal::Rails
end
