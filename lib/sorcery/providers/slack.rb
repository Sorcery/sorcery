module Sorcery
  module Providers
    # This class adds support for OAuth with slack.com.

    class Slack < Base
      include Protocols::Oauth2

      attr_accessor :auth_path, :scope, :token_url, :user_info_path

      def initialize
        super

        @scope          = 'identity.basic, identity.email'
        @site           = 'https://slack.com/'
        @user_info_path = 'https://slack.com/api/users.identity'
        @auth_path      = '/oauth/authorize'
        @token_url      = '/api/oauth.access'
      end

      def get_user_hash(access_token)
        auth_hash(access_token).tap do |h|
          h[:user_info] = fetch_user_info(access_token)['user']
          h[:uid] = h[:user_info]['id']
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

        get_access_token(args, token_url: token_url, token_method: :post)
      end

      private

      def fetch_user_info(access_token)
        return access_token if user_info_present?(access_token)

        JSON.parse(access_token.get(user_info_path).body)
      end

      def user_info_present?(access_token)
        access_token['user'].present? &&
          access_token['user']['id'].present? &&
          access_token['user']['email'].present?
      end
    end
  end
end
