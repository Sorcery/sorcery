$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV['RAILS_ENV'] ||= 'test'

SORCERY_ORM = :active_record

# require 'simplecov'
# SimpleCov.root File.join(File.dirname(__FILE__), '..', 'lib')
# SimpleCov.start
require 'rails/all'
require 'rspec/rails'
require 'timecop'
require 'byebug'

def setup_orm; end

def teardown_orm; end

require "orm/#{SORCERY_ORM}"

require 'rails_app/config/environment'

class TestMailer < ActionMailer::Base; end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include RSpec::Rails::ControllerExampleGroup, file_path: /controller(.)*_spec.rb$/
  config.mock_with :rspec

  config.use_transactional_fixtures = false

  config.before(:suite) { setup_orm }
  config.after(:suite) { teardown_orm }
  config.before(:each) { ActionMailer::Base.deliveries.clear }

  config.include ::Sorcery::TestHelpers::Internal
  config.include ::Sorcery::TestHelpers::Internal::Rails

  if begin
       Module.const_defined?('::Rails::Controller::Testing')
     rescue StandardError
       false
     end
    config.include ::Rails::Controller::Testing::TestProcess, type: :controller
    config.include ::Rails::Controller::Testing::TemplateAssertions, type: :controller
    config.include ::Rails::Controller::Testing::Integration, type: :controller
  end
end
