module Sorcery
  module Generators
    module Helpers
      private

      def file_path
        model_name.underscore
      end

      def migration_class_name
        if Rails::VERSION::MAJOR >= 5
          "ActiveRecord::Migration[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        else
          'ActiveRecord::Migration'
        end
      end

      # Either return the model passed in a classified form or return the default "User".
      def model_class_name
        options[:model] ? options[:model].classify : 'User'
      end

      def model_injection
        indents = model_class_name.split('::').count
        indents += 1 if namespace

        "#{'  ' * indents}authenticates_with_sorcery!\n"
      end

      def model_injection_point
        "class #{model_class_name} < #{model_superclass_name}\n"
      end

      def model_name
        if namespace
          [namespace.to_s] + [model_class_name]
        else
          [model_class_name]
        end.join('::')
      end

      def model_path
        @model_path ||= File.join('app', 'models', "#{file_path}.rb")
      end

      def model_superclass_name
        if Rails::VERSION::MAJOR >= 5
          'ApplicationRecord'
        else
          'ActiveRecord::Base'
        end
      end

      def namespace
        Rails::Generators.namespace if Rails::Generators.respond_to?(:namespace)
      end

      def only_submodules?
        options[:migrations] || options[:only_submodules]
      end

      def sorcery_config_path
        'config/initializers/sorcery.rb'
      end

      def tableized_model_class
        model_class_name.gsub(/::/, '').tableize
      end
    end
  end
end
