module Sorcery
  module Providers
    # This class adds support for OAuth with open.wx.qq.com.
    #
    #   config.wechat.key = <key>
    #   config.wechat.secret = <secret>
    #   ...
    #
    class Wechat < Base
      include Protocols::Oauth2

      attr_reader   :mode, :param_name, :parse
      attr_accessor :auth_url, :scope, :token_url, :user_info_path

      def initialize
        super

        @scope = 'snsapi_login'
        @auth_url = 'https://open.weixin.qq.com/connect/qrconnect'
        @user_info_path = 'https://api.weixin.qq.com/sns/userinfo'
        @token_url = 'https://api.weixin.qq.com/sns/oauth2/access_token'
        @state = SecureRandom.hex(16)
        @mode = :body
        @parse = :json
        @param_name = 'access_token'
      end

      def authorize_url(options = {})
        oauth_params = {
          appid: @key,
          redirect_uri: @callback_url,
          response_type: 'code',
          scope: scope,
          state: @state
        }
        "#{options[:authorize_url]}?#{oauth_params.to_query}#wechat_redirect"
      end

      def get_user_hash(access_token)
        response = access_token.get(
          user_info_path,
          params: {
            access_token: access_token.token,
            openid: access_token.params['openid']
          }
        )

        {}.tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['unionid']
        end
      end

      def get_access_token(args, options = {})
        client = build_client(options)
        client.auth_code.get_token(
          args[:code],
          { appid: @key, secret: @secret, parse: parse },
          options
        )
      end

      def login_url(_params, _session)
        authorize_url authorize_url: auth_url
      end

      def process_callback(params, _session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(
          args,
          token_url: token_url,
          mode: mode,
          param_name: param_name
        )
      end
    end
  end
end
