module Sorcery
  module Controller
    module Submodules
      module JwtAuth
        def self.included(base)
          base.include(InstanceMethods)
        end

        module InstanceMethods
          def login_for_jwt(*credentials)
            user = user_class.authenticate(*credentials)
            if user
              user_params = Config.jwt_user_params.each_with_object({}) do |val, acc|
                acc[val] = user.public_send(val)
              end
              jwt_encode(user_params)
            end
          end

          def require_jwt_auth
            authenticate_request!
          end

          def authenticate_request!
            not_authenticated && return unless user_id?

            @current_user = User.find(user_id)
          rescue JWT::VerificationError, JWT::DecodeError
            not_authenticated && return
          end

          def http_token
            @http_token ||= request.headers['Authorization']&.split(' ')&.last
          end

          def auth_token
            @auth_token ||= jwt_decode(http_token)
          end

          def user_id
            return if auth_token[:id].blank?
            auth_token[:id].to_i
          end

          def user_id?
            http_token && auth_token && user_id
          end

          def jwt_encode(payload)
            JWT.encode(payload, Rails.application.secrets.secret_key_base)
          end

          def jwt_decode(token)
            HashWithIndifferentAccess.new(
              JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
            )
          rescue JWT::DecodeError => e
            e
          end

          attr_reader :current_user
        end
      end
    end
  end
end