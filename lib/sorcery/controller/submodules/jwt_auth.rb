module Sorcery
  module Controller
    module Submodules
      module JwtAuth
        def self.included(base)
          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          # This method return generated token if user can be authenticated
          def jwt_auth(*credentials)
            user = user_class.authenticate(*credentials)
            if user
              now = Time.current
              default_payload = {
                  sub: user.id,
                  exp: (now + 3.days).to_i,
                  iat: now.to_i
              }

              payload = default_payload.merge Config.jwt_payload
              
              { Config.jwt_user_data_key => default_payload,
                Config.jwt_auth_token_key => jwt_encode(payload) }
            end
          end

          # To be used as a before_action.
          def jwt_require_auth
            binding.pry
            @current_user = Config.jwt_set_user ? User.find(jwt_user_id) : jwt_user_data
          rescue JWT::DecodeError => e
            jwt_not_authenticated(message: e.message) && return
          end

          # This method creating JWT token by payload
          def jwt_encode(payload)
            JWT.encode(payload, Config.jwt_secret_key, Config.jwt_algorithm)
          end

          # This method decoding JWT token
          # Return nil if token incorrect
          def jwt_decode(token)
            HashWithIndifferentAccess.new(
              JWT.decode(token, Config.jwt_secret_key)[0]
            )
          end

          # Take token from header, by key defined in config
          # With memoization
          def jwt_from_header
            @jwt_header_token ||= request.headers[Config.jwt_headers_key]
          end

          # Return user data which decoded from token
          # With memoization
          def jwt_user_data(token = jwt_from_header)
            @jwt_user_data ||= jwt_decode(token)
          end

          # Return user id from user data if id present.
          # Else return nil
          def jwt_user_id
            jwt_user_data[:sub]
          end

          # This method called if user not authenticated
          def jwt_not_authenticated(message:)
            respond_to do |format|
              format.html { not_authenticated }
              format.json {
                render json: {
                    "error": {
                        "message": message,
                    }
                },
                status: :unauthorized
              }
            end
          end
        end
      end
    end
  end
end
