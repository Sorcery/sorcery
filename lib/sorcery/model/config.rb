# Each class which calls 'activate_sorcery!' receives an instance of this class.
# Every submodule which gets loaded may add accessors to this class so that all
# options will be configured from a single place.
module Sorcery
  module Model
    class Config
      # change *virtual* password attribute, the one which is used until an encrypted one is generated.
      attr_accessor :password_attribute_name
      # change default email attribute.
      attr_accessor :email_attribute_name
      # downcase the username before trying to authenticate, default is false
      attr_accessor :downcase_username_before_authenticating
      # change default crypted_password attribute.
      attr_accessor :crypted_password_attribute_name
      # application-specific secret token that is joined with the password and its salt.
      # Currently available with BCrypt (default crypt provider) only.
      attr_accessor :pepper
      # what pattern to use to join the password with the salt
      # APPLICABLE TO MD5, SHA1, SHA256, SHA512. Other crypt providers (incl. BCrypt) ignore this parameter.
      attr_accessor :salt_join_token
      # change default salt attribute.
      attr_accessor :salt_attribute_name
      # how many times to apply encryption to the password.
      attr_accessor :stretches
      # encryption key used to encrypt reversible encryptions such as AES256.
      attr_accessor :encryption_key
      # make this configuration inheritable for subclasses. Useful for ActiveRecord's STI.
      attr_accessor :subclasses_inherit_config
      # configured in config/application.rb
      attr_accessor :submodules
      # an array of method names to call before authentication completes. used internally.
      attr_accessor :before_authenticate
      # method to send email related
      # options: `:deliver_later`, `:deliver_now`, `:deliver`
      # Default: :deliver (Rails version < 4.2) or :deliver_now (Rails version 4.2+)
      # method to send email related
      attr_accessor :email_delivery_method
      # an array of method names to call after configuration by user. used internally.
      attr_accessor :after_config
      # Set token randomness
      attr_accessor :token_randomness

      # change default username attribute, for example, to use :email as the login. See 'username_attribute_names=' below.
      attr_reader :username_attribute_names
      # change default encryption_provider.
      attr_reader :encryption_provider
      # use an external encryption class.
      attr_reader :custom_encryption_provider
      # encryption algorithm name. See 'encryption_algorithm=' below for available options.
      attr_reader :encryption_algorithm

      def initialize
        @defaults = {
          :@submodules                           => [],
          :@username_attribute_names             => [:email],
          :@password_attribute_name              => :password,
          :@downcase_username_before_authenticating => false,
          :@email_attribute_name                 => :email,
          :@crypted_password_attribute_name      => :crypted_password,
          :@encryption_algorithm                 => :bcrypt,
          :@encryption_provider                  => CryptoProviders::BCrypt,
          :@custom_encryption_provider           => nil,
          :@encryption_key                       => nil,
          :@pepper                               => '',
          :@salt_join_token                      => '',
          :@salt_attribute_name                  => :salt,
          :@stretches                            => nil,
          :@subclasses_inherit_config            => false,
          :@before_authenticate                  => [],
          :@after_config                         => [],
          :@email_delivery_method                => default_email_delivery_method,
          :@token_randomness                     => 15
        }
        reset!
      end

      # Resets all configuration options to their default values.
      def reset!
        @defaults.each do |k, v|
          instance_variable_set(k, v)
        end
      end

      def username_attribute_names=(fields)
        @username_attribute_names = fields.is_a?(Array) ? fields : [fields]
      end

      def custom_encryption_provider=(provider)
        @custom_encryption_provider = @encryption_provider = provider
      end

      def encryption_algorithm=(algo)
        @encryption_algorithm = algo
        @encryption_provider = case @encryption_algorithm.to_sym
                               when :none   then nil
                               when :md5    then CryptoProviders::MD5
                               when :sha1   then CryptoProviders::SHA1
                               when :sha256 then CryptoProviders::SHA256
                               when :sha512 then CryptoProviders::SHA512
                               when :aes256 then CryptoProviders::AES256
                               when :bcrypt then CryptoProviders::BCrypt
                               when :custom then @custom_encryption_provider
                               else raise ArgumentError, "Encryption algorithm supplied, #{algo}, is invalid"
                               end
      end

      private

      def default_email_delivery_method
        # Rails 4.2 deprecates #deliver
        rails_version_bigger_than_or_equal?('4.2.0') ? :deliver_now : :deliver
      end

      def rails_version_bigger_than_or_equal?(version)
        Gem::Version.new(version) <= Gem::Version.new(Rails.version)
      end
    end
  end
end
