require 'sorcery'
require 'rails'

module Sorcery
  # The Sorcery engine takes care of extending ActiveRecord (if used) and ActionController,
  # With the plugin logic.
  class Engine < Rails::Engine
    config.sorcery = ::Sorcery::Controller::Config

    # TODO: Should this include a modified version of the helper methods?
    initializer 'extend Controller with sorcery' do
      # FIXME: on_load is needed to fix Rails 6 deprecations, but it breaks
      #        applications due to undefined method errors.
      # ActiveSupport.on_load(:action_controller_api) do
      if defined?(ActionController::API)
        ActionController::API.send(:include, Sorcery::Controller)
      end

      # FIXME: on_load is needed to fix Rails 6 deprecations, but it breaks
      #        applications due to undefined method errors.
      # ActiveSupport.on_load(:action_controller_base) do
      if defined?(ActionController::Base)
        ActionController::Base.send(:include, Sorcery::Controller)
        ActionController::Base.helper_method :current_user
        ActionController::Base.helper_method :logged_in?
      end
    end
  end
end
