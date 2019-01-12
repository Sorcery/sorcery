module Sorcery
  module Controller
    module Config
      class << self
        attr_accessor :submodules
        # what class to use as the user class.
        attr_accessor :user_class
        # what controller action to call for non-authenticated users.
        attr_accessor :not_authenticated_action
        # when a non logged in user tries to enter a page that requires login,
        # save the URL he wanted to reach, and send him there after login.
        attr_accessor :save_return_to_url
        # set domain option for cookies
        attr_accessor :cookie_domain

        attr_accessor :login_sources
        attr_accessor :after_login
        attr_accessor :after_failed_login
        attr_accessor :before_logout
        attr_accessor :after_logout
        attr_accessor :jwt_user_params
        attr_accessor :jwt_headers_key
        attr_accessor :jwt_user_data_key
        attr_accessor :jwt_auth_token_key
        # If true, will set user by request to db.
        # If false will use data from jwt_user_params without executing db requests.
        attr_accessor :jwt_set_user
        attr_accessor :jwt_secret_key
        attr_accessor :jwt_payload
        attr_accessor :jwt_algorithm

        def init!
          @defaults = {
            :@user_class                           => nil,
            :@submodules                           => [],
            :@not_authenticated_action             => :not_authenticated,
            :@login_sources                        => [],
            :@after_login                          => [],
            :@after_failed_login                   => [],
            :@before_logout                        => [],
            :@after_logout                         => [],
            :@save_return_to_url                   => true,
            :@cookie_domain                        => nil,
            :@jwt_user_params                      => [:id],
            :@jwt_headers_key                      => 'Authorization',
            :@jwt_user_data_key                    => :user_data,
            :@jwt_payload                          => {},
            :@jwt_algorithm                        => 'HS256',
            :@jwt_auth_token_key                   => :auth_token,
            :@jwt_set_user                         => true,
            :@jwt_secret_key                       => 'default_secret_key'
          }
        end

        # Resets all configuration options to their default values.
        def reset!
          @defaults.each do |k, v|
            instance_variable_set(k, v)
          end
        end

        def update!
          @defaults.each do |k, v|
            instance_variable_set(k, v) unless instance_variable_defined?(k)
          end
        end

        def user_config(&blk)
          block_given? ? @user_config = blk : @user_config
        end

        def configure(&blk)
          @configure_blk = blk
        end

        def configure!
          @configure_blk.call(self) if @configure_blk
        end
      end

      init!
      reset!
    end
  end
end
