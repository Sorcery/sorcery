module Sorcery
  module Controller
    module Submodules
      module JwtAuth
        def self.included(base)
          base.include(InstanceMethods)
        end

        module InstanceMethods
          # This method return generated token if user can be authenticated
          def jwt_login(*credentials)
            user = user_class.authenticate(*credentials)
            if user
              user_params = Config.jwt_user_params.each_with_object({}) do |val, acc|
                acc[val] = user.public_send(val)
              end
              { Config.jwt_user_data_key => user_params,
                Config.jwt_auth_token_key => jwt_encode(user_params) }
            end
          end

          # To be used as a before_action.
          def jwt_require_auth
            jwt_not_authenticated && return unless jwt_user_id

            @current_user = Config.jwt_set_user ? User.find(jwt_user_id) : jwt_user_data
          rescue JWT::VerificationError, JWT::DecodeError
            jwt_not_authenticated && return
          end

          # This method creating JWT token by payload
          def jwt_encode(payload)
            JWT.encode(payload, Config.jwt_secret_key)
          end

          # This method decoding JWT token
          # Return nil if token incorrect
          def jwt_decode(token)
            HashWithIndifferentAccess.new(
              JWT.decode(token, Config.jwt_secret_key)[0]
            )
          rescue JWT::DecodeError
            nil
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
            jwt_user_data.try(:[], :id)
          end

          # This method called if user not authenticated
          def jwt_not_authenticated
            respond_to do |format|
              format.html { not_authenticated }
              format.json { render json: { status: 401 }, status: 401 }
            end
          end
        end
      end
    end
  end
end