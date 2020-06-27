module Sorcery
  module Controller
    module Config
      DEFAULTS = {
        # what class to use as the user class.
        :user_class                           => nil,
        :submodules                           => [],
        # what controller action to call for non-authenticated users.
        :not_authenticated_action             => :not_authenticated,
        :login_sources                        => Set.new,
        :after_login                          => Set.new,
        :after_failed_login                   => Set.new,
        :before_logout                        => Set.new,
        :after_logout                         => Set.new,
        :after_remember_me                    => Set.new,
        # when a non logged in user tries to enter a page that requires login,
        # save the URL he wanted to reach, and send him there after login.
        :save_return_to_url                   => true,
        # set domain option for cookies
        :cookie_domain                        => nil
      }.freeze
      private_constant :DEFAULTS

      class << self
        def add_defaults(defaults)
          singleton_class.attr_accessor(*defaults.keys)
          @defaults.merge!(
            defaults.transform_keys { |key| "@#{key}".to_sym }
          )
        end

        def init!
          @defaults = DEFAULTS.map { |k, v| ["@#{k}".to_sym, v.dup] }.to_h
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
      add_defaults(DEFAULTS)
      reset!
    end
  end
end
