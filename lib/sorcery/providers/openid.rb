module Sorcery
  module Providers
    class Openid < Base
      include Protocols::Oauth2

      attr_accessor :auth_url, :scope, :token_url, :user_info_url

      def initialize
        super

        @auth_url      = '/authorize'
        @token_url     = '/token'
        @user_info_url = '/userinfo'
        @scope         = 'openid'
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_url)
        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['sub']
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(_params, _session, args = {})
        options = {
          authorize_url: auth_url,
          params: args
        }
        authorize_url(options)
      end

      # tries to login the user from access token
      def process_callback(params, _session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, ssl: { verify: false }, token_url: token_url, token_method: :post)
      end
    end
  end
end
