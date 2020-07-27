module Sorcery
  module Controller
    module Submodules
      # This submodule adds support for authentication via JSON Web Tokens.
      # https://jwt.io/
      module Jwt
        TOKEN_REGEX = /^(Token|Bearer)\s+/.freeze

        def self.included(base)
          base.send(:include, InstanceMethods)

          Config.module_eval do
            class << self
              attr_accessor :jwt_algorithm
              attr_accessor :jwt_encode_key
              attr_accessor :jwt_decode_key
              attr_accessor :jwt_lifetime
              attr_accessor :jwt_lifetime_leeway
              attr_accessor :jwt_header
              attr_accessor :jwt_additional_user_payload_action
              attr_accessor :jwt_not_authenticated_action

              def merge_jwt_defaults!
                @defaults.merge!(:@jwt_algorithm                      => nil,
                                 :@jwt_encode_key                     => nil,
                                 :@jwt_decode_key                     => nil,
                                 :@jwt_lifetime                       => 3600,
                                 :@jwt_lifetime_leeway                => 30,
                                 :@jwt_header                         => 'Authorization',
                                 :@jwt_additional_user_payload_action => nil,
                                 :@jwt_not_authenticated_action       => :jwt_not_authenticated)
              end
            end

            merge_jwt_defaults!
          end

          Config.login_sources << :login_from_jwt_header
        end

        module InstanceMethods
          # To be used as before_action.
          # Will trigger auto-login attempts via the call to logged_in?
          # If all attempts to auto-login fail, the failure callback will be called.
          def require_jwt_authentication
            return if logged_in?

            send(Config.jwt_not_authenticated_action)
          end

          # Takes credentials and returns generated token on successful authentication.
          # Runs hooks after login or failed login.
          def jwt_authenticate(*credentials)
            validate_jwt_configuration

            @current_user = nil

            user_class.authenticate(*credentials) do |user, failure_reason|
              if failure_reason
                after_failed_login!(credentials)

                yield(user, failure_reason) if block_given?

                break
              end

              # Identical to auto_login but doesn't touch session
              @current_user = user

              after_login!(user, credentials)

              yield(user, failure_reason) if block_given?

              # Return our own value, not the return_value from authentication_response
              break generate_jwt(user)
            end
          end

          # Generate token and payload hash based on provided user
          def generate_jwt(user)
            now = Time.current.to_i

            payload = { sub: user.id,
                        iat: now,
                        exp: now + Config.jwt_lifetime }

            payload.merge!(user.public_send(Config.jwt_additional_user_payload_action)) if Config.jwt_additional_user_payload_action

            { token:   jwt_encode(payload),
              payload: payload }
          end

          # Checks header for a token and tries to log in user if token is valid.
          # Runs as a login source callback. Check current_user method for more details.
          def login_from_jwt_header
            @current_user = if jwt_decoded_payload['sub']
                              user_class.sorcery_adapter.find_by_id(jwt_decoded_payload['sub'])
                            end
          end

          # The default action for denying non-authenticated users.
          # You can override this method in your controllers,
          # or provide a different method in the configuration.
          def jwt_not_authenticated
            head :unauthorized
          end

          def validate_jwt_configuration
            raise ArgumentError, "To use jwt submodule, you must define an algorithm (config.jwt_algorithm = 'algorithm')." if Config.jwt_algorithm.nil? || Config.jwt_algorithm == ''
            raise ArgumentError, "To use jwt submodule, you must define an encode key (config.jwt_encode_key = 'your_key')." if Config.jwt_encode_key.nil? || Config.jwt_encode_key == ''
            raise ArgumentError, "To use jwt submodule, you must define a decode key (config.jwt_decode_key = 'your_key')." if Config.jwt_decode_key.nil? || Config.jwt_decode_key == ''
          end

          # Token (without type) extracted from header
          def jwt_from_header
            @jwt_from_header ||= request.headers[Config.jwt_header].to_s.sub(TOKEN_REGEX, '')
          end

          # Payload decoded from token
          def jwt_decoded_payload
            @jwt_decoded_payload ||= jwt_decode(jwt_from_header)
          end

          # Create JWT from payload
          def jwt_encode(payload)
            JWT.encode(payload, Config.jwt_encode_key, Config.jwt_algorithm)
          end

          # Decode payload from JWT
          def jwt_decode(token)
            JWT.decode(token, Config.jwt_decode_key, true, { algorithm: Config.jwt_algorithm, exp_leeway: Config.jwt_lifetime_leeway })[0]
          rescue JWT::DecodeError
            {}
          end
        end
      end
    end
  end
end
