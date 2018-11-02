require File.expand_path('boot', __dir__)

require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'rails/test_unit/railtie'

Bundler.require :default, SORCERY_ORM

# rubocop:disable Lint/HandleExceptions
begin
  require "#{SORCERY_ORM}/railtie"
rescue LoadError
  # TODO: Log this issue or change require scheme.
end
# rubocop:enable Lint/HandleExceptions

require 'sorcery'

module AppRoot
  class Application < Rails::Application
    config.autoload_paths.reject! { |p| p =~ %r{/\/app\/(\w+)$/} && !%w[controllers helpers mailers views].include?(Regexp.last_match(1)) }
    config.autoload_paths += ["#{config.root}/app/#{SORCERY_ORM}"]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.action_mailer.delivery_method = :test
    config.active_support.deprecation = :stderr
    if Rails.version >= '5.1.0' && config.active_record.sqlite3.present?
      config.active_record.sqlite3.represent_boolean_as_integer = true
    end
  end
end
