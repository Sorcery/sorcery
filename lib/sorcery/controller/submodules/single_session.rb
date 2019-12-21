module Sorcery
  module Controller
    module Submodules
      module SingleSession
        def self.included(base)
          base.send(:include, InstanceMethods)

          Config.module_eval do
            class << self
              attr_accessor :verify_session_token_enabled
              def merge_remember_me_defaults!
                @defaults.merge!(:@verify_session_token_enabled => true)
              end
            end
            merge_remember_me_defaults!
          end

          unless Config.after_login.include?(:set_session_token)
            Config.after_login << :set_session_token
          end

          base.after_action :verify_session_token, if: :logged_in?
        end

        module InstanceMethods
          # Checks if session token matches users
          # To be used as a before_action
          def verify_session_token
            return unless Config.verify_session_token_enabled
            return if sorcery_session_token_valid?

            reset_sorcery_session
            remove_instance_variable :@current_user if defined? @current_user
          end

          def sorcery_session_token_valid?
            session[:token] == current_user.session_token
          end

          def set_session_token(user, _credentials = nil)
            session[:token] = user.regenerate_session_token
          end
        end
      end
    end
  end
end
