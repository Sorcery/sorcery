module Sorcery
  module Providers
    # This class adds support for OAuth with graph.qq.com.
    #
    class Qq < Base
      include Protocols::Oauth2

      attr_reader   :parse
      attr_accessor :auth_url, :scope, :token_url, :user_info_path, :openid_path

      def initialize
        super

        @scope = 'get_user_info'
        @auth_url = 'https://graph.qq.com/oauth2.0/authorize'
        @openid_path = 'https://graph.qq.com/oauth2.0/me'
        @user_info_path = 'https://graph.qq.com/user/get_user_info'
        @token_url = 'https://graph.qq.com/oauth2.0/token'
        @parse = :query
        @state = SecureRandom.hex(16)
      end

      def authorize_url(options = {})
        oauth_params = {
          response_type: 'code',
          client_id: @key,
          redirect_uri: @callback_url,
          state: @state,
          scope: @scope
        }
        "#{options[:authorize_url]}?#{oauth_params.to_query}#qq_redirect"
      end

      def get_user_hash(access_token)
        openid_response = access_token.get(openid_path, params: {
          access_token: access_token.token
        })

        openid = openid_response.body.match(/"openid":"(\w{3,32})"/) || [nil, '']

        info_response = access_token.get(user_info_path, params: {
          access_token: access_token.token,
          oauth_consumer_key: @key,
          openid: openid[1]
        })

        {}.tap do |h|
          h[:user_info] = JSON.parse(info_response.body)
          h[:uid] = openid[1]
        end
      end

      def get_access_token(args, options = {})
        client = build_client(options)

        client.auth_code.get_token(
          args[:code],
          { client_id: @key, client_secret: @secret, redirect_uri: @callback_url, parse: @parse},
          options
        )
      end

      def login_url(_params, _session)
        authorize_url authorize_url: auth_url
      end

      def process_callback(params, _session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code].present?
        end

        get_access_token(
          args,
          token_url: token_url,
        )
      end
    end
  end
end
