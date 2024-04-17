class MigrationHelper
  class << self
    def migrate(path)
      ActiveRecord::MigrationContext.new(path, schema_migration).migrate
    end

    def rollback(path)
      ActiveRecord::MigrationContext.new(path, schema_migration).rollback
    end

    private

    def schema_migration
      ActiveRecord::Base.connection.schema_migration
    end
  end
end
