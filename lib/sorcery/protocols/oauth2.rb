require 'oauth2'

module Sorcery
  module Protocols
    module Oauth2
      def oauth_version
        '2.0'
      end

      def authorize_url(options = {})
        query_params = {
          redirect_uri: @callback_url,
          scope: @scope,
          display: @display,
          state: @state
        }
        params = options.extract! :params
        query_params.merge!(params[:params]) unless params.empty?
        client = build_client(options)
        client.auth_code.authorize_url(query_params)
      end

      def get_access_token(args, options = {})
        client = build_client(options)
        client.auth_code.get_token(
          args[:code],
          {
            redirect_uri: @callback_url,
            parse: options.delete(:parse)
          },
          options
        )
      end

      def build_client(options = {})
        defaults = {
          site: @site,
          ssl: { ca_file: Sorcery::Controller::Config.ca_file }
        }
        ::OAuth2::Client.new(
          @key,
          @secret,
          defaults.merge!(options)
        )
      end
    end
  end
end
