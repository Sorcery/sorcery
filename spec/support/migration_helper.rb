class MigrationHelper
  class << self
    def migrate(path)
      if ActiveRecord.version >= Gem::Version.new('6.0.0')
        ActiveRecord::MigrationContext.new(path, schema_migration).migrate
      elsif ActiveRecord.version >= Gem::Version.new('5.2.0')
        ActiveRecord::MigrationContext.new(path).migrate
      else
        ActiveRecord::Migrator.migrate(path)
      end
    end

    def rollback(path)
      if ActiveRecord.version >= Gem::Version.new('6.0.0')
        ActiveRecord::MigrationContext.new(path, schema_migration).rollback
      elsif ActiveRecord.version >= Gem::Version.new('5.2.0')
        ActiveRecord::MigrationContext.new(path).rollback
      else
        ActiveRecord::Migrator.rollback(path)
      end
    end

    private

    def schema_migration
      ActiveRecord::Base.connection.schema_migration
    end
  end
end
