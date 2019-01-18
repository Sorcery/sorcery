require 'securerandom'

module Sorcery
  module Model
    # This module encapsulates the logic for temporary token.
    # A temporary token is created to identify a user in scenarios
    # such as reseting password and activating the user by email.
    module TemporaryToken
      def self.included(base)
        # FIXME: This may not be the ideal way of passing sorcery_config to generate_random_token.
        @sorcery_config = base.sorcery_config
        base.extend(ClassMethods)
      end

      # Random code, used for salt and temporary tokens.
      def self.generate_random_token
        SecureRandom.urlsafe_base64(@sorcery_config.token_randomness).tr('lIO0', 'sxyz')
      end

      module ClassMethods
        def load_from_token(token, token_attr_name, token_expiration_date_attr = nil, &block)
          return token_response(failure: :invalid_token, &block) if token.blank?

          user = sorcery_adapter.find_by_token(token_attr_name, token)

          return token_response(failure: :user_not_found, &block) unless user

          unless check_expiration_date(user, token_expiration_date_attr)
            return token_response(user: user, failure: :token_expired, &block)
          end

          token_response(user: user, return_value: user, &block)
        end

        protected

        def check_expiration_date(user, token_expiration_date_attr)
          return true unless token_expiration_date_attr

          expires_at = user.send(token_expiration_date_attr)

          !expires_at || (Time.now.in_time_zone < expires_at)
        end

        def token_response(options = {})
          yield(options[:user], options[:failure]) if block_given?

          options[:return_value]
        end
      end
    end
  end
end
