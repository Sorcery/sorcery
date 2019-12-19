module Sorcery
  module Providers
    # This class adds support for OAuth with discordapp.com

    class Discord < Base
      include Protocols::Oauth2

      attr_accessor :auth_path, :scope, :token_url, :user_info_path

      def initialize
        super

        @scope          = 'identify'
        @site           = 'https://discordapp.com/'
        @auth_path      = '/api/oauth2/authorize'
        @token_url      = '/api/oauth2/token'
        @user_info_path = '/api/users/@me'
        @state          = SecureRandom.hex(16)
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)
        body = JSON.parse(response.body)
        auth_hash(access_token).tap do |h|
          h[:user_info] = body
          h[:uid] = body['id']
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(_params, _session)
        authorize_url(authorize_url: auth_path)
      end

      # tries to login the user from access token
      def process_callback(params, _session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end
        get_access_token(
          args,
          token_url: token_url,
          client_id: @key,
          client_secret: @secret,
          grant_type: 'authorization_code',
          token_method: :post
        )
      end
    end
  end
end
