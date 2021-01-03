require 'active_support/concern'
require 'active_support/testing/stream'
require 'rails/generators'

module GeneratorHelper
  extend ActiveSupport::Concern
  include ActiveSupport::Testing::Stream
  include FileUtils

  included do |base|
    class_attribute :destination_root, default: File.expand_path('../rails_app', __dir__)
    class_attribute :generator_class

    base.teardown :remove_installation!
  end

  module ClassMethods
    def tests(klass)
      self.generator_class = klass
    end

    def destination(path)
      self.destination_root = path
    end
  end

  # Instantiate the generator.
  def generator(*args, options: {}, config: {})
    generator_class.new(args, options, config.reverse_merge(destination_root: destination_root))
  end

  # Invoke a specific action
  def invoke!(action, *args, options: {}, config: {})
    gen = generator(*args, options: options, config: config.reverse_merge(behavior: :invoke))

    capture(:stdout) do
      gen.invoke(action)
    end
  end

  # Revoke a specific action
  def revoke!(action, *args, options: {}, config: {})
    gen = generator(*args, options: options, config: config.reverse_merge(behavior: :revoke))

    capture(:stdout) do
      gen.invoke(action)
    end
  end

  def initializer_path
    @initializer_path ||= File.join(destination_root, 'config', 'initializers', 'sorcery.rb')
  end

  def migrations_path
    @migrations_path ||= File.join(destination_root, 'db', 'migrate')
  end

  # def migration_path(migration)
  #   @migration_path ||= {}
  #   @migration_path[migration.to_s] ||= Dir.glob("#{migrations_path}/[0-9]*_*.rb")
  #     .grep(/\d+_#{migration}.rb$/)
  #     .first
  # end

  def model_path(model)
    @model_path ||= {}
    @model_path[model.to_s] ||= File.join(destination_root, 'app', 'models', "#{model}.rb")
  end

private

  def remove_installation!
    # Remove any generated initializers, models, migrations files
    files = [initializer_path]
    files += Dir.glob(File.join(destination_root, 'app', 'models', '*.rb'))
    files += Dir.glob(File.join(destination_root, 'db', 'migrate', '*.rb'))

    files.each do |file|
      rm_f(file) if File.exists?(file)
    end

    # Recursively remove full directories
    dirs = [
      File.join(destination_root, 'test')
    ]

    dirs.each do |dir|
      rm_rf(dir) if Dir.exists?(dir)
    end
  end
end