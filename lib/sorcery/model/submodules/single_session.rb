module Sorcery
  module Model
    module Submodules
      # This submodule adds the ability to set unique session token per user.
      # It helps enforce single session per user.
      # This is the model part of the submodule, which provides configuration options.
      module SingleSession
        def self.included(base)
          base.sorcery_config.class_eval do
            # Unique session token attribute name
            attr_accessor :session_token_attribute_name
          end

          base.sorcery_config.instance_eval do
            @defaults.merge!(:@session_token_attribute_name => :session_token)
            reset!
          end

          base.sorcery_config.after_config << :define_session_token_fields

          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)
        end

        module ClassMethods

          protected

          def define_session_token_fields
            class_eval do
              sorcery_adapter.define_field sorcery_config.session_token_attribute_name, String
            end
          end
        end

        module InstanceMethods
          def regenerate_session_token
            token = TemporaryToken.generate_random_token
            sorcery_adapter.update_attributes({ sorcery_config.session_token_attribute_name => token })

            token
          end
        end
      end
    end
  end
end
