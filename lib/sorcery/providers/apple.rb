require 'jwt'

module Sorcery
  module Providers
    # This class adds support for OAuth with apple.com.
    #
    #   config.apple.key = <key>
    #   config.apple.team_id = <team_id>
    #   config.apple.key_id = <key_id>
    #   config.apple.pem = <pem>
    #   config.apple.verify_payload = <true,false>
    #   ...
    #
    class Apple < Base
      include Protocols::Oauth2

      attr_accessor :auth_url, :token_url, :keys_url, :key, :team_id, :key_id, :pem, :verify_payload, :site, :user_info

      def initialize
        super

        @site          = 'https://appleid.apple.com'
        @auth_url      = '/auth/authorize'
        @token_url     = '/auth/token'
        @keys_url = '/auth/keys'
        @scope = 'name email'
      end

      def get_user_hash(access_token)
        # The actual user information should be obtained from the id_token
        decoded_id_token = decode_id_token(access_token)

        verify_claims!(decoded_id_token)

        auth_hash(access_token).tap do |h|
          h[:user_info] = decoded_id_token.merge(@user_info)
          h[:uid] = decoded_id_token['sub']
        end
      end

      def login_url(params, session)
        @secret = client_secret
        params[:scope] ||= 'name email'
        params[:nonce] = new_nonce(session)
        params[:response_mode] = 'form_post'
        authorize_url(authorize_url: auth_url, connection_opts: { params: params })
      end

      def process_callback(params, _session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
          a[:key] = key
          a[:client_secret] = client_secret
        end

        @user_info = JSON.parse(params[:user] || '{}')

        get_access_token(args, token_url: token_url, token_method: :post)
      end

      private

      def new_nonce(session)
        session['sorcery.apple.nonce'] = SecureRandom.urlsafe_base64(16)
      end

      def stored_nonce
        session.delete('sorcery.apple.nonce')
      end

      def decode_id_token(access_token)
        id_token = access_token.params['id_token']

        if verify_payload
          _, decoded_header = JWT.decode(id_token, nil, false)
          kid = decoded_header['kid']

          keys_response = access_token.get(keys_url)
          json_response = JSON.parse(keys_response.body)

          matching_key = find_key_by_kid(json_response['keys'], kid)

          raise 'No matching key found' unless matching_key

          jwk_key = JWT::JWK.import(matching_key)
          public_key = jwk_key.keypair

          verified_payload, = JWT.decode(id_token, public_key, true, { algorithm: matching_key['alg'] })

          verified_payload
        else
          payload, = JWT.decode(id_token, nil, false)

          payload
        end
      end

      def find_key_by_kid(keys, kid)
        keys.find { |key| key['kid'] == kid }
      end

      def client_secret
        JWT.encode({
          iss: team_id,
          aud: site,
          sub: key,
          kid: key_id,
          iat: Time.now.to_i,
          exp: (Time.now + 60).to_i
        }, private_key, 'ES256')
      end

      def private_key
        ::OpenSSL::PKey::EC.new(pem)
      end

      def verify_claims!(id_token)
        verify_iss!(id_token)
        verify_aud!(id_token)
        verify_iat!(id_token)
        verify_exp!(id_token)
        verify_nonce!(id_token) if id_token[:nonce_supported]
      end

      def verify_iss!(id_token)
        invalid_claim! :iss unless id_token['iss'] == site
      end

      def verify_aud!(id_token)
        invalid_claim! :aud unless id_token['aud'] == key
      end

      def verify_iat!(id_token)
        invalid_claim! :iat unless id_token['iat'] <= Time.now.to_i
      end

      def verify_exp!(id_token)
        invalid_claim! :exp unless id_token['exp'] >= Time.now.to_i
      end

      def verify_nonce!(id_token)
        invalid_claim! :nonce unless id_token['nonce'] && id_token['nonce'] == stored_nonce
      end

      def invalid_claim!(claim)
        raise InvalidClaim, "#{claim} invalid"
      end
    end

    class InvalidClaim < StandardError
    end
  end
end
