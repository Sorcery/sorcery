module Sorcery
  module Providers
    # This class adds support for OAuth with Auth0.com
    #
    #   config.auth0.key = <key>
    #   config.auth0.secret = <secret>
    #   config.auth0.domain = <domain>
    #   ...
    #
    class Auth0 < Base
      include Protocols::Oauth2

      attr_accessor :auth_path, :token_path, :user_info_path, :scope

      def initialize
        super

        @auth_path      = '/authorize'
        @token_path     = '/oauth/token'
        @user_info_path = '/userinfo'
        @scope          = 'openid profile email'
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['sub']
        end
      end

      def login_url(_params, _session)
        authorize_url(authorize_url: auth_path)
      end

      def process_callback(params, _session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, token_url: token_path, token_method: :post)
      end
    end
  end
end
