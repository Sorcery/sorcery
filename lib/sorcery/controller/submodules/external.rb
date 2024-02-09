module Sorcery
  module Controller
    module Submodules
      # This submodule helps you login users from external auth providers such as Twitter.
      # This is the controller part which handles the http requests and tokens passed between the app and the @provider.
      module External
        def self.included(base)
          base.send(:include, InstanceMethods)

          require 'sorcery/providers/base'
          require 'sorcery/providers/facebook'
          require 'sorcery/providers/twitter'
          require 'sorcery/providers/vk'
          require 'sorcery/providers/linkedin'
          require 'sorcery/providers/liveid'
          require 'sorcery/providers/xing'
          require 'sorcery/providers/github'
          require 'sorcery/providers/heroku'
          require 'sorcery/providers/google'
          require 'sorcery/providers/jira'
          require 'sorcery/providers/salesforce'
          require 'sorcery/providers/paypal'
          require 'sorcery/providers/slack'
          require 'sorcery/providers/wechat'
          require 'sorcery/providers/microsoft'
          require 'sorcery/providers/instagram'
          require 'sorcery/providers/auth0'
          require 'sorcery/providers/line'
          require 'sorcery/providers/discord'
          require 'sorcery/providers/battlenet'

          Config.module_eval do
            class << self
              attr_reader :external_providers
              attr_accessor :ca_file

              def external_providers=(providers)
                @external_providers = providers

                providers.each do |name|
                  class_eval <<-RUBY, __FILE__, __LINE__ + 1
                    def self.#{name}
                      @#{name} ||= Sorcery::Providers.const_get('#{name}'.to_s.camelcase).new
                    end
                  RUBY
                end
              end

              def merge_external_defaults!
                @defaults.merge!(:@external_providers => [],
                                 :@ca_file => File.join(__dir__, '../../protocols/certs/ca-bundle.crt'))
              end
            end
            merge_external_defaults!
          end
        end

        module InstanceMethods
          protected

          # save the singleton ProviderClient instance into @provider
          def sorcery_get_provider(provider_name)
            return unless Config.external_providers.include?(provider_name.to_sym)

            Config.send(provider_name.to_sym)
          end

          # get the login URL from the provider, if applicable.  Returns nil if the provider
          # does not provide a login URL.  (as of v0.8.1 all providers provide a login URL)
          def sorcery_login_url(provider_name, args = {})
            @provider = sorcery_get_provider provider_name
            sorcery_fixup_callback_url @provider

            return nil unless @provider.respond_to?(:login_url) && @provider.has_callback?

            @provider.state = args[:state]
            @provider.login_url(params, session)
          end

          # get the user hash from a provider using information from the params and session.
          def sorcery_fetch_user_hash(provider_name)
            # the application should never ask for user hashes from two different providers
            # on the same request.  But if they do, we should be ready: on the second request,
            # clear out the instance variables if the provider is different
            provider = sorcery_get_provider provider_name
            if @provider.nil? || @provider != provider
              @provider = provider
              @access_token = nil
              @user_hash = nil
            end

            # delegate to the provider for the access token and the user hash.
            # cache them in instance variables.
            @access_token ||= @provider.process_callback(params, session) # sends request to oauth agent to get the token
            @user_hash ||= @provider.get_user_hash(@access_token) # uses the token to send another request to the oauth agent requesting user info
            nil
          end

          # for backwards compatibility
          def access_token(*_args)
            @access_token
          end

          # this method should be somewhere else.  It only does something once per application per provider.
          def sorcery_fixup_callback_url(provider)
            provider.original_callback_url ||= provider.callback_url

            return unless provider.original_callback_url.present? && provider.original_callback_url[0] == '/'

            uri = URI.parse(request.url.gsub(/\?.*$/, ''))
            uri.path = ''
            uri.query = nil
            uri.scheme = 'https' if request.env['HTTP_X_FORWARDED_PROTO'] == 'https'
            host = uri.to_s
            provider.callback_url = "#{host}#{@provider.original_callback_url}"
          end

          # sends user to authenticate at the provider's website.
          # after authentication the user is redirected to the callback defined in the provider config
          def login_at(provider_name, args = {})
            redirect_to sorcery_login_url(provider_name, args), allow_other_host: true
          end

          # tries to login the user from provider's callback
          def login_from(provider_name, should_remember = false)
            sorcery_fetch_user_hash provider_name

            return unless (user = user_class.load_from_provider(provider_name, @user_hash[:uid].to_s))

            # we found the user.
            # clear the session
            return_to_url = session[:return_to_url]
            reset_sorcery_session
            session[:return_to_url] = return_to_url

            # sign in the user
            auto_login(user, should_remember)
            after_login!(user)

            # return the user
            user
          end

          # If user is logged, he can add all available providers into his account
          def add_provider_to_user(provider_name)
            sorcery_fetch_user_hash provider_name
            # config = user_class.sorcery_config # TODO: Unused, remove?

            current_user.add_provider_to_user(provider_name.to_s, @user_hash[:uid].to_s)
          end

          # Initialize new user from provider informations.
          # If a provider doesn't give required informations or username/email is already taken,
          # we store provider/user infos into a session and can be rendered into registration form
          def create_and_validate_from(provider_name)
            sorcery_fetch_user_hash provider_name
            config = user_class.sorcery_config

            attrs = user_attrs(@provider.user_info_mapping, @user_hash)

            user, saved = user_class.create_and_validate_from_provider(provider_name, @user_hash[:uid], attrs)

            unless saved
              session[:incomplete_user] = {
                provider: { config.provider_uid_attribute_name => @user_hash[:uid], config.provider_attribute_name => provider_name },
                user_hash: attrs
              }
            end

            user
          end

          # this method automatically creates a new user from the data in the external user hash.
          # The mappings from user hash fields to user db fields are set at controller config.
          # If the hash field you would like to map is nested, use slashes. For example, Given a hash like:
          #
          #   "user" => {"name"=>"moishe"}
          #
          # You will set the mapping:
          #
          #   {:username => "user/name"}
          #
          # And this will cause 'moishe' to be set as the value of :username field.
          # Note: Be careful. This method skips validations model.
          # Instead you can pass a block, if the block returns false the user will not be created
          #
          #   create_from(provider) {|user| user.some_check }
          #
          def create_from(provider_name, &block)
            sorcery_fetch_user_hash provider_name
            # config = user_class.sorcery_config # TODO: Unused, remove?

            attrs = user_attrs(@provider.user_info_mapping, @user_hash)
            @user = user_class.create_from_provider(provider_name, @user_hash[:uid], attrs, &block)
          end

          # follows the same patterns as create_from, but builds the user instead of creating
          def build_from(provider_name, &block)
            sorcery_fetch_user_hash provider_name
            # config = user_class.sorcery_config # TODO: Unused, remove?

            attrs = user_attrs(@provider.user_info_mapping, @user_hash)
            @user = user_class.build_from_provider(attrs, &block)
          end

          def user_attrs(user_info_mapping, user_hash)
            attrs = {}
            user_info_mapping.each do |k, v|
              if (varr = v.split('/')).size > 1
                attribute_value = begin
                                    varr.inject(user_hash[:user_info]) { |hash, value| hash[value] }
                                  rescue StandardError
                                    nil
                                  end
                attribute_value.nil? ? attrs : attrs.merge!(k => attribute_value)
              else
                attrs.merge!(k => user_hash[:user_info][v])
              end
            end
            attrs
          end
        end
      end
    end
  end
end
