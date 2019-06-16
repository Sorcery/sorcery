module Sorcery
  module Providers
    # This class adds support for OAuth with LinkedIn.
    #
    #   config.linkedin.key = <key>
    #   config.linkedin.secret = <secret>
    #   ...
    #
    class Linkedin < Base
      include Protocols::Oauth2

      attr_accessor :auth_url, :scope, :token_url, :user_info_url, :email_info_url

      def initialize
        super

        @site           = 'https://api.linkedin.com'
        @auth_url       = '/oauth/v2/authorization'
        @token_url      = '/oauth/v2/accessToken'
        @user_info_url  = 'https://api.linkedin.com/v2/me'
        @email_info_url = 'https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))'
        @scope          = 'r_liteprofile r_emailaddress'
        @state          = SecureRandom.hex(16)
      end

      def get_user_hash(access_token)
        user_info = get_user_info(access_token)

        auth_hash(access_token).tap do |h|
          h[:user_info] = user_info
          h[:uid]       = h[:user_info]['id']
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

      def get_user_info(access_token)
        response  = access_token.get(user_info_url)
        user_info = JSON.parse(response.body)

        if email_in_scope?
          email = fetch_email(access_token)

          return user_info.merge(email)
        end

        user_info
      end

      def email_in_scope?
        scope.include?('r_emailaddress')
      end

      def fetch_email(access_token)
        email_response = access_token.get(email_info_url)
        email_info     = JSON.parse(email_response.body)['elements'].first

        email_info['handle~']
      end
    end
  end
end
