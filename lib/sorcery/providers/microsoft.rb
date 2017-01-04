module Sorcery
  module Providers
    # This class adds support for OAuth with Microsoft Graph.
    #
    #   config.microsoft.key = <key>
    #   config.microsoft.secret = <secret>
    #   ...
    #
    class Microsoft < Base
      include Protocols::Oauth2

      attr_accessor :auth_url, :scope, :token_url, :user_info_url

      def initialize
        super

        @site          = 'https://login.microsoftonline.com'
        @auth_url      = '/common/oauth2/v2.0/authorize'
        @token_url     = '/common/oauth2/v2.0/token'
        @user_info_url = 'https://graph.microsoft.com/v1.0/me'
        @scope         = 'openid email https://graph.microsoft.com/User.Read'
        @state         = SecureRandom.hex(16)
      end

      def authorize_url(options = {})
        oauth_params = {
          client_id: @key,
          response_type: 'code'
        }
        options.merge!(oauth_params)
        super(options)
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_url)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['id']
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(_params, _session)
        authorize_url(authorize_url: auth_url)
      end

      # tries to login the user from access token
      def process_callback(params, _session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, token_url: token_url, token_method: :post)
      end
    end
  end
end
