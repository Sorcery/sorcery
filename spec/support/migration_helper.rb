class MigrationHelper
  class << self
    def migrate(path)
      if Rails.version >= '7.0'
        ActiveRecord::MigrationContext.new(path).migrate
      elsif Rails.version < '7.0'
        ActiveRecord::MigrationContext.new(path, schema_migration).migrate
      end
    end

    def rollback(path)
      if Rails.version >= '7.0'
        ActiveRecord::MigrationContext.new(path).rollback
      elsif Rails.version < '7.0'
        ActiveRecord::MigrationContext.new(path, schema_migration).rollback
      end
    end

    private
    def schema_migration
      ActiveRecord::Base.connection.schema_migration
    end
  end
end
