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
              { Config.jwt_user_data_key => user_params,
                Config.jwt_auth_token_key => jwt_encode(user_params) }
            end
          end

          def require_jwt_auth
            authenticate_request!
          end

          def authenticate_request!
            jwt_not_authenticated && return unless user_id

            @current_user = User.find(user_id)
          rescue JWT::VerificationError, JWT::DecodeError
            jwt_not_authenticated && return
          end

          def jwt_encode(payload)
            JWT.encode(payload, Rails.application.secrets.secret_key_base)
          end

          def jwt_decode(token)
            HashWithIndifferentAccess.new(
              JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
            )
          rescue JWT::DecodeError
            nil
          end

          def jwt_from_header
            @header_token ||= request.headers[Config.jwt_headers_key]
          end

          def user_data(token = jwt_from_header)
            @user_data ||= jwt_decode(token)
          end

          def user_id
            user_data.try(:[], :id)
          end

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