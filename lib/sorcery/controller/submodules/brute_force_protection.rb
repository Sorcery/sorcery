module Sorcery
  module Controller
    module Submodules
      # This module helps protect user accounts by locking them down after too
      # many failed attemps to login were detected.
      # This is the controller part of the submodule which takes care of
      # updating the failed logins and resetting them.
      # See Sorcery::Model::Submodules::BruteForceProtection for configuration
      # options.
      module BruteForceProtection
        def self.included(base)
          base.send(:include, InstanceMethods)
          # FIXME: There is likely a more elegant way to safeguard these callbacks.
          unless Config.after_login.include?(:reset_failed_logins_count!)
            Config.after_login << :reset_failed_logins_count!
          end
          unless Config.after_failed_login.include?(:update_failed_logins_count!)
            Config.after_failed_login << :update_failed_logins_count!
          end
        end

        module InstanceMethods
          protected

          # Increments the failed logins counter on every failed login.
          # Runs as a hook after a failed login.
          def update_failed_logins_count!(credentials)
            user = user_class.sorcery_adapter.find_by_credentials(credentials)

            # if the password is valid, don't extend the lock expiry. The
            # authentication has already failed due to the lock.
            user.register_failed_login! if user && !user.valid_password?(credentials[1])
          end

          # Resets the failed logins counter.
          # Runs as a hook after a successful login.
          def reset_failed_logins_count!(user, _credentials)
            user.sorcery_adapter.update_attribute(user_class.sorcery_config.failed_logins_count_attribute_name, 0)
          end
        end
      end
    end
  end
end
