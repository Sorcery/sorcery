require 'sorcery'
require 'rails'

module Sorcery
  # The Sorcery engine takes care of extending ActiveRecord (if used) and ActionController,
  # With the plugin logic.
  class Engine < Rails::Engine
    config.sorcery = ::Sorcery::Controller::Config

    initializer 'extend Controller with sorcery' do
      # TODO: Should this include a modified version of the helper methods?
      if defined?(ActionController::API)
        ActionController::API.send(:include, Sorcery::Controller)
      end

      if defined?(ActionController::Base)
        ActionController::Base.send(:include, Sorcery::Controller)
        ActionController::Base.helper_method :current_user
        ActionController::Base.helper_method :logged_in?
      end
    end
  end
end
