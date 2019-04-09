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
        attr_accessor :after_remember_me

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
            :@after_remember_me                    => [],
            :@save_return_to_url                   => true,
            :@cookie_domain                        => nil
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
