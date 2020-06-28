module Sorcery
  module Controller
    class Config
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
        def instance
          @instance ||= new(DEFAULTS)
        end

        def init!
          @instance = new(DEFAULTS)
        end

        def add_defaults(defaults)
          attr_accessor(*defaults.keys)

          # Delegate accessor methods to instance
          defaults.each_key do |name|
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def self.#{name}
                instance.#{name}
              end

              def self.#{name}=(value)
                instance.#{name} = value
              end
            RUBY
          end

          @instance = instance.merge(defaults)
        end

        # Delegate methods to instance
        %i[reset! user_config configure configure!].each do |name|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}(&blk)
              block_given? ? instance.#{name}(&blk) : instance.#{name}
            end
          RUBY
        end
      end

      def initialize(defaults)
        @defaults = defaults.dup.transform_values { |v| v.is_a?(Class) ? v : v.dup }
        reset!
      end

      # Resets all configuration options to their default values.
      def reset!
        @defaults.each do |k, v|
          instance_variable_set("@#{k}", v)
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

      def merge(other)
        new_defaults = attributes.merge(other)
        self.class.new(new_defaults)
      end

      def dup
        self.class.new(attributes)
      end

      private def attributes
        keys = @defaults.keys + [:user_config, :configure_blk]
        keys.map { |k| [k, instance_variable_get("@#{k}")] }.to_h
      end

      add_defaults(DEFAULTS)
    end
  end
end
