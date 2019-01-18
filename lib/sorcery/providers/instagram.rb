module Sorcery
  module Providers
    # This class adds support for OAuth with Instagram.com.
    class Instagram < Base
      include Protocols::Oauth2

      attr_accessor :access_permissions, :token_url,
                    :authorization_path, :user_info_path,
                    :scope, :user_info_fields

      def initialize
        super

        @site = 'https://api.instagram.com'
        @token_url = '/oauth/access_token'
        @authorization_path = '/oauth/authorize/'
        @user_info_path = '/v1/users/self'
        @scope = 'basic'
      end

      def self.included(base)
        base.extend Sorcery::Providers
      end

      # provider implements method to build Oauth client
      def login_url(_params, _session)
        authorize_url(token_url: @token_url)
      end

      # overrides oauth2#authorize_url to allow customized scope.
      def authorize_url(opts = {})
        @scope = access_permissions.present? ? access_permissions.join(' ') : scope
        super(opts.merge(token_url: @token_url))
      end

      # pass oauth2 param `code` provided by instgrm server
      def process_callback(params, _session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end
        get_access_token(
          args,
          token_url: @token_url,
          client_id: @key,
          client_secret: @secret
        )
      end

      # see `user_info_mapping` in config/initializer,
      # given `user_info_mapping` to specify
      #   {:db_attribute_name => 'instagram_attr_name'}
      # so that Sorcery can build AR model from attr names
      #
      # NOTE: instead of just getting the user info
      # from the access_token (which already returns them),
      # testing strategy relies on querying user_info_path
      def get_user_hash(access_token)
        call_api_params = {
          access_token: access_token.token,
          client_id: access_token[:client_id]
        }
        response = access_token.get(
          "#{user_info_path}?#{call_api_params.to_param}"
        )

        user_attrs = {}
        user_attrs[:user_info] = JSON.parse(response.body)['data']
        user_attrs[:uid] = user_attrs[:user_info]['id']
        user_attrs
      end
    end
  end
end
