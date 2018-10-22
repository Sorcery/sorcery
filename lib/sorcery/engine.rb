require 'sorcery'
require 'rails'

module Sorcery
  # The Sorcery engine takes care of extending ActiveRecord (if used) and ActionController,
  # With the plugin logic.
  class Engine < Rails::Engine
    config.sorcery = ::Sorcery::Controller::Config

    initializer 'extend Controller with sorcery' do
      ActiveSupport.on_load(:action_controller) do
        send(:include, Sorcery::Controller)
      end
      ActiveSupport.on_load(:action_controller_base) do
        helper_method :current_user
        helper_method :logged_in?
      end
    end
  end
end
