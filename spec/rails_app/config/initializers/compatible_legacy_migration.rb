module ActiveRecord
  module CompatibleLegacyMigration
    def self.migration_class
      if Rails::VERSION::MAJOR >= 5
        ActiveRecord::Migration::Current
      else
        ActiveRecord::Migration
      end
    end
  end
end
